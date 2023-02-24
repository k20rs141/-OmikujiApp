import UserNotifications
import MapKit

class NotificationModel: ObservableObject {

    let notificationIdentifier = "NotificationIdentifier"
    var notificationDelegate = ForegroundNotificationDelegate()

    init() {
        // フォアグラウンド通知用
        UNUserNotificationCenter.current().delegate = self.notificationDelegate
    }

    func setNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if granted {
                self.makeNotification()
            } else {

            }
        }
    }

    func makeNotification() {
        let notificationDate = Date().addingTimeInterval(1) // 1秒後
        let dateComp = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: notificationDate)
        //日時でトリガー指定
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComp, repeats: false)
        //通知内容
        let content = UNMutableNotificationContent()
        content.title = "まもなく到着します"
        content.body = "準備をしてください"
        content.sound = UNNotificationSound.default
        //リクエスト作成
        let request = UNNotificationRequest(identifier: self.notificationIdentifier, content: content, trigger: trigger)
        //通知をセット
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    func removeNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [self.notificationIdentifier])
    }
}
