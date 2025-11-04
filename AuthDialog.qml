import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Polkit

FloatingWindow {
	id: root
	title: "Authentication Required"
	visible: agent.isActive
	color: C.surfaceContainer
	implicitWidth: 500
	implicitHeight: 300

	PolkitAgent {
		id: agent
	}

	Shortcut {
		sequences: [StandardKey.Cancel]
		onActivated: agent.flow?.cancelAuthenticationRequest()
	}

	ColumnLayout {
		anchors.fill: parent
		anchors.margins: C.spacing.large
		spacing: C.spacing.normal

		Text {
			text: agent.flow?.message ?? ""
			wrapMode: Text.WordWrap
			font.pixelSize: C.fontLarge
			color: C._onSurface
			Layout.fillWidth: true
		}

		Text {
			text: agent.flow?.supplementaryMessage ?? ""
			wrapMode: Text.WordWrap
			font.pixelSize: C.fontMedium
			color: agent.flow?.supplementaryIsError ? C.error : C._onSurface
			Layout.fillWidth: true
		}

		TextField {
			id: response
			placeholderText: agent.flow?.inputPrompt ?? ""
			echoMode: agent.flow?.responseVisible ? TextInput.Normal : TextInput.Password
			visible: agent.flow?.isResponseRequired ?? false
			focus: true
			Layout.fillWidth: true

			onAccepted: agent.flow?.submit(text)
		}

		Item {
			Layout.fillHeight: true
		} // Spacer

		RowLayout {
			spacing: C.spacing.small
			Layout.alignment: Qt.AlignRight
			Layout.fillWidth: true

			Button {
				text: "Cancel"
				onClicked: agent.flow?.cancelAuthenticationRequest()
			}

			Button {
				text: "Submit"
				enabled: !!agent.flow?.isResponseRequired
				onClicked: agent.flow?.submit(response.text)
			}
		}
	}

	Connections {
		target: agent.flow
		function onIsResponseRequiredChanged(): void {
			response.clear();
			if (agent.flow.isResponseRequired)
				response.forceActiveFocus();
		}
	}
}
