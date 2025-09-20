pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls as Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Pipewire

Item {
	id: root
	width: 300
	height: 350

	component TabButton: T.TabButton {
		id: control
		implicitWidth: implicitContentWidth + leftPadding + rightPadding
		implicitHeight: implicitContentHeight + topPadding + bottomPadding
		background: Ripple {
			id: ripple
			clip: true
		}
		contentItem: Text {
			textFormat: Text.PlainText
			text: control.text
			color: control.checked ? C._onSurface : C._onSurfaceVariant
			font.pixelSize: C.fontMedium
			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter
			padding: C.spacing.normal
		}
		onPressed: ripple.play(control.pressX, control.pressY)
	}

	component TabBar: T.TabBar {
		id: control2
		implicitWidth: contentWidth + leftPadding + rightPadding
		implicitHeight: contentHeight + topPadding + bottomPadding

		background: Rectangle {
			height: 1
			color: C.outlineVariant
		}

		contentItem: ListView {
			model: control2.contentModel
			currentIndex: control2.currentIndex
			orientation: ListView.Horizontal
			flickableDirection: Flickable.AutoFlickIfNeeded
			snapMode: ListView.SnapToItem
			highlightMoveDuration: C.duration._short
			highlightResizeDuration: 0
			highlightFollowsCurrentItem: true
			highlight: Item {
				Rectangle {
					y: control2.position === T.TabBar.Footer ? 0 : parent.height - height
					width: parent.width
					height: 2
					color: C.primary
				}
			}
		}
	}

	function nodeName(n: PwNode): string {
		return n ? n.nickname || n.description || n.name : "";
	}

	Controls.SwipeView {
		id: view
		currentIndex: bar.currentIndex
		clip: true
		width: parent.width
		height: bar.y
		topPadding: C.spacing.normal

		ListView {
			model: Pipewire.nodes
			delegate: Item {
				id: node
				required property PwNode modelData
				visible: modelData.isSink && !modelData.isStream
				implicitHeight: childrenRect.height
				width: parent.width
				height: visible ? implicitHeight + C.spacing.normal : 0

				PwObjectTracker {
					objects: [node.modelData]
				}

				Text {
					id: name
					textFormat: Text.PlainText
					text: root.nodeName(node.modelData)
					elide: Text.ElideRight
					font.pixelSize: C.fontMedium
					color: C._onSurface
					anchors.left: parent.left
					anchors.right: parent.right
					anchors.margins: C.spacing.normal
				}

				Slider {
					value: node.modelData.audio?.volume ?? 0
					onMoved: node.modelData.audio.volume = value
					anchors {
						top: name.bottom
						left: name.left
						right: name.right
						topMargin: C.spacing.small
					}
				}
			}
		}

		ListView {
			model: Pipewire.nodes
			delegate: Item {
				id: node
				required property PwNode modelData
				visible: modelData.isStream && modelData.audio
				implicitHeight: childrenRect.height
				width: parent.width
				height: visible ? implicitHeight + C.spacing.normal : 0

				PwObjectTracker {
					objects: [node.modelData]
				}

				Text {
					id: name
					textFormat: Text.PlainText
					text: node.modelData.properties["application.name"] ?? root.nodeName(node.modelData)
					elide: Text.ElideRight
					font.pixelSize: C.fontMedium
					color: C._onSurface
					anchors.left: parent.left
					anchors.right: expandButton.left
					anchors.margins: C.spacing.normal
				}

				Text {
					id: summary
					textFormat: Text.PlainText
					text: node.modelData.properties["media.name"] ?? ""
					elide: Text.ElideRight
					font.pixelSize: C.fontSmall
					color: C.primary
					width: parent.width
					height: visible ? contentHeight : 0
					anchors {
						top: name.bottom
						right: name.right
						left: name.left
					}
				}

				Button {
					id: expandButton
					width: height
					text: drawer.state === "hidden" ? "+" : "-"
					anchors.right: parent.right
					anchors.top: parent.top
					anchors.margins: C.spacing.normal

					onClicked: drawer.toggle()
				}

				Rectangle {
					id: drawer
					anchors.top: summary.bottom
					anchors.margins: C.spacing.small
					state: "hidden"
					visible: false
					width: parent.width
					color: C.surfaceVariant

					function toggle(): void {
						state = state === "hidden" ? "visible" : "hidden";
					}

					states: [
						State {
							name: "hidden"
							PropertyChanges {
								drawer {
									opacity: 0
									height: 0
								}
							}
						},
						State {
							name: "visible"
							PropertyChanges {
								drawer {
									opacity: 1
									height: targets.y + targets.height + C.spacing.normal
								}
							}
						}
					]

					transitions: [
						Transition {
							to: "visible"
							SequentialAnimation {
								ScriptAction {
									script: drawer.visible = true
								}
								ParallelAnimation {
									OpacityAnimator {
										target: drawer
										duration: C.duration.medium
										easing.type: Easing.BezierSpline
										easing.bezierCurve: C.easing.emphasizedDecel
									}
									NumberAnimation {
										target: drawer
										property: "height"
										duration: C.duration.medium
										easing.type: Easing.BezierSpline
										easing.bezierCurve: C.easing.emphasizedDecel
									}
								}
							}
						},
						Transition {
							from: "visible"
							to: "hidden"
							SequentialAnimation {
								ParallelAnimation {
									OpacityAnimator {
										target: drawer
										duration: C.duration._short
										easing.type: Easing.BezierSpline
										easing.bezierCurve: C.easing.emphasizedAccel
									}
									NumberAnimation {
										target: drawer
										property: "height"
										duration: C.duration._short
										easing.type: Easing.BezierSpline
										easing.bezierCurve: C.easing.emphasizedAccel
									}
								}
								ScriptAction {
									script: drawer.visible = false
								}
							}
						}
					]

					Text {
						id: targetsLabel
						text: "Targets"
						font.capitalization: Font.AllUppercase
						font.pixelSize: C.fontSmall
						color: C._onSurfaceVariant
						x: C.spacing.normal
						y: C.spacing.small
					}

					Flow {
						id: targets
						anchors {
							top: targetsLabel.bottom
							right: parent.right
							left: parent.left
							margins: C.spacing.normal
							topMargin: C.spacing.small
						}
						spacing: C.spacing.normal

						Repeater {
							model: ScriptModel {
								values: Pipewire.nodes.values.filter(n => n.isSink && !n.isStream)
							}
							delegate: Button {
								required property PwNode modelData
								onClicked: Quickshell.execDetached(["pw-target", node.modelData.id, modelData.id])
								text: root.nodeName(modelData)
							}
						}
					}
				}
			}
		}
	}

	TabBar {
		id: bar
		position: T.TabBar.Footer
		currentIndex: view.currentIndex
		width: parent.width
		anchors.bottom: parent.bottom

		TabButton {
			text: "Devices"
		}
		TabButton {
			text: "Applications"
		}
	}
}
