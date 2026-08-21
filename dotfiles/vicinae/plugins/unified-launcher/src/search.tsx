import {
  Action,
  ActionPanel,
  Application,
  Icon,
  List,
  WindowManagement,
  closeMainWindow,
  getApplications,
  open,
  showToast,
  Toast
} from "@vicinae/api";
import { execFile } from "child_process";
import { promisify } from "util";
// eslint-disable-next-line @typescript-eslint/ban-ts-comment
// @ts-ignore
import { create, all } from "mathjs";
import {
  useEffect,
  useState
} from "react";

type WindowEntry =
  WindowManagement.Window;

// Lightweight math engine for inline expressions (arithmetic + unit conversion).
const math = create(all, {
  number: "BigNumber",
  precision: 16
});

type CalcResult = {
  expression: string;
  formatted: string;
  raw: string;
};

const tryEvaluate = (
  input: string
): CalcResult | null => {
  const trimmed = input.trim();

  if (trimmed.length < 2) {
    return null;
  }

  try {
    const node = math.parse(trimmed);
    const result = node.evaluate();

    if (result === undefined || result === null) {
      return null;
    }

    const isUnit = result
      && typeof result === "object"
      && "units" in result;

    let raw: string;
    let formatted: string;

    if (node.type === "OperatorNode") {
      // Only treat as a calculation if it's an operator (so plain "vivaldi"
      // or symbols like "e"/"pi" are not evaluated as results).
      raw = String(result);
      if (isUnit) {
        /*
         * Unit result: format as "<value> <unit>".
         * mathjs ->toString already does this.
         */
        formatted = result.format
          ? result.format({ precision: 14 })
          : raw;
      } else {
        formatted = typeof result === "number"
          ? String(Number(result))
          : raw;
      }
    } else {
      return null;
    }

    return {
      expression: trimmed,
      formatted,
      raw
    };
  } catch {
    return null;
  }
};

// Built-in Vicinae commands surfaced in the launcher. Each is launched through
// the vicinae CLI so it opens in the (single) running Vicinae window.
type VicinaeCommandGroup = {
  group: string;
  icon: Icon;
  commands: { id: string; title: string; icon?: Icon }[];
};

const VICINAE_COMMANDS: VicinaeCommandGroup[] = [
  {
    group: "Settings & System",
    icon: Icon.Cog,
    commands: [
      {
        id: "core:settings",
        title: "Open Settings"
      },
      {
        id: "wm:switch-windows",
        title: "Switch Windows"
      },
      {
        id: "theme:set",
        title: "Change Theme"
      },
      {
        id: "core:manage-fallback",
        title: "Configure Fallbacks"
      },
      {
        id: "system:set-default-terminal",
        title: "Set Default Terminal"
      },
      {
        id: "system:browse-apps",
        title: "Browse Applications"
      },
      {
        id: "core:list-extensions",
        title: "Installed Extensions"
      },
      {
        id: "core:search-builtin-icons",
        title: "Search Builtin Icons"
      },
      {
        id: "core:open-config-file",
        title: "Open Config File"
      },
      {
        id: "core:show-logs",
        title: "Show Logs"
      },
      {
        id: "core:refresh-apps",
        title: "Refresh Applications"
      }
    ]
  },
  {
    group: "Tools",
    icon: Icon.Hammer,
    commands: [
      {
        id: "calculator:history",
        title: "Calculator & Unit Converter",
        icon: Icon.Calculator
      },
      {
        id: "calculator:refresh-rates",
        title: "Refresh Exchange Rates"
      },
      {
        id: "clipboard:history",
        title: "Clipboard History",
        icon: Icon.CopyClipboard
      },
      {
        id: "clipboard:clear",
        title: "Clear Clipboard"
      },
      {
        id: "files:search",
        title: "Search Files",
        icon: Icon.MagnifyingGlass
      },
      {
        id: "core:search-emojis",
        title: "Search Emojis",
        icon: Icon.Emoji
      },
      {
        id: "font:browse",
        title: "Browse Fonts"
      },
      {
        id: "system:run",
        title: "Run Command"
      }
    ]
  },
  {
    group: "Content",
    icon: Icon.Text,
    commands: [
      {
        id: "manage-shortcuts:manage",
        title: "Manage Shortcuts",
        icon: Icon.Link
      },
      {
        id: "manage-shortcuts:create",
        title: "Create Shortcut"
      },
      {
        id: "snippets:manage",
        title: "Manage Snippets"
      },
      {
        id: "snippets:create",
        title: "Create Snippet"
      },
      {
        id: "browser-extension:browse-tabs",
        title: "Browse Browser Tabs"
      },
      {
        id: "browser-extension:shortcut-active-tab",
        title: "Shortcut Active Tab"
      }
    ]
  },
  {
    group: "System Control",
    icon: Icon.Power,
    commands: [
      {
        id: "power:lock",
        title: "Lock Screen"
      },
      {
        id: "power:logout",
        title: "Log Out"
      },
      {
        id: "power:suspend",
        title: "Suspend"
      },
      {
        id: "power:reboot",
        title: "Reboot"
      },
      {
        id: "power:power-off",
        title: "Power Off"
      },
      {
        id: "system:volume-up",
        title: "Volume Up"
      },
      {
        id: "system:volume-down",
        title: "Volume Down"
      },
      {
        id: "system:toggle-mute",
        title: "Toggle Mute"
      }
    ]
  }
];

const execFileAsync = promisify(execFile);

