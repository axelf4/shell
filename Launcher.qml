import QtQuick
import QtQuick.Controls
import Quickshell

FocusScope {
	width: 500
	height: 400

	TextField {
		id: input
		focus: true
		anchors.top: parent.top
		anchors.right: parent.right
		anchors.left: parent.left
		anchors.margins: C.spacing.large
		padding: C.spacing.normal

		placeholderText: "Enter Application"
		placeholderTextColor: C.primary
		background: Rectangle {
			color: C.surfaceContainerHighest
			radius: 4
		}
		color: C._onSurface
		font.pixelSize: C.fontMedium

		onAccepted: {
			if (!list.currentItem)
				return;
			list.currentItem.modelData.execute();
			clear();
		}
		Keys.onPressed: event => {
			if (event.key === Qt.Key_Backspace && text === "") {
				console.log("exit...");
			}
		}
		Keys.forwardTo: [list]
	}

	component AppDelegate: Item {
		id: app
		readonly property int iconSize: 32
		required property int index
		required property DesktopEntry modelData
		width: parent.width
		height: iconSize + C.spacing.small

		Image {
			source: Quickshell.iconPath(app.modelData.icon)
			sourceSize.width: app.iconSize
			sourceSize.height: app.iconSize
			asynchronous: true
			x: C.spacing.small
			anchors.verticalCenter: parent.verticalCenter
		}

		Text {
			anchors.fill: parent
			anchors.leftMargin: app.iconSize + 2 * C.spacing.small
			text: app.modelData.name
			textFormat: Text.PlainText
			verticalAlignment: Text.AlignVCenter
			font.bold: app.ListView.isCurrentItem
			font.pixelSize: C.fontMedium
			color: C._onSurface
		}

		MouseArea {
			anchors.fill: parent
			hoverEnabled: true
			/* onEntered: list.currentIndex = app.index */
			onClicked: app.modelData.execute()
		}
	}

	ListView {
		id: list
		model: ScriptModel {
			values: {
				const needle = input.text.toLowerCase();
				DesktopEntries.applications.values.filter(app => !app.noDisplay && app.name.toLowerCase().startsWith(needle)).sort((a, b) => a.name.length - b.name.length);
			}
			onValuesChanged: list.currentIndex = 0
		}
		delegate: AppDelegate {}
		highlight: Rectangle {
			color: C.surfaceVariant
		}
		reuseItems: true
		clip: true

		anchors.top: input.bottom
		anchors.right: parent.right
		anchors.bottom: parent.bottom
		anchors.left: parent.left
		anchors.topMargin: C.spacing.large
		spacing: 0
	}
}
