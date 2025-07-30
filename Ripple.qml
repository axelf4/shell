import QtQuick

MouseArea {
	id: root
	property color color: C._onSurfaceVariant

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
		readonly property int duration: 1200
		width: Math.max(parent.width, parent.height)
		height: width
		radius: 9999
		opacity: 0
		color: root.color

		ParallelAnimation {
			id: animation
			OpacityAnimator {
				target: ripple
				from: 1
				duration: ripple.duration
				easing.type: Easing.BezierSpline
				easing.bezierCurve: C.easing.emphasizedDecel
			}
			ScaleAnimator {
				target: ripple
				from: 0
				to: 2.5
				duration: ripple.duration
				easing.type: Easing.BezierSpline
				easing.bezierCurve: C.easing.emphasizedDecel
			}
		}
	}
}
