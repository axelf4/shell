import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Services.UPower

PanelWindow {
	id: root
	readonly property int blurWidth: 15

	anchors {
		left: true
		top: true
		bottom: true
	}
	mask: Region {
		item: bar
	}

	implicitWidth: C.barWidth + blurWidth
	exclusiveZone: C.barWidth
	color: "transparent"

	RectangularShadow {
		anchors.fill: bar
		blur: 10
		spread: 4
		cached: true
	}

	Rectangle {
		anchors.fill: bar
		color: C.surface
	}

	ColumnLayout {
		id: bar
		anchors.fill: parent
		anchors.rightMargin: root.blurWidth

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
