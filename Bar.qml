import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
	id: root
	anchors {
		top: true
		bottom: true
		left: true
	}
	implicitWidth: C.barWidth

	PanelWindow {
		id: popup
		exclusionMode: ExclusionMode.Ignore
		WlrLayershell.layer: WlrLayer.Overlay
		WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
		anchors {
			top: true
			right: true
			bottom: true
			left: true
		}
		visible: false
		color: "transparent"

		MouseArea {
			anchors.fill: parent
			onPressed: content.state = "hidden"
		}

		Item {
			id: content
			width: launcher.width
			height: launcher.height
			focus: true
			state: "hidden"

			Keys.onPressed: event => {
				if (event.key === Qt.Key_Escape) {
					content.state = "hidden";
					event.accepted = true;
				}
			}

			transform: Scale {
				id: scale
			}

			RectangularShadow {
				anchors.fill: parent
				blur: 10
				offset: Qt.vector2d(0, 3)
			}
			Rectangle {
				anchors.fill: parent
				color: C.surfaceContainer
				radius: C.radius
				clip: true

				Ripple {
					id: ripple
					enabled: false
				}
			}
			Launcher {
				id: launcher
			}

			states: [
				State {
					name: "hidden"
					PropertyChanges {
						content {
							opacity: 0
						}
						scale {
							xScale: 0
						}
					}
				},
				State {
					name: "visible"
				}
			]

			transitions: [
				Transition {
					to: "visible"
					SequentialAnimation {
						ScriptAction {
							script: popup.visible = true
						}
						ParallelAnimation {
							OpacityAnimator {
								target: content
								duration: C.duration.medium
								easing.type: Easing.BezierSpline
								easing.bezierCurve: C.easing.emphasizedDecel
							}
							NumberAnimation {
								target: scale
								property: "xScale"
								duration: C.duration.medium
								easing.type: Easing.BezierSpline
								easing.bezierCurve: C.easing.emphasizedDecel
							}
						}
					}
				},
				Transition {
					from: "visible"
					to: "hidden"
					SequentialAnimation {
						ParallelAnimation {
							OpacityAnimator {
								target: content
								duration: C.duration._short
								easing.type: Easing.BezierSpline
								easing.bezierCurve: C.easing.emphasizedAccel
							}
							NumberAnimation {
								target: scale
								property: "xScale"
								duration: C.duration._short
								easing.type: Easing.BezierSpline
								easing.bezierCurve: C.easing.emphasizedAccel
							}
						}
						ScriptAction {
							script: popup.visible = false
						}
					}
				}
			]
		}
	}

	function toggleLauncher(x: int, y: int): void {
		if (content.state === "visible") {
			content.state = "hidden";
			return;
		}
		popup.screen = root.screen;
		content.x = button.x;
		content.y = button.y;
		content.state = "visible";
		ripple.play(x - content.x, y - content.y);
		launcher.forceActiveFocus();
	}

	IpcHandler {
		target: "launcher"

		function toggle(): void {
			let x = button.x + button.width / 2, y = button.y + button.height / 2;
			root.toggleLauncher(x, y);
		}
	}

	Rectangle {
		anchors.fill: parent
		color: C.surface
	}

	ColumnLayout {
		anchors.fill: parent

		MouseArea {
			cursorShape: Qt.PointingHandCursor
			Layout.fillWidth: true
			implicitHeight: width

			onClicked: event => root.toggleLauncher(event.x, event.y)

			Rectangle {
				id: button
				anchors.fill: parent
				anchors.margins: C.spacing.small
				radius: C.radius
				color: C.primary

				Image {
					anchors.fill: parent
					anchors.margins: 2
					source: Quickshell.iconPath("nix-snowflake")
					sourceSize.width: 2 * width
					sourceSize.height: 2 * width
				}
			}
		}

		Item {
			Layout.fillHeight: true
		}

		SysTray {
			Layout.alignment: Qt.AlignHCenter
		}

		BatteryIcon {
			Layout.alignment: Qt.AlignHCenter
		}

		Text {
			text: Qt.formatDateTime(Time.date, "hh\nmm")
			textFormat: Text.PlainText
			lineHeight: 0.8
			Layout.alignment: Qt.AlignCenter
			Layout.bottomMargin: C.spacing.small
			font.pixelSize: C.fontSmall
			color: C._onSurface
		}
	}
}
