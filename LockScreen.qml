pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pam

Singleton {
	Timer {
		id: unlockTimer
		interval: C.duration._long
		onTriggered: lock.unlocking = lock.locked = false
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
			if (status === PamResult.Success) {
				lock.unlocking = true;
				unlockTimer.start();
			} else
				error = "Invalid password";
		}

		function login(password: string): void {
			response = password;
			start();
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
		property bool unlocking: false

		WlSessionLockSurface {
			id: surface
			color: "transparent"

			ScreencopyView {
				anchors.fill: parent
				captureSource: surface.screen
			}

			Item {
				anchors.fill: parent
				opacity: lock.unlocking ? 0 : 1
				scale: lock.unlocking ? 1.2 : 1

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
