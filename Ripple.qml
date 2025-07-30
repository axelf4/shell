import QtQuick

MouseArea {
	id: root
	property color color: C._onSurfaceVariant

	propagateComposedEvents: true
	acceptedButtons: Qt.LeftButton
	anchors.fill: parent

	function play(x: int, y: int): void {
		translation.x = x - ripple.width / 2;
		translation.y = y - ripple.height / 2;
		animation.restart();
	}

	onPressed: event => play(event.x, event.y)
	
	Rectangle {
		readonly property int duration: 1200
		id: ripple
		width: Math.max(parent.width, parent.height)
		height: width
		radius: 9999
		opacity: 0
		color: root.color

		transform: Translate {
			id: translation
		}

		ParallelAnimation {
			id: animation
			OpacityAnimator {
				target: ripple
				from: 1
				to: 0
				duration: ripple.duration
				easing.type: Easing.BezierSpline
				easing.bezierCurve: C.easing.emphasizedDecel
			}
			NumberAnimation {
				target: ripple
				property: "scale"
				from: 0
				to: 2.5
				duration: ripple.duration
				easing.type: Easing.BezierSpline
				easing.bezierCurve: C.easing.emphasizedDecel
			}
		}
	}
}
