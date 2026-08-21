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
	Toast,
} from "@vicinae/api";
import { useEffect, useState } from "react";

type WindowEntry = WindowManagement.Window;

const useWindows = () => {
	const [loading, setLoading] = useState(true);
	const [windows, setWindows] = useState<WindowEntry[]>([]);
	const [error, setError] = useState<Error | null>(null);

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
	const [loading, setLoading] = useState(true);
	const [apps, setApps] = useState<Application[]>([]);
	const [error, setError] = useState<Error | null>(null);

	useEffect(() => {
		getApplications()
			.then(setApps)
			.catch(setError)
			.finally(() => setLoading(false));
	}, []);

	return { apps, loading, error };
};

const focusWindow = async (window: WindowEntry) => {
	const focused = await window.focus();
	if (!focused) {
		await showToast({
			style: Toast.Style.Failure,
			title: "Could not focus window",
			message: window.title,
		});
		return;
	}
	closeMainWindow();
};

const launchApp = async (app: Application) => {
	try {
		await open(app.path, app);
		closeMainWindow();
	} catch (error) {
		await showToast({
			style: Toast.Style.Failure,
			title: `Could not launch ${app.name}`,
			message: error instanceof Error ? error.message : String(error),
		});
	}
};

export default function Search() {
	const {
		windows,
		loading: windowsLoading,
		error: windowsError,
	} = useWindows();
	const { apps, loading: appsLoading, error: appsError } = useApps();

	const loading = windowsLoading || appsLoading;
	const error = windowsError ?? appsError;

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
		<List isLoading={loading} searchBarPlaceholder="Search apps and windows...">
			<List.Section title="Open Windows">
				{windows.map((window) => (
					<List.Item
						key={window.id}
						title={window.title}
						subtitle={window.application?.name}
						icon={window.application?.icon ?? Icon.AppWindow}
						accessories={
							window.active
								? [
										{
											text: "Focused",
											icon: Icon.Eye,
										},
									]
								: window.workspaceId
									? [
											{
												text: `WS ${window.workspaceId}`,
											},
										]
									: []
						}
						actions={
							<ActionPanel>
								<Action
									title="Focus Window"
									icon={Icon.Eye}
									onAction={() => focusWindow(window)}
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
						icon={app.icon ?? Icon.AppWindow}
						accessories={[{ text: "Launch" }]}
						actions={
							<ActionPanel>
								<Action
									title={`Launch ${app.name}`}
									icon={Icon.AppWindow}
									onAction={() => launchApp(app)}
								/>
							</ActionPanel>
						}
					/>
				))}
			</List.Section>
		</List>
	);
}
