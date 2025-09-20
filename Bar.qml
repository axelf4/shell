pragma ComponentBehavior: Bound

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
				ignoreUnknownSignals: true
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
					PropertyChanges {
						content {
							opacity: 1
						}
						scale {
							xScale: 1
						}
					}
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

	component IconButton: MouseArea {
		id: mouseArea
		required property string popupSource
		default property alias content: button.children

		cursorShape: Qt.PointingHandCursor
		hoverEnabled: true
		Layout.fillWidth: true
		implicitHeight: width

		Rectangle {
			anchors.fill: button
			anchors.margins: -4
			radius: C.radius
			color: C.primary
			visible: mouseArea.containsMouse
			opacity: mouseArea.pressed ? 0.12 : 0.08
		}

		Item {
			id: button
			anchors.fill: parent
			anchors.margins: C.spacing.small
		}

		onClicked: event => root.togglePopup(button, popupSource)
	}

	ColumnLayout {
		anchors.fill: parent
		spacing: 0

		IconButton {
			popupSource: "Launcher.qml"
			Image {
				id: startButton
				anchors.fill: parent
				source: Quickshell.iconPath("nix-snowflake-white")
				sourceSize.width: 2 * width
				sourceSize.height: 2 * height

				layer.enabled: true
				layer.effect: MultiEffect {
					colorization: 1
					colorizationColor: C._onSurface
				}
			}
		}

		Item {
			Layout.fillHeight: true
		}

		SysTray {
			Layout.fillWidth: true
		}

		IconButton {
			popupSource: "AudioWidget.qml"
			Image {
				anchors.fill: parent
				source: "audio.svg"
				sourceSize.width: width
				sourceSize.height: height

				layer.enabled: true
				layer.effect: MultiEffect {
					colorization: 1
					colorizationColor: C._onSurface
				}
			}
		}

		IconButton {
			popupSource: "BluetoothWidget.qml"
			Image {
				source: "bluetooth.svg"
				sourceSize.width: 4 * 32
				sourceSize.height: 4 * 32
				fillMode: Image.PreserveAspectCrop
				smooth: false
				anchors.centerIn: parent
				width: C.barWidth
				height: C.barWidth
			}
		}

		BatteryIcon {
			Layout.alignment: Qt.AlignCenter
		}

		Text {
			text: Qt.formatDateTime(Time.date, "hh\nmm")
			textFormat: Text.PlainText
			horizontalAlignment: Text.AlignHCenter
			lineHeight: 0.8
			Layout.alignment: Qt.AlignCenter
			Layout.bottomMargin: C.spacing.small
			font.pixelSize: C.fontSmall
			color: C._onSurface
		}
	}
}
