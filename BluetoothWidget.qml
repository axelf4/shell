import QtQuick
import Quickshell.Bluetooth

Item {
	width: 300
	height: 350

	Text {
		textFormat: Text.PlainText
		text: Bluetooth.defaultAdapter.enabled ? "On" : "Off"
		anchors.left: parent.left
		anchors.margins: C.spacing.normal
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
		anchors.left: parent.left
		anchors.margins: C.spacing.normal
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
		font.pixelSize: C.fontSmall
		anchors.top: discoverSwitch.bottom
		anchors.left: parent.left
		anchors.topMargin: C.spacing.large
		anchors.leftMargin: C.spacing.normal
	}

	ListView {
		model: Bluetooth.devices
		delegate: Item {
			id: node
			required property BluetoothDevice modelData
			height: 48
			anchors.right: parent.right
			anchors.left: parent.left

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

			Item {
				x: C.spacing.normal
				anchors.verticalCenter: parent.verticalCenter
				height: childrenRect.height
				Text {
					id: name
					text: node.modelData.name
					font.pixelSize: C.fontMedium
					color: C._onSurface
				}
				Text {
					id: status
					visible: node.modelData.state != BluetoothDeviceState.Disconnected
					height: visible ? contentHeight : 0
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
					anchors.top: name.bottom
					anchors.left: name.left
				}
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
