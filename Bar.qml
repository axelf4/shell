import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Services.UPower

PanelWindow {
	id: root
	required property ShellScreen screen
	readonly property int barWidth: 35
	readonly property int blurWidth: 15

	anchors {
		left: true
		top: true
		bottom: true
	}
	mask: Region {
		item: bar
	}

	implicitWidth: barWidth + blurWidth
	exclusiveZone: barWidth
	color: "transparent"

	RectangularShadow {
		anchors.fill: bar
		blur: 10
		spread: 4
		cached: true
	}

	Rectangle {
		anchors.fill: bar
		color: "#c0d0f0"
	}

	ColumnLayout {
		id: bar
		anchors.fill: parent
		anchors.rightMargin: root.blurWidth

		Text {
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
			lineHeight: 0.75
			Layout.alignment: Qt.AlignHCenter
		}
	}
}
