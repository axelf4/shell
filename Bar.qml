import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Services.UPower
import Quickshell.Wayland
/* import Quickshell.Hyprland */

PanelWindow {
	readonly property int popupWidth: 300
	readonly property int blurWidth: 10

	id: root

	anchors {
		left: true
		top: true
		bottom: true
	}
	implicitWidth: C.barWidth + popupWidth + blurWidth
	exclusiveZone: C.barWidth
	mask: Region {
		item: bar
	}
	color: "transparent"

	/* WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand */

	PopupWindow {
		id: popup
		anchor.item: button
		anchor.adjustment: PopupAdjustment.None
		/* anchor.rect.x: -10 */
		color: "transparent"

		anchor.margins.top: -root.blurWidth
		anchor.margins.right: -root.blurWidth
		anchor.margins.bottom: -root.blurWidth
		anchor.margins.left: -root.blurWidth

		implicitWidth: launcher.implicitWidth
		implicitHeight: launcher.implicitHeight

		// TODO
		/* HyprlandFocusGrab { */
		/* 	active: popup.visible */
		/* 	windows: [ popup ] */
		/* 	onCleared: popup.visible = false */
		/* } */

		Item {
			id: myitem

			anchors.fill: parent
			anchors.margins: root.blurWidth

			RectangularShadow {
				anchors.fill: bod
				blur: root.blurWidth
				spread: 0
				offset: Qt.vector2d(0, 3)
			}

			Rectangle {
				id: bod
				color: C.surfaceVariant
				radius: C.radius
				clip: true
				anchors.fill: parent

				Ripple {
					id: ripple
					enabled: false
				}
			}

			Launcher {
				id: launcher
			}

			transform: Scale {
				id: scale
			}

			ParallelAnimation {
				id: popupAnimation
				OpacityAnimator {
					target: bod
					from: 0
					to: 1
					duration: C.duration.medium
					easing.type: Easing.BezierSpline
					easing.bezierCurve: C.easing.emphasizedDecel
				}
				NumberAnimation {
					target: scale
					property: "xScale"
					from: 0
					to: 1
					duration: C.duration.medium
					easing.type: Easing.BezierSpline
					easing.bezierCurve: C.easing.emphasizedDecel
				}
			}
		}
	}

	Rectangle {
		anchors.fill: bar
		color: C.surface

		MouseArea {
			anchors.fill: parent

			onClicked: event => {
				popup.visible = !popup.visible
				popupAnimation.restart()
				let p = ripple.mapFromItem(bar, event.x, event.y)
				ripple.play(p.x, p.y)
				myitem.forceActiveFocus()
			}
		}
	}

	ColumnLayout {
		id: bar
		anchors.top: parent.top
		anchors.bottom: parent.bottom
		anchors.left: parent.left
		width: C.barWidth

		focus: popup.visible
		Keys.onPressed: event => {
			console.log(event);
			if (event.key === Qt.Key_Escape)
				popup.visible = false;
			/* bar.focus = false; */
			/* root.visible = false */
			/* root.visible = true */
			root.WlrLayershell.keyboardFocus = WlrKeyboardFocus.None
		}

		Rectangle {
			id: button
			/* Layout.fillWidth: true */
			implicitWidth: 26
			implicitHeight: 26
			radius: C.radius
			color: C._onSurface
			Layout.alignment: Qt.AlignHCenter
			Layout.topMargin: C.spacing.small

			Image {
				anchors.fill: parent
				anchors.margins: 2
				source: Quickshell.iconPath("nix-snowflake")
				sourceSize.width: 2 * width
				sourceSize.height: 2 * width
			}
		}

		Item {
			Layout.fillHeight: true
		}

		SysTray {
			Layout.alignment: Qt.AlignHCenter
		}

		BatteryIcon {
			device: UPower.displayDevice
			Layout.alignment: Qt.AlignHCenter
		}

		Text {
			text: Qt.formatDateTime(Time.date, "hh\nmm")
			lineHeight: 0.8
			Layout.alignment: Qt.AlignHCenter
			Layout.bottomMargin: C.spacing.small
			font.pixelSize: C.fontSmall
			color: C._onSurface
		}
	}
}
