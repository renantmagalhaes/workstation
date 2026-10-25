//@ pragma UseQApplication

import Quickshell
import "Modules"

ShellRoot {
    Variants {
        model: Quickshell.screens

        Bar {}
    }

    Variants {
        model: Quickshell.screens

        Overview {}
    }

    Variants {
        model: Quickshell.screens

        Launcher {}
    }
}
