import UserNotifications
import MapKit
import AVFoundation

class NotificationModel: ObservableObject {
    let synthesizer = AVSpeechSynthesizer()
    var notificationDelegate = ForegroundNotificationDelegate()

    init() {
        // フォアグラウンド通知用
        UNUserNotificationCenter.current().delegate = self.notificationDelegate
        // フォアグラウンド時に配信した全ての通知を削除
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
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
        // 通知内容
        let content = UNMutableNotificationContent()
        content.title = "JR九州香椎線"
        content.body = "まもなく到着します"
        content.sound = UNNotificationSound.default
        // リクエスト作成
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
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
