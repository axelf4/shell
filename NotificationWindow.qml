import QtQuick
import QtQuick.Layouts
import Quickshell

PanelWindow {
	// TODO screen: Quickshell.primaryScreen
	exclusionMode: ExclusionMode.Ignore
	/* WlrLayershell.layer: WlrLayer.Overlay */
	color: "transparent"

	implicitWidth: 300
	anchors {
		top: true
		right: true
		bottom: true
	}
	mask: Region {
		item: list.contentItem
	}

	component NotificationWidget: Rectangle {
		id: notif
		required property int index
		required property Timer timer
		required property string image
		required property string summary
		required property string body
		radius: 8
		color: m3surfaceContainer

		readonly property color m3surfaceContainer: "#231E23"

		width: parent?.width
		implicitHeight: content.implicitHeight

		MouseArea {
			property double start: 0
			anchors.fill: parent
			acceptedButtons: Qt.LeftButton
			drag.axis: Drag.XAxis
			drag.target: notif
			drag.minimumX: 0
			onEntered: notif.timer.stop()
			onClicked: NotificationManager.dismiss(notif.index)
			onPressed: mouse => start = mouse.x
			onReleased: mouse => {
				if (drag.active)
					NotificationManager.dismiss(notif.index);
			}
		}

		GridLayout {
			id: content
			columns: 2
			readonly property double margin: 10

			Image {
				readonly property int size: 45

				asynchronous: true
				source: notif.image
				sourceSize.width: size
				sourceSize.height: size

				Layout.rowSpan: 2
				Layout.alignment: Qt.AlignTop
				Layout.margins: content.margin
				Layout.preferredWidth: size
				Layout.preferredHeight: size
			}

			Text {
				Layout.preferredWidth: 0.75 * notif.width
				Layout.topMargin: content.margin
				text: notif.summary
				elide: Text.ElideRight
				font.bold: true
				color: "#ffffff"
			}

			Text {
				Layout.preferredWidth: 0.75 * notif.width
				Layout.bottomMargin: content.margin
				Layout.rightMargin: content.margin
				textFormat: Text.MarkdownText
				text: notif.body
				wrapMode: Text.WrapAtWordBoundaryOrAnywhere
				color: "#ffffff"
			}
		}
	}

	ListView {
		id: list
		/* verticalLayoutDirection: ListView.BottomToTop */
		model: NotificationManager.notifications
		delegate: NotificationWidget {}

		anchors.fill: parent
		anchors.topMargin: 10
		anchors.rightMargin: 10
		anchors.bottomMargin: 10
		implicitWidth: contentItem.childrenRect.width
		spacing: 10

		add: Transition {
			NumberAnimation {
				properties: "opacity,scale"
				from: 0
				to: 1.0
				duration: 400
			}
			NumberAnimation {
				property: "x"
				from: list.width
				duration: 400
			}
		}

		remove: Transition {
			NumberAnimation {
				properties: "opacity"
				from: 1
				to: 0
				duration: 400
				easing.type: Easing.OutQuad
			}
			NumberAnimation {
				property: "x"
				to: list.width
				duration: 400
				easing.type: Easing.OutQuad
			}
		}

		displaced: Transition {
			id: dispTrans
			SequentialAnimation {
				PauseAnimation {
					duration: (dispTrans.ViewTransition.index - dispTrans.ViewTransition.targetIndexes[0]) * 100
				}
				NumberAnimation {
					properties: "x,y"
					duration: 500
					easing.type: Easing.OutBounce
				}
			}
		}
	}
}
