import QtQuick
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

		width: parent?.width
		height: body.y + body.height + C.spacing.normal

		MouseArea {
			property double start: 0
			anchors.fill: parent
			drag.axis: Drag.XAxis
			drag.target: notif
			drag.minimumX: 0
			hoverEnabled: true
			onEntered: notif.timer.stop()
			onClicked: NotificationManager.dismiss(notif.index)
			onPressed: mouse => start = mouse.x
			onReleased: mouse => {
				if (drag.active)
					NotificationManager.dismiss(notif.index);
			}
		}

		Ripple {
			clip: true
		}

		Image {
			id: icon
			asynchronous: true
			source: notif.image
			sourceSize.width: width
			sourceSize.height: height
			x: C.spacing.normal
			y: C.spacing.normal
			width: 40
			height: width
		}

		Text {
			id: summary
			textFormat: Text.PlainText
			text: notif.summary
			elide: Text.ElideRight
			font.bold: true
			font.pixelSize: C.fontSmall
			color: C._onSurface
			y: C.spacing.normal
			anchors.left: icon.right
			anchors.leftMargin: C.spacing.normal
			width: parent.width - x - C.spacing.normal
		}

		Text {
			id: body
			textFormat: Text.MarkdownText
			text: notif.body
			wrapMode: Text.WrapAtWordBoundaryOrAnywhere
			font.pixelSize: C.fontTiny
			color: C._onSurface
			anchors {
				top: summary.bottom
				right: parent.right
				left: summary.left
				topMargin: C.spacing.small
				rightMargin: C.spacing.normal
			}
		}
	}

	ListView {
		id: list
		/* verticalLayoutDirection: ListView.BottomToTop */
		model: NotificationManager.notifications
		delegate: NotificationWidget {}

		anchors.fill: parent
		anchors.margins: C.spacing.normal
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
