import UserNotifications

// フォアグラウンド通知用
extension NotificationModel: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .list, .badge, .sound])
    }
    // 通知をタップしてアプリを起動した時
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        stopSpeechSynthesizer()
        removeNotificationRequests = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.removeNotificationRequests = false
        }
        completionHandler()
    }
}
