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
		interval: C.duration._long
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
				scale: root.locked ? 1 : 1.2
				Behavior on opacity {
					OpacityAnimator {
						duration: C.duration._long
						easing.type: Easing.BezierSpline
						easing.bezierCurve: C.easing.emphasizedAccel
					}
				}
				Behavior on scale {
					ScaleAnimator {
						duration: C.duration._long
						easing.type: Easing.BezierSpline
						easing.bezierCurve: C.easing.emphasizedAccel
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
					radius: C.radiusFull
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
					textFormat: Text.PlainText
					font.pixelSize: C.fontLarge
					font.weight: Font.Medium
					color: C.primary
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
					placeholderTextColor: C.primary
					font.pixelSize: C.fontMedium
					color: C._onSurface
					focus: true

					anchors.horizontalCenter: username.horizontalCenter
					anchors.top: username.bottom
					anchors.topMargin: C.spacing.large
					padding: 8
					implicitWidth: 250
					implicitHeight: 40

					background: Rectangle {
						radius: C.radius
						color: C.surface
						opacity: 0.6
					}

					onAccepted: pam.login(text)
				}

				Text {
					text: pam.error
					textFormat: Text.PlainText
					visible: pam.error !== ""
					color: C.error
					font.pixelSize: C.fontSmall
					anchors.top: input.bottom
					anchors.left: input.left
					anchors.topMargin: C.spacing.small
				}
			}
		}
	}
}
