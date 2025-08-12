import QtQuick
import Quickshell.Bluetooth

Item {
	width: 300
	height: 350

	Text {
		textFormat: Text.PlainText
		text: Bluetooth.defaultAdapter.enabled ? "On" : "Off"
		x: C.spacing.normal
		anchors.verticalCenter: onSwitch.verticalCenter
		font.pixelSize: C.fontMedium
		color: C._onSurface
	}
	Switch {
		id: onSwitch
		checked: Bluetooth.defaultAdapter.enabled
		onClicked: Bluetooth.defaultAdapter.enabled = checked
		anchors.top: parent.top
		anchors.right: parent.right
		anchors.margins: C.spacing.normal
	}

	Text {
		textFormat: Text.PlainText
		text: "Discover"
		x: C.spacing.normal
		anchors.verticalCenter: discoverSwitch.verticalCenter
		font.pixelSize: C.fontMedium
		color: C._onSurface
	}
	Switch {
		id: discoverSwitch
		checked: Bluetooth.defaultAdapter.discovering
		onClicked: Bluetooth.defaultAdapter.discovering = checked
		anchors.top: onSwitch.bottom
		anchors.right: parent.right
		anchors.margins: C.spacing.normal
	}

	Text {
		id: heading
		textFormat: Text.PlainText
		text: "Devices"
		color: C.primary
		font.capitalization: Font.AllUppercase
		font.pixelSize: C.fontSmall
		x: C.spacing.normal
		anchors.top: discoverSwitch.bottom
		anchors.topMargin: C.spacing.large
	}

	ListView {
		model: Bluetooth.devices
		delegate: Item {
			id: node
			required property BluetoothDevice modelData
			width: parent.width
			height: status.y + status.height + C.spacing.small / 2

			Ripple {
				clip: true
				cursorShape: Qt.PointingHandCursor
				onClicked: {
					if (node.modelData.connected)
						node.modelData.disconnect();
					else
						node.modelData.connect();
				}
			}

			Text {
				id: name
				textFormat: Text.PlainText
				text: node.modelData.name
				verticalAlignment: Text.AlignVCenter
				font.pixelSize: C.fontMedium
				color: C._onSurface
				x: C.spacing.normal
				y: C.spacing.small / 2
				height: contentHeight + (status.visible ? 0 : status.contentHeight)
			}
			Text {
				id: status
				visible: node.modelData.state !== BluetoothDeviceState.Disconnected
				textFormat: Text.PlainText
				text: switch (node.modelData.state) {
				case BluetoothDeviceState.Connected:
					return "Connected";
				case BluetoothDeviceState.Disconnecting:
					return "Disconnecting";
				case BluetoothDeviceState.Disconnected:
					return "Disconnected";
				case BluetoothDeviceState.Connecting:
					return "Connecting";
				}
				font.pixelSize: C.fontSmall
				color: C.primary
				x: C.spacing.normal
				y: name.contentHeight
			}
		}
		clip: true
		anchors {
			top: heading.bottom
			right: parent.right
			bottom: parent.bottom
			left: parent.left
		}
	}
}
