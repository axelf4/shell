import QtQuick
import QtQuick.Templates as T

T.Slider {
	id: control
	readonly property int handlePadding: 6
	implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitHandleWidth + leftPadding + rightPadding)
	implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset, implicitHandleHeight + topPadding + bottomPadding)

	// Track
	background: Item {
		x: control.leftPadding
		y: control.topPadding + (control.availableHeight - height) / 2
		implicitWidth: 200
		implicitHeight: 8
		width: control.availableWidth
		height: implicitHeight

		Rectangle {
			width: control.visualPosition * parent.width - (handle.width / 2 + control.handlePadding)
			height: parent.height
			radius: C.radiusFull
			topRightRadius: 2
			bottomRightRadius: 2
			color: C.primary
		}
		Rectangle {
			anchors.right: parent.right
			width: parent.width - control.visualPosition * parent.width - (handle.width / 2 + control.handlePadding)
			height: parent.height
			radius: C.radiusFull
			color: C.secondaryContainer
			topLeftRadius: 2
			bottomLeftRadius: 2
		}
	}

	handle: Rectangle {
		id: handle
		x: control.leftPadding + control.visualPosition * control.availableWidth - width / 2
		y: control.topPadding + (control.availableHeight - height) / 2
		implicitWidth: control.pressed ? 2 : 4
		implicitHeight: 28
		radius: C.radiusFull
		color: C.primary
	}
}
