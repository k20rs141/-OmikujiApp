import UIKit

class LotViewController: UIViewController {
    struct Omikuji: Codable {
        struct Contents: Codable {
            let type: String
            let comment: [String]
        }

        let fortuneType: String
        let contents: [Contents]
    }

    var omikuji = [Omikuji]()

    @IBOutlet var shakeLeftImageView: UIImageView!
    @IBOutlet var shakeRightImageView: UIImageView!

    @IBOutlet var omikujiResultView: UIView! {
        didSet {
            omikujiResultView.alpha = 0.0
        }
    }

    @IBOutlet var fortuneLabel: UILabel! {
        didSet {
            fortuneLabel.textColor = .black
        }
    }

    @IBOutlet var fortuneCommentLabel: UILabel!
    @IBOutlet var academicCommentLabel: UILabel!
    @IBOutlet var loveCommentLabel: UILabel!
    @IBOutlet var travelCommentLabel: UILabel!

    @IBAction func homeButton(_ sender: UIButton) {
        presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    @IBAction func testButton(_ sender: UIButton) {
        showOmikuji(0)
    }

    // 切符の日付(dateString)とシリアル番号(serialString)
    // 値渡し（ScamViewController）
    var dateString = ""
    var serialString = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        becomeFirstResponder()
        omikujiJson()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // シェイク縦バージョン
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [.repeat, .autoreverse], animations: {
            self.shakeLeftImageView.center.y += 20
            self.shakeRightImageView.center.y += 20
        })
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        // 揺れが開始した時の処理
        if motion == .motionShake {
        }
    }

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        // 揺れが終了した時の処理
        if motion == .motionShake {
            showOmikuji(1)
        }
    }

    override func motionCancelled(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        // 揺れがキャンセルした時の処理
        if motion == .motionShake {
        }
    }

    private func showOmikuji(_ number: Int) {
        // デバイストークンを読み込む
        let storedDeviceToken = UserDefaults.standard.string(forKey: "deviceToken") ?? "54321098765432"
        let tokenNumber = (storedDeviceToken.components(separatedBy: NSCharacterSet.decimalDigits.inverted).joined())
        let tokenBits = tokenNumber.prefix(14)

        // おみくじ結果の表示
        UIView.transition(with: omikujiResultView, duration: 2.0, options: .curveEaseIn, animations: {
            self.omikujiResultView.alpha = 1.0
        })
        UIView.transition(with: shakeLeftImageView, duration: 2.0, options: .curveEaseIn, animations: {
            self.shakeLeftImageView.isHidden = true
        })
        UIView.transition(with: shakeRightImageView, duration: 2.0, options: .curveEaseIn, animations: {
            self.shakeRightImageView.isHidden = true
        })

        let dateInt: Int = Int(dateString) ?? 12345678
        let serialInt: Int = Int(serialString) ?? 9999
        print("dateInt: \(dateInt)")
        print("serialInt: \(serialInt)")

        let value = dateInt * serialInt + (Int(tokenBits) ?? 0)

        // number == 0 だと強制大吉
        let fortuneTypeNumber: Int = (value & 0x3) * number
        let fortuneNumber = (value >> 2) & 0x4
        let academicNumber = (value >> 5) & 0x4
        let loveNumber = (value >> 8) & 0x4
        let travelNumber = (value >> 11) & 0x4

        fortuneLabel.text = omikuji[fortuneTypeNumber].fortuneType

        // 配列参照する場合は，入ってるかを必ずチェック
        if omikuji[fortuneTypeNumber].contents.count >= 4 {
            fortuneCommentLabel.text = omikuji[fortuneTypeNumber].contents[0].comment[fortuneNumber]
            academicCommentLabel.text = omikuji[fortuneTypeNumber].contents[2].comment[academicNumber]
            loveCommentLabel.text = omikuji[fortuneTypeNumber].contents[1].comment[loveNumber]
            travelCommentLabel.text = omikuji[fortuneTypeNumber].contents[3].comment[travelNumber]
        }
    }

    private func omikujiJson() {
        guard let path = Bundle.main.path(forResource: "omikuji", ofType: "json"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
              let omikuji = try? JSONDecoder().decode([Omikuji].self, from: data) else { return }
        
        self.omikuji = omikuji
    }
}
