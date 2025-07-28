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
	id: root
	property bool locked: true

	Timer {
		id: unlockTimer
		interval: 1000
		onTriggered: {
			lock.locked = false;
			root.locked = true; // Reset animation
		}
	}

	PamContext {
		id: pam
		property string response
		property string error: ""

		onPamMessage: {
			if (responseRequired)
				respond(response);
			else if (messageIsError)
				error = message;
		}

		onCompleted: status => {
			const success = status === PamResult.Success;
			if (success) {
				root.locked = false;
				unlockTimer.start();
			} else {
				error = "Invalid password";
			}
		}

		function login(password: string): void {
			response = password;
			start();
		}
	}

	IpcHandler {
		target: "lockscreen"

		function lock(): void {
			root.locked = lock.locked = true;
		}
		function unlock(): void {
			lock.locked = false;
		}
	}

	WlSessionLock {
		id: lock

		WlSessionLockSurface {
			id: surface
			color: "transparent"

			ScreencopyView {
				anchors.fill: parent
				captureSource: surface.screen
			}

			Item {
				anchors.fill: parent

				opacity: root.locked ? 1 : 0
				Behavior on opacity {
					NumberAnimation {
						duration: 1000
						easing.type: Easing.BezierSpline
						easing.bezierCurve: [0.2, 0, 0, 1, 1, 1]
					}
				}

				Image {
					id: background
					anchors.fill: parent
					fillMode: Image.PreserveAspectCrop
					source: "/home/axel/Pictures/wallpaper.jpg"
					cache: true
					smooth: false

					layer.enabled: true
					layer.effect: MultiEffect {
						autoPaddingEnabled: false
						blurEnabled: true
						blur: 1
						blurMax: 48
					}
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
					placeholderTextColor: "#b7becf"
					font.pixelSize: 16
					color: "#F5F5F5"

					anchors.horizontalCenter: username.horizontalCenter
					anchors.top: username.bottom
					anchors.topMargin: 20
					padding: 8
					implicitWidth: 250
					implicitHeight: 40

					background: Rectangle {
						radius: 7
						color: "#C0BFC0"
						opacity: 0.3
					}

					Component.onCompleted: forceActiveFocus()
					onAccepted: pam.login(text)
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
			}
		}
	}
}
