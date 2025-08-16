import QtQuick
import QtQuick.Templates as T

T.Switch {
	id: control
	implicitWidth: implicitBackgroundWidth
	implicitHeight: implicitBackgroundHeight

	// Track
	background: Rectangle {
		implicitWidth: 52
		implicitHeight: 32
		radius: C.radiusFull
		border {
			color: control.checked ? color : control.enabled ? C.outline : C._onSurface
			width: 2
		}
		color: control.checked ? (control.enabled ? C.primary : C._onSurface) //
		: C.surfaceContainerHighest
		opacity: control.enabled ? 1 : 0.12

		Behavior on color {
			ColorAnimation {
				duration: 67
			}
		}
	}

	// Ripple/state layer
	Rectangle {
		width: 40
		height: 40
		radius: C.radiusFull
		color: C.primary
		visible: control.enabled && control.hovered
		opacity: control.down ? 0.12 : 0.08
		anchors.centerIn: control.indicator
	}

	// Handle
	indicator: Rectangle {
		x: y + control.visualPosition * (parent.width - 2 * y - width)
		anchors.verticalCenter: parent.verticalCenter
		width: 28
		height: 28
		radius: C.radiusFull
		scale: (control.down ? 28 : control.checked ? 24 : 16) / width
		color: control.enabled ? (control.hovered //
			? (control.checked ? C.primaryContainer : C._onSurfaceVariant) //
			: (control.checked ? C._onPrimary : C.outline)) //
		: (control.checked ? C.surface : C._onSurface)
		opacity: control.enabled || control.checked ? 1 : 0.38

		Behavior on x {
			NumberAnimation {
				duration: C.duration.medium2
				easing.type: Easing.BezierSpline
				easing.bezierCurve: [0.175, 0.885, 0.32, 1.275, 1, 1]
			}
		}
		Behavior on scale {
			NumberAnimation {
				duration: C.duration._short
				easing.type: Easing.BezierSpline
				easing.bezierCurve: C.easing.standard
			}
		}
		Behavior on color {
			ColorAnimation {
				duration: 67
			}
		}
	}
}
