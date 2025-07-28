import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray

Column {
	component TrayItem: MouseArea {
		id: item
		required property SystemTrayItem modelData

		acceptedButtons: Qt.LeftButton | Qt.RightButton
		onClicked: event => {
			switch (event.button) {
			case Qt.LeftButton: modelData.activate(); break;
			case Qt.RightButton: if (modelData.hasMenu) menu.open(); break;
			}
			event.accepted = true;
		}

		QsMenuAnchor {
			id: menu
			menu: item.modelData.menu
			anchor.item: item
			anchor.edges: Edges.Top | Edges.Right
		}

		implicitWidth: 20
		implicitHeight: 20

		IconImage {
			source: {
				let icon = item.modelData.icon;
				if (icon.includes("?path=")) {
					const [name, path] = icon.split("?path=");
					icon = `file://${path}/${name.slice(name.lastIndexOf("/") + 1)}`;
				}
				icon;
			}
			asynchronous: true
			anchors.fill: parent
		}
	}

	Repeater {
		model: SystemTray.items
		TrayItem {}
	}

	add: Transition {
        NumberAnimation {
            properties: "scale"
            from: 0
            to: 1
			duration: 500
			easing.type: Easing.OutBounce 
        }
    }
}
