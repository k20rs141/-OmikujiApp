import SideMenu
import UIKit

class JrkklViewController: UIViewController {
    @IBOutlet var hambergerButton: UIButton! {
        didSet {
            hambergerButton.tintColor = UIColor(named: "Jrq2ndColor") ?? .blue
        }
    }

    @IBOutlet var frequentlyAskedQuestionsButton: UIButton! {
        didSet {
            frequentlyAskedQuestionsButton.tintColor = UIColor(named: "Jrq2ndColor") ?? .blue
        }
    }

    @IBOutlet var leftButton: UIButton! {
        didSet {
            leftButton.contentMode = .scaleAspectFit
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        hiddenBar()
        setupSideMenu()
    }

    private func hiddenBar() {
        print("hiddenBar()")
        navigationController?.navigationBar.isHidden = true
        tabBarController?.tabBar.isHidden = true
    }

    private func setupSideMenu() {
        // サイドバーメニューからの通知を受け取る
        // 設定は，AppDelegateにある
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(catchSelectMenuNotification(notification:)),
            name: Notification.Name("SelectMenuNotification"),
            object: nil
        )
    }

    // 選択されたサイドバーのアイテムを取得
    @objc
    func catchSelectMenuNotification(notification: Notification) {
        // メニューからの返り値を取得
        guard let itemNumber = notification.userInfo?["itemNo"] as? Int else { return } // 返り値が格納されている変数
        // 実行したい処理を記述する

        print("catchSelectMenuNotification():\(itemNumber)")

        switch itemNumber {
        case 2: openViewController("JRKYUSYU")
        case 3: openUrl("https://www.jrkyushu.co.jp/")
        case 4: openApp(urlScheme: "jp.ac.kyusan-u.ISICKSU://", urlString: "https://apps.apple.com/jp/app/id702774515")
//        case 4: openApp("ISICKSU://","https://apps.apple.com/jp/app/id702774515")
        case 5: openUrl("https://www.kyusan-u.ac.jp/")
        case 7: openUrl("https://jrk-kyushutabi.shop/smartphone/")
        case 9: openUrl("https://twitter.com/search?q=%23%E9%A6%99%E6%A4%8E%E7%B7%9A")
        case 10: openUrl("https://www.instagram.com/jrkyushu_akc.railgram_official/?hl=ja")
        case 11: openUrl("https://www.instagram.com/jr_lady_official/")
        case 12: openUrl("https://www.facebook.com/jrkyushu.please/")
        case 13: openUrl("https://line.me/R/ti/p/%40573zaqtk#~")
        case 14: openUrl("https://www.tiktok.com/tag/%E9%A6%99%E6%A4%8E%E7%B7%9A?lang=ja-JP")
//        case 13: openUrl("https://www.jrkyushu.co.jp/contact/")
        case 16: openUrl(UIApplication.openSettingsURLString)
        default: break
        }
    }

    private func openUrl(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        if UIApplication.shared.canOpenURL(url) { UIApplication.shared.open(url) }
    }

    private func openViewController(_ name: String) {
        guard let nextViewController = UIStoryboard(name: name, bundle: nil).instantiateInitialViewController() as? UINavigationController else { return }
        present(nextViewController, animated: true, completion: nil)
    }

    private func openApp(urlScheme: String, urlString: String) {
        guard let url = URL(string: urlScheme) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            openUrl(urlString)
        }
    }

    @IBAction func hambergerButton(_ sender: UIButton) {
        guard let menu = SideMenuManager.default.leftMenuNavigationController else { return }
        present(menu, animated: true, completion: nil)
    }

    @IBAction func frequentlyAskedQuestionsButton(_ sender: UIButton) {
        guard let nextViewController = UIStoryboard(name: "NEWS", bundle: nil).instantiateInitialViewController() as? UINavigationController else { return }
        present(nextViewController, animated: false, completion: nil)
    }

    @IBAction func myUnwindAction(segue: UIStoryboardSegue) {
    }

    @IBAction func informationButton(_ sender: UIButton) {
//        openUrl("https://www.jrkyushu.co.jp/news/index.html")
        openUrl("https://www.jrkyushu.co.jp/")
    }

    @IBAction func rightButton(_ sender: UIButton) {
        openViewController("JRKYUSYU")
    }
}
