import QtQuick
import QtQuick.Templates as T

T.Button {
	id: control
	implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, implicitContentWidth + leftPadding + rightPadding)
	implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset, implicitContentHeight + topPadding + bottomPadding)
	leftPadding: 12
	rightPadding: 12

	background: Rectangle {
        implicitHeight: 32
        radius: C.radiusFull
        opacity: enabled ? 1 : 0.1
		color: {
			let base = C.primary, stateLayer = C._onPrimary;
			let a = control.pressed ? 0.18 : control.hovered ? 0.08 : 0;
			let tint = Qt.rgba(stateLayer.r, stateLayer.g, stateLayer.b, a);
			enabled ? Qt.tint(base, tint) : C._onSurface;
		}
    }

	contentItem: Text {
        text: control.text
        font: control.font
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        opacity: enabled ? 1 : 0.38
        color: enabled ? C._onPrimary : C._onSurface
    }
}
