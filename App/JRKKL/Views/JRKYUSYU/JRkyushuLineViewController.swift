import UIKit

class JRkyushuLineViewController: UIViewController {
    @IBOutlet var applicationButton: UIButton!

    enum Constant {
        static let url = "https://www.jrkyushu.co.jp/app/lp/"
        static let urlScheme = "jrqapp://"
        static let appStoreUrl = "https://apps.apple.com/jp/app/id1081742880"
        static let appImageName = "JRKyusyuApp"
        static let appStoreBadgeImageName = "AppStoreBadge"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let url = URL(string: Constant.urlScheme) else { return }
        if UIApplication.shared.canOpenURL(url) {
            applicationButton.setImage(UIImage(named: Constant.appImageName), for: .normal)
        } else {
            applicationButton.setImage(UIImage(named: Constant.appStoreBadgeImageName), for: .normal)
        }
        applicationButton.imageView?.contentMode = .scaleAspectFit
    }

    private func openUrl(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        if UIApplication.shared.canOpenURL(url) { UIApplication.shared.open(url) }
    }

    @IBAction func homepageButton(_ sender: UIButton) {
        openUrl(Constant.url)
    }

    @IBAction func applicationButton(_ sender: UIButton) {
        guard let url = URL(string: Constant.urlScheme) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            openUrl(Constant.appStoreUrl)
        }
    }
}
