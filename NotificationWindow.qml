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
		radius: C.radius
		color: C.surface
		clip: true

		width: parent?.width
		implicitHeight: content.implicitHeight

		MouseArea {
			property double start: 0
			anchors.fill: parent
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

		Ripple {}

		GridLayout {
			id: content
			columns: 2
			columnSpacing: C.spacing.small
			rowSpacing: C.spacing.normal

			Image {
				readonly property int size: 40

				asynchronous: true
				source: notif.image
				sourceSize.width: size
				sourceSize.height: size

				Layout.rowSpan: 2
				Layout.alignment: Qt.AlignTop
				Layout.margins: C.spacing.normal
				Layout.preferredWidth: size
				Layout.preferredHeight: size
			}

			Text {
				Layout.preferredWidth: 0.7 * notif.width
				Layout.topMargin: C.spacing.normal
				text: notif.summary
				textFormat: Text.PlainText
				elide: Text.ElideRight
				font.bold: true
				font.pixelSize: C.fontSmall
				color: C._onSurface
			}

			Text {
				Layout.preferredWidth: 0.7 * notif.width
				Layout.bottomMargin: C.spacing.normal
				Layout.rightMargin: C.spacing.normal
				textFormat: Text.MarkdownText
				text: notif.body
				wrapMode: Text.WrapAtWordBoundaryOrAnywhere
				font.pixelSize: C.fontTiny
				color: C._onSurface
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
		spacing: C.spacing.normal

		add: Transition {
			NumberAnimation {
				properties: "opacity,scale"
				from: 0
				duration: C.duration.medium
				easing.type: Easing.BezierSpline
				easing.bezierCurve: C.easing.emphasizedDecel
			}
			XAnimator {
				from: list.width
				duration: C.duration.medium
				easing.type: Easing.BezierSpline
				easing.bezierCurve: C.easing.emphasizedDecel
			}
		}

		remove: Transition {
			OpacityAnimator {
				to: 0
				duration: C.duration._short
				easing.type: Easing.BezierSpline
				easing.bezierCurve: C.easing.emphasizedAccel
			}
			XAnimator {
				to: list.width
				duration: C.duration._short
				easing.type: Easing.BezierSpline
				easing.bezierCurve: C.easing.emphasizedAccel
			}
		}

		displaced: Transition {
			id: dispTrans
			SequentialAnimation {
				PauseAnimation {
					duration: 100 * (dispTrans.ViewTransition.index - dispTrans.ViewTransition.targetIndexes[0])
				}
				NumberAnimation {
					properties: "x,y"
					duration: C.duration.medium2
					easing.type: Easing.BezierSpline
					easing.bezierCurve: C.easing.standard
				}
			}
		}
	}
}
