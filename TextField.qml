import QtQuick
import QtQuick.Templates as T

T.TextField {
	id: control
	property alias backgroundColor: background.color
	padding: C.spacing.normal
	implicitWidth: contentWidth + leftPadding + rightPadding
	implicitHeight: contentHeight + topPadding + bottomPadding
	background: Rectangle {
		id: background
		color: C.surfaceContainerHighest
		radius: C.radius
	}
	color: C._onSurface
	placeholderTextColor: C.primary
	font.pixelSize: C.fontMedium

	Text {
		text: control.placeholderText
		color: control.placeholderTextColor
		elide: Text.ElideRight
		font: control.font
		verticalAlignment: Text.AlignVCenter
		visible: !control.length
		anchors {
			fill: parent
			topMargin: control.topPadding
			rightMargin: control.rightPadding
			bottomMargin: control.bottomPadding
			leftMargin: control.leftPadding
		}
	}
}
