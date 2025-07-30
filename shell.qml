//@ pragma UseQApplication
//@ pragma NativeTextRendering

import QtQuick
import Quickshell

ShellRoot {
	NotificationWindow {}

	Variants {
		model: Quickshell.screens

		Scope {
			id: root
			required property ShellScreen modelData

			Wallpaper {
				screen: root.modelData
			}
			Bar {
				screen: root.modelData
			}
		}
	}

	Component.onCompleted: LockScreen
}
