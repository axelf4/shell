pragma Singleton

import QtQuick
import Quickshell

Singleton {
    component Easing: QtObject {
        readonly property list<real> emphasized: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82, 0.25, 1, 1, 1]
        readonly property list<real> emphasizedAccel: [0.3, 0, 0.8, 0.15, 1, 1]
        readonly property list<real> emphasizedDecel: [0.05, 0.7, 0.1, 1, 1, 1]
        readonly property list<real> standard: [0.2, 0, 0, 1, 1, 1]
        readonly property list<real> standardAccel: [0.3, 0, 1, 1, 1, 1]
        readonly property list<real> standardDecel: [0, 0, 0, 1, 1, 1]
    }

	component Duration: QtObject {
        readonly property int _short: 200
		readonly property int medium2: 300
		readonly property int medium: 400
		readonly property int _long: 600
	}

	readonly property Easing easing: Easing {}
	readonly property Duration duration: Duration {}

    component Spacing: QtObject {
        readonly property int small: 7
        readonly property int normal: 12
        readonly property int large: 20
    }

	readonly property Spacing spacing: Spacing {}

	component Palette: QtObject {
        readonly property color primary20: "#381E72"
        readonly property color primary30: "#4F378B"
        readonly property color primary80: "#D0BCFF"
        readonly property color primary90: "#EADDFF"
        readonly property color neutral6: "#141218"
        readonly property color neutral12: "#211F26"
        readonly property color neutral22: "#36343B"
        readonly property color neutral90: "#E6E0E9"
        readonly property color neutralVariant30: "#49454F"
        readonly property color neutralVariant60: "#938F99"
        readonly property color neutralVariant80: "#CAC4D0"
        readonly property color error80: "#F2B8B5"
        readonly property color green80: "#80DA88"
	}

	readonly property Palette palette: Palette {}

	readonly property color primary: palette.primary80
	readonly property color _onPrimary: palette.primary20
	readonly property color primaryContainer: palette.primary30
	readonly property color _onPrimaryContainer: palette.primary90
	readonly property color error: palette.error80
	readonly property color surface: palette.neutral6
	readonly property color _onSurface: palette.neutral90
	readonly property color surfaceVariant: palette.neutralVariant30
	readonly property color _onSurfaceVariant: palette.neutralVariant80
	readonly property color surfaceContainer: palette.neutral12
	readonly property color surfaceContainerHighest: palette.neutral22
	readonly property color outline: palette.neutralVariant60

	readonly property int fontTiny: 10
	readonly property int fontSmall: 13
	readonly property int fontMedium: 16
	readonly property int fontLarge: 24

	readonly property int radius: 8
	readonly property int radiusFull: 2147483647

	readonly property int barWidth: 32
}
