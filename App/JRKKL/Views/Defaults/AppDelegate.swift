import UIKit
import SideMenu
import UserNotifications

func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
        let output = items.map { "\($0)" }.joined(separator: separator)
        Swift.print(output, terminator: terminator)
    #endif
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    struct Content: Codable {
        var userId: String
        var user: String
    }

    var contents = [Content]()

    var window: UIWindow?
    var userId: String?

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self

        // MARK: 02. request to user

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            guard granted else { return }

            // MARK: 03. register to APNs

            DispatchQueue.main.async { UIApplication.shared.registerForRemoteNotifications() }
        }

        setSideMenu()
        
        return true
    }

    private func setSideMenu() {
        // MenuViewControllerをSideMenuにセット
        let menuViewController = MenuViewController()
        let menuNavigationController = SideMenuNavigationController(rootViewController: menuViewController)

        SideMenuManager.default.leftMenuNavigationController = menuNavigationController
        SideMenuManager.default.leftMenuNavigationController?.presentationStyle = .menuSlideIn
        // SideMenuのWidthサイズ
//        SideMenuManager.default.leftMenuNavigationController?.menuWidth = 320
        // SideMenuをSwipeGestureで非表示に
        SideMenuManager.default.leftMenuNavigationController?.enableSwipeToDismissGesture = true
    }
    
    // フォアグラウンドでの通知受信
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .sound, .banner, .list])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: () -> Void) {
        completionHandler()
    }

    func applicationWillResignActive(_ application: UIApplication) {

    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // プッシュ通知を決す
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func applicationWillEnterForeground(_ application: UIApplication) {

    }

    func applicationDidBecomeActive(_ application: UIApplication) {

    }

    func applicationWillTerminate(_ application: UIApplication) {
        
    }
}

// MARK: - Callback for Remote Notification

extension AppDelegate {
    // MARK: 04-1. succeeded to register to APNs

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // 値が保持されていなければ、初期値をセット
        UserDefaults.standard.register(defaults: ["deviceToken": "0"])
        UserDefaults.standard.register(defaults: ["uuid": "0"])
        UserDefaults.standard.register(defaults: ["userId": 0])

        // デバイストークンとUUIDを読込み、値がデフォルト値であれば、すぐにセット
        let deviceToken = deviceToken.map { (byte: UInt8) in String(format: "%02.2hhx", byte) }
        let uuid = UIDevice.current.identifierForVendor!.uuidString
        if UserDefaults.standard.object(forKey: "deviceToken") as? String == "0" { UserDefaults.standard.set(deviceToken.joined(), forKey: "deviceToken") }
        if UserDefaults.standard.object(forKey: "uuid") as? String == "0" { UserDefaults.standard.set(uuid, forKey: "uuid") }

        // 保存されている値を読み込む
        guard let storedDeviceToken = UserDefaults.standard.object(forKey: "deviceToken") as? String else { return }
        guard let storedUuid = UserDefaults.standard.object(forKey: "uuid") as? String else { return }
        guard let userId = UserDefaults.standard.object(forKey: "userId") as? Int else { return }

        // 保存されている値と比較し、違っていたら新しい値をセット
        if deviceToken.joined() != storedDeviceToken { UserDefaults.standard.set(deviceToken.joined(), forKey: "deviceToken") }
        if uuid != storedUuid { UserDefaults.standard.set(uuid, forKey: "uuid") }

        // 情報収集
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        let modelName = UIDevice.modelName
        let systemVersion = UIDevice.current.systemVersion

        // POST送信の準備
        let postString = "deviceToken=\(deviceToken.joined())&storedDeviceToken=\(storedDeviceToken)&uuid=\(uuid)&storedUuid=\(storedUuid)&userId=\(userId)&build=\(build)&modelName=\(modelName)&systemVersion=\(systemVersion)"
        print(postString)
        var request = URLRequest(url: URL(string: "http://mwu.apps.kyusan-u.ac.jp:8086/jrkkl/deviceToken.php")!)
        request.httpMethod = "POST"
        request.httpBody = postString.data(using: .utf8)
    }

    // MARK: failed to register to APNs
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register to APNs: \(error)")
    }
}
