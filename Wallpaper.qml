import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
	WlrLayershell.layer: WlrLayer.Background
	WlrLayershell.namespace: "wallpaper"
	exclusionMode: ExclusionMode.Ignore

	anchors {
		top: true
		right: true
		bottom: true
		left: true
	}

	Image {
		fillMode: Image.PreserveAspectCrop
		source: "/home/axel/Pictures/dlw56yjfrvwd1.jpg"
		asynchronous: true
		retainWhileLoading: true

		sourceSize.width: width
		sourceSize.height: width

		anchors.fill: parent
	}
}
