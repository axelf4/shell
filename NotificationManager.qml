pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
	id: root
	property alias notifications: server.trackedNotifications

	Component {
		id: notificationTimer
		Timer {
			required property Notification notification
			running: interval >= 0
			onTriggered: notification.expire()
		}
	}

	NotificationServer {
		id: server
		imageSupported: true
		actionsSupported: true
		actionIconsSupported: true

		onNotification: notification => {
			console.log("got notification:", notification, notification.image, notification.appIcon);
			notification.tracked = true;
			notification.timer = notificationTimer.createObject(notification, {
				notification,
				interval: 1000 * notification.expireTimeout
			});
		}
	}
}
