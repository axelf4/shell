import QtQuick
import QtQuick.Controls
import Quickshell.Services.UPower

Image {
	required property UPowerDevice device

	visible: device.isLaptopBattery
	fillMode: Image.PreserveAspectFit
	retainWhileLoading: true
	source: {
		let isCharging;
		switch (device.state) {
		case UPowerDeviceState.Charging:
		case UPowerDeviceState.PendingCharge:
		case UPowerDeviceState.FullyCharged:
			isCharging = true;
			break;
		default:
			isCharging = false;
			break;
		}

		const isLow = device.percentage <= 0.20, min = 0, max = 17, w = min + (max - min) * device.percentage;
		const color = isCharging ? C.palette.green80 : isLow ? C.error : C._onSurface;
		const svg = `<?xml version="1.0" encoding="UTF-8"?>
<svg viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
	<path d="m5 10v12h21v-3c0.5 0 1-0.4 2-1v-4s-0.4-1-2-1v-3zm1 1h19v10h-19zm1 1v8h${w}l-2-8z" fill="${color}" />
</svg>`;

		`data:image/svg+xml;base64,${Qt.btoa(svg)}`;
	}
	sourceSize.width: width
	sourceSize.height: height
}
