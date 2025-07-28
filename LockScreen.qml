pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pam

Singleton {
	PamContext {
		id: pam
		property string error: ""

		onPamMessage: {
			if (this.responseRequired)
				this.respond(lock.password);
			else if (this.messageIsError) {
				error = this.message;
			}
		}

		onCompleted: status => {
			const success = status === PamResult.Success;
			if (success) {
				lock.password = "";
				lock.locked = false;
			} else {
				error = "Invalid password";
			}
		}
	}

	IpcHandler {
		target: "lockscreen"

		function lock(): void {
			lock.locked = true;
		}
		function unlock(): void {
			lock.locked = false;
		}
	}

	WlSessionLock {
		id: lock
		property string password: ""

		WlSessionLockSurface {
			Image {
				id: background
				anchors.fill: parent
				fillMode: Image.PreserveAspectCrop
				source: "/home/axel/Pictures/wallpaper.jpg"
				cache: true
				smooth: false
			}
			MultiEffect {
				source: background
				anchors.fill: background
				blurEnabled: true
				blurMax: 48
				blur: 1.0
			}

			// User avatar/icon
			Rectangle {
				Layout.alignment: Qt.AlignHCenter
				implicitWidth: 100
				implicitHeight: 100
				radius: 50
				color: "#C0BFC0"

				/*
				  Image {
                  id: avatarImage
                  anchors.fill: parent
                  anchors.margins: 4
                  source: Settings.settings.profileImage
                  fillMode: Image.PreserveAspectCrop
                  visible: false // Only show the masked version
                  asynchronous: true
				  }
				  // Fallback icon
				  Text {
                  anchors.centerIn: parent
                  text: "person"
                  font.family: "Material Symbols Outlined"
                  font.pixelSize: 32
                  color: Theme.onAccent
                  visible: Settings.settings.profileImage === ""
				  }
				  // Glow effect
				  layer.enabled: true
				  layer.effect: Glow {
                  color: Theme.accentPrimary
                  radius: 8
                  samples: 16
				  }
				*/

				anchors.horizontalCenter: username.horizontalCenter
				anchors.bottom: username.top
				anchors.bottomMargin: 5
			}

			Text {
				id: username
				text: Quickshell.env("USER")
				font.pixelSize: 24
				font.weight: Font.Medium
				color: "#F5F5F5"
				anchors.centerIn: parent
			}

			TextField {
				id: input
				verticalAlignment: TextInput.AlignVCenter
				echoMode: TextInput.Password
				passwordCharacter: "●"
				passwordMaskDelay: 0
				enabled: !pam.active
				placeholderText: "Enter Password"
				// placeholderTextColor: "#E1DFE1"
				placeholderTextColor: "#b7becf"
				font.pixelSize: 16
				color: "#F5F5F5"

				anchors.horizontalCenter: username.horizontalCenter
				anchors.top: username.bottom
				anchors.topMargin: 20
				padding: 12
				implicitWidth: 250
				implicitHeight: 40

				background: Rectangle {
					radius: 7
					color: "#C0BFC0"
					opacity: 0.3
				}

				text: lock.password
				onTextChanged: lock.password = text

				Component.onCompleted: {
					forceActiveFocus();
				}
				onAccepted: pam.start()
			}

			Text {
				text: pam.error
				visible: pam.error !== ""
				color: "#ee0000"
				font.pixelSize: 14
				anchors.top: input.bottom
				anchors.left: input.left
				anchors.topMargin: 5
			}

			Button {
				text: "unlock me"
				onClicked: lock.locked = false
				anchors.top: input.bottom
				anchors.right: input.right
				anchors.topMargin: 5
			}

			/*
			// Unlock button
			Rectangle {
			Layout.alignment: Qt.AlignHCenter
			implicitWidth: 120
			implicitHeight: 44
			radius: 22
			opacity: unlockButtonArea.containsMouse ? 0.8 : 0.5
			color: "#ffff00"
			// color: unlockButtonArea.containsMouse ? Theme.accentPrimary : Theme.surface
			border.width: 2
			enabled: !pam.active

			Text {
			id: unlockButtonText
			anchors.centerIn: parent
			text: lock.authenticating ? "..." : "Unlock"
			font.pixelSize: 16
			font.bold: true
			// color: unlockButtonArea.containsMouse ? Theme.onAccent : Theme.accentPrimary
			color: "#00ffff"
			}

			MouseArea {
			id: unlockButtonArea
			anchors.fill: parent
			hoverEnabled: true
			onClicked: {
			if (!lock.authenticating) {
			pam.start();
			}
			}
			}

			Behavior on opacity {
			NumberAnimation {
			duration: 200
			}
			}
			}
			*/
		}
	}
}
