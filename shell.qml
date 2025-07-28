//@ pragma UseQApplication

import QtQuick
import Quickshell

Scope {
	Component.onCompleted: [LockScreen]

	NotificationWindow {}

	Variants {
		model: Quickshell.screens

		Scope {
			id: root
			required property ShellScreen modelData

			Bar {
				screen: root.modelData
			}
			Wallpaper {
				screen: root.modelData
			}
		}
	}
}
