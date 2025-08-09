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
		screen: root.screen
		visible: false
		color: "transparent"

		MouseArea {
			anchors.fill: parent
			onPressed: content.state = "hidden"
		}

		Item {
			id: content
			width: loader.width
			height: loader.height
			transform: Scale {
				id: scale
			}
			state: "hidden"

			RectangularShadow {
				anchors.fill: parent
				blur: 10
				offset: Qt.vector2d(0, 3)
			}
			Rectangle {
				anchors.fill: parent
				color: C.surfaceContainer
				radius: C.radius

				Ripple {
					id: ripple
					clip: true
					enabled: false
				}
			}
			Loader {
				id: loader
				focus: true
			}
			Connections {
				target: loader.item
				function onFinished(): void {
					content.state = "hidden";
				}
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

			Keys.onPressed: event => {
				if (event.key === Qt.Key_Escape) {
					content.state = "hidden";
					event.accepted = true;
				}
			}
		}
	}

	function togglePopup(button: Item, src: string): void {
		if (content.state === "visible") {
			content.state = "hidden";
			return;
		}
		loader.source = src;
		let p = button.mapToGlobal(0, 0);
		content.x = p.x;
		content.y = p.y + content.height > popup.screen.height //
		? p.y + button.height - content.height : p.y;
		content.state = "visible";
		ripple.play(button.width / 2, p.y + button.height / 2 - content.y);
	}

	IpcHandler {
		target: "launcher"

		function toggle(): void {
			root.togglePopup(startButton, "Launcher.qml");
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

			Rectangle {
				id: startButton
				anchors.fill: parent
				anchors.margins: C.spacing.small
				radius: C.radius
				color: C.primary

				Image {
					anchors.fill: parent
					anchors.margins: 2
					source: Quickshell.iconPath("nix-snowflake")
					sourceSize.width: 2 * width
					sourceSize.height: 2 * height
				}
			}

			onClicked: event => root.togglePopup(startButton, "Launcher.qml")
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
