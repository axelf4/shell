import QtQuick

MouseArea {
	property alias color: ripple.color
	propagateComposedEvents: true
	acceptedButtons: Qt.LeftButton
	anchors.fill: parent

	function play(x: int, y: int): void {
		ripple.x = x - ripple.width / 2;
		ripple.y = y - ripple.height / 2;
		animation.restart();
	}

	onPressed: event => play(event.x, event.y)

	Rectangle {
		id: ripple
		width: Math.max(parent.width, parent.height)
		height: width
		radius: 9999
		opacity: 0
		color: C._onSurfaceVariant

		ParallelAnimation {
			id: animation
			readonly property int duration: 1200
			OpacityAnimator {
				target: ripple
				from: 1
				duration: animation.duration
				easing.type: Easing.BezierSpline
				easing.bezierCurve: C.easing.emphasizedDecel
			}
			ScaleAnimator {
				target: ripple
				from: 0
				to: 2.5
				duration: animation.duration
				easing.type: Easing.BezierSpline
				easing.bezierCurve: C.easing.emphasizedDecel
			}
		}
	}
}
