import QtQuick
import Quickshell.Services.UPower

Image {
	property UPowerDevice device: UPower.displayDevice

	visible: device.isLaptopBattery
	fillMode: Image.PreserveAspectFit
	retainWhileLoading: true
	source: {
		let isCharging = false;
		switch (device.state) {
		case UPowerDeviceState.Charging:
		case UPowerDeviceState.PendingCharge:
		case UPowerDeviceState.FullyCharged:
			isCharging = true;
			break;
		}

		const isLow = device.percentage <= 0.20, min = 0, max = 17, w = min + (max - min) * device.percentage;
		const color = isCharging ? C.palette.green80 : isLow ? C.error : C._onSurface;
		const svg = `<svg viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
	<path fill="${color}" d="M5 9v12h21v-3c0.5 0 1-0.4 2-1v-4s-0.4-1-2-1v-3zm1 1h19v10h-19zm1 1v8h${w}l-2-8z" />
</svg>`;

		`data:image/svg+xml;base64,${Qt.btoa(svg)}`;
	}
	sourceSize.width: width
	sourceSize.height: height
}
