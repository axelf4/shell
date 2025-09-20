//@ pragma UseQApplication
//@ pragma NativeTextRendering

import QtQuick
import Quickshell

ShellRoot {
	NotificationWindow {}
	Bar {}

	Variants {
		model: Quickshell.screens

		Scope {
			id: root
			required property ShellScreen modelData

			Wallpaper {
				screen: root.modelData
			}
		}
	}

	Component.onCompleted: LockScreen
}
