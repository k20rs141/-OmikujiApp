import UIKit
import SideMenu

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private var tableView = UITableView()

    // サイドメニュの項目は，ここで定義
    // 動作は，トップメニュ（AnimationViewController）で設定
    private var items: [String] = ["", "ホーム", "JR九州アプリ「JR九州」", "JR九州Webサイト", "九州産業大学アプリ「KSU」", "九州産業大学Webサイト", "", "九州の旅とお取り寄せ", "", "Twitter（#香椎線）", "Instagram（香椎地区統括）", "Instagram（客室乗務員）", "Facebook（鉄道プロモ）", "JR九州公式LINEアカウント", "TikTok（#香椎線）", "GPSチェックイン", "スタンプコレクション", "バージョン：\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "") (\(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""))", ""]

    let jrq1stColor: UIColor = UIColor(named: "Jrq1stColor") ?? .white
    let jrq2ndColor: UIColor = UIColor(named: "Jrq2ndColor") ?? .white

    override func viewDidLoad() {
        super.viewDidLoad()

        // 背景色はJR九州2ndカラーにして，透過率は，0.95にする
        view.backgroundColor = jrq2ndColor.withAlphaComponent(0.95)

        // 見た目調整
        navigationController?.navigationBar.tintColor = .clear
        navigationController?.navigationBar.barStyle = UIBarStyle.default
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.backgroundColor = UIColor(hex: "22304F")

        navigationController?.navigationBar.isHidden = true

        // TableView を追加
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView()
        view.addSubview(tableView)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.textLabel?.text = items[indexPath.row]
        cell.textLabel?.textColor = .white
//        cell.textLabel?.textColor = jrq1stColor
//        cell.textLabel?.textColor = jrq2ndColor
        cell.textLabel?.font = UIFont(name: "HiraMaruProN-W4", size: cell.textLabel!.font.pointSize)
        cell.backgroundColor = .clear

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // セルの選択を解除
        tableView.deselectRow(at: indexPath, animated: true)
        dismiss(animated: true, completion: nil)

        NotificationCenter.default.post(
            name: Notification.Name("SelectMenuNotification"),
            object: nil,
            userInfo: ["itemNo": indexPath.row] // 返したいデータをセットする
        )
    }
}
