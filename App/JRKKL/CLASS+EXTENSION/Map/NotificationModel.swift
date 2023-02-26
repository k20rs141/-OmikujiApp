import UserNotifications
import MapKit
import AVFoundation

class NotificationModel: ObservableObject {
    let synthesizer = AVSpeechSynthesizer()
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
        // 日時でトリガー指定
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComp, repeats: false)
        // 通知内容
        let content = UNMutableNotificationContent()
        content.title = "JR九州香椎線"
        content.body = "まもなく到着します"
        content.sound = UNNotificationSound.default
        // リクエスト作成
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        // 通知をセット
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        // 通知のテキストを音声で読み上げ
        speechSynthesizer(comment: request.content.body)
    }

    func removeNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [UUID().uuidString])
    }
    
    func speechSynthesizer(comment: String) {
        let utterance = AVSpeechUtterance(string: comment)
        utterance.voice = makeVoice("com.apple.voice.enhanced.ja-JP.Kyoko")
        synthesizer.speak(utterance)
    }
    // 日本語ボイスの生成
    func makeVoice(_ identifier: String) -> AVSpeechSynthesisVoice! {
        let voices = AVSpeechSynthesisVoice.speechVoices()
        for voice in voices {
            if voice.identifier == identifier {
                return AVSpeechSynthesisVoice.init(identifier: identifier)
            }
        }
        return AVSpeechSynthesisVoice.init(language: "ja-JP")
    }
}
