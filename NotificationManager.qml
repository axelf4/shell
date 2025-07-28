pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
	id: root
	readonly property ListModel notifications: ListModel {}

	Component {
		id: notificationTimer
		Timer {
			required property Notification notification
			onTriggered: notification.expire()
		}
	}

	NotificationServer {
		imageSupported: true
		actionsSupported: true
		actionIconsSupported: true

		onNotification: notification => {
			console.log("got notification:", notification, notification.image, notification.appIcon)
			notification.tracked = true;
			notification.closed.connect(root.forget.bind(this, notification))

			const timer = notificationTimer.createObject(this, {
				notification,
				running: notification.expireTimeout >= 0,
				interval: 1000 * notification.expireTimeout
			});
			root.notifications.append({
				notification, timer,
				image: notification.image || notification.appIcon,
				summary: notification.summary,
				body: notification.body,
			})
		}
	}

	function forget(notification: Notification, reason: NotificationCloseReason) {
		for (let i = 0; i < notifications.count; ++i) {
			let x = notifications.get(i);
			if (x.notification === notification) {
				x.timer.stop();
				notifications.remove(i);
				break;
			}
		}
	}

	function dismiss(index: int): void {
		if (index < 0) return;
		notifications.get(index).notification.dismiss();
	}
}
