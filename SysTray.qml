import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray

Column {
	component TrayItem: MouseArea {
		id: item
		required property SystemTrayItem modelData

		acceptedButtons: Qt.LeftButton | Qt.RightButton
		cursorShape: Qt.PointingHandCursor
		width: 20
		height: width

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

		IconImage {
			id: icon
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

			layer.enabled: true
			layer.effect: MultiEffect {
				saturation: -0.75
			}
		}
	}

	Repeater {
		model: SystemTray.items
		TrayItem {}
	}

	add: Transition {
        NumberAnimation {
            properties: "opacity,scale"
            from: 0
			to: 1
			duration: C.duration.medium
			easing.type: Easing.BezierSpline
			easing.bezierCurve: C.easing.emphasizedDecel
        }
    }

	move: Transition {
        NumberAnimation {
            properties: "x,y"
			duration: C.duration.medium2
			easing.type: Easing.BezierSpline
			easing.bezierCurve: C.easing.standard
        }
    }
}
