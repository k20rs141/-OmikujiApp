import UserNotifications
import MapKit
import AVFoundation

class NotificationModel: NSObject, ObservableObject {
    let synthesizer = AVSpeechSynthesizer()
    let title = "JR九州香椎線"
    let body = "まもなく到着します"
    @Published var removeNotificationRequests = false

    override init() {
        super.init()
        // フォアグラウンド通知用
        UNUserNotificationCenter.current().delegate = self
    }

    func setNotification(notify: Bool) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if granted {
                self.makeNotification()
                // trueの時、音声読み上げ
                if notify {
                    self.speechSynthesizer()
                }
            } else {

            }
        }
    }

    func makeNotification() {
        // 通知内容
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        // リクエスト作成
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        // 通知をセット
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    func removeNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [UUID().uuidString])
    }
    
    func speechSynthesizer() {
        let utterance = AVSpeechUtterance(string: body)
        utterance.voice = makeVoice("com.apple.voice.enhanced.ja-JP.Kyoko")
        utterance.rate = 0.5
        synthesizer.speak(utterance)
    }
    
    func stopSpeechSynthesizer() {
        synthesizer.stopSpeaking(at: .word)
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