const launchVicinaeCommand = async (
  command: { id: string; title: string }
) => {
  try {
    await execFileAsync("vicinae", [
      "cmd",
      "launch",
      command.id
    ]);
    closeMainWindow();
  } catch (error) {
    await showToast({
      style: Toast.Style.Failure,
      title: `Could not open ${command.title}`,
      message:
        error instanceof Error
          ? error.message
          : String(error)
    });
  }
};

const useWindows = () => {
  const [loading, setLoading] =
    useState(true);
  const [windows, setWindows] =
    useState<WindowEntry[]>([]);
  const [error, setError] =
    useState<Error | null>(null);

  const refresh = () => {
    setLoading(true);
    WindowManagement.getWindows()
      .then(setWindows)
      .catch(setError)
      .finally(() => setLoading(false));
  };

  useEffect(() => {
    refresh();
  }, []);

  return { windows, loading, error };
};

const useApps = () => {
  const [loading, setLoading] =
    useState(true);
  const [apps, setApps] = useState<
    Application[]
  >([]);
  const [error, setError] =
    useState<Error | null>(null);

  useEffect(() => {
    getApplications()
      .then(setApps)
      .catch(setError)
      .finally(() => setLoading(false));
  }, []);

  return { apps, loading, error };
};

const focusWindow = async (
  window: WindowEntry
) => {
  const focused = await window.focus();
  if (!focused) {
    await showToast({
      style: Toast.Style.Failure,
      title: "Could not focus window",
      message: window.title
    });
    return;
  }
  closeMainWindow();
};

const launchApp = async (
  app: Application
) => {
  try {
    // Launch the app itself (empty target). Passing app.path here would treat
    // the .desktop file as a target to open, causing the browser to try to
    // download it.
    await open("", app);
    closeMainWindow();
  } catch (error) {
    await showToast({
      style: Toast.Style.Failure,
      title: `Could not launch ${app.name}`,
      message:
        error instanceof Error
          ? error.message
          : String(error)
    });
  }
};

export default function Search() {
  const {
    windows,
    loading: windowsLoading,
    error: windowsError
  } = useWindows();
  const {
    apps,
    loading: appsLoading,
    error: appsError
  } = useApps();

  const [query, setQuery] = useState("");
  const calcResult = tryEvaluate(query);

  const loading =
    windowsLoading || appsLoading;
  const error =
    windowsError ?? appsError;

  if (error) {
    return (
      <List isLoading={false}>
        <List.EmptyView
          title="Could not load apps and windows"
          description={error.message}
          icon={Icon.Warning}
        />
      </List>
    );
  }

  return (
    <List
      isLoading={loading}
      filtering={true}
      searchBarPlaceholder="Search apps, windows, or type a calculation..."
      onSearchTextChange={setQuery}
      isShowingDetail={calcResult !== null}
    >
      {calcResult && (
        <List.Section
          title="Calculator"
          subtitle={
            calcResult.formatted
          }
        >
          <List.Item
            title={calcResult.formatted}
            subtitle={
              calcResult.expression
            }
            icon={Icon.Calculator}
            detail={
              <List.Item.Detail
                markdown={[
                  `### ${calcResult.expression}`,
                  "",
                  "---",
                  "",
                  "## Result",
                  "",
                  `# \`${calcResult.formatted}\``
                ].join("\n")}
              />
            }
            actions={
              <ActionPanel>
                <Action.CopyToClipboard
                  title="Copy Result"
                  content={calcResult.formatted}
                />
                <Action.CopyToClipboard
                  title="Copy Full Expression"
                  content={`${calcResult.expression} = ${calcResult.formatted}`}
                />
              </ActionPanel>
            }
          />
        </List.Section>
      )}
      <List.Section title="Open Windows">
        {windows.map((window) => (
          <List.Item
            key={window.id}
            title={window.title}
            subtitle={
              window.application?.name
            }
            icon={
              window.application
                ?.icon ?? Icon.AppWindow
            }
            accessories={
              window.active
                ? [
                    {
                      text: "Focused",
                      icon: Icon.Eye
                    }
                  ]
                : window.workspaceId
                  ? [
                      {
                        text: `WS ${window.workspaceId}`
                      }
                    ]
                  : []
            }
            actions={
              <ActionPanel>
                <Action
                  title="Focus Window"
                  icon={Icon.Eye}
                  onAction={() =>
                    focusWindow(window)
                  }
                />
                <Action.CopyToClipboard
                  title="Copy Window Title"
                  content={window.title}
                />
              </ActionPanel>
            }
          />
        ))}
      </List.Section>

      <List.Section title="Applications">
        {apps.map((app) => (
          <List.Item
            key={app.id}
            title={app.name}
            subtitle={app.path}
            icon={
              app.icon ?? Icon.AppWindow
            }
            accessories={[
              { text: "Launch" }
            ]}
            actions={
              <ActionPanel>
                <Action
                  title={`Launch ${app.name}`}
                  icon={Icon.AppWindow}
                  onAction={() =>
                    launchApp(app)
                  }
                />
              </ActionPanel>
            }
          />
        ))}
      </List.Section>

      {VICINAE_COMMANDS.map((group) => (
        <List.Section
          key={group.group}
          title={group.group}
          subtitle={String(
            group.commands.length
          )}
        >
          {group.commands.map((command) => (
            <List.Item
              key={command.id}
              title={command.title}
              subtitle={command.id}
              icon={command.icon ?? group.icon}
              accessories={[
                { text: "Open" }
              ]}
              actions={
                <ActionPanel>
                  <Action
                    title={`Open ${command.title}`}
                    icon={command.icon ?? group.icon}
                    onAction={() =>
                      launchVicinaeCommand(command)
                    }
                  />
                </ActionPanel>
              }
            />
          ))}
        </List.Section>
      ))}
    </List>
  );
}
