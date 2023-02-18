import AVFoundation
import UIKit
import Vision

class ScanViewController: UIViewController {
    
    @IBOutlet weak var errorImageView: UIImageView! {
        didSet {
            errorImageView.alpha = 0.0
        }
    }
        
    @IBOutlet var previewView: ScanPreviewView!
    @IBOutlet var cutoutView: UIView!
    @IBOutlet var numberLabel: UILabel!
    @IBOutlet var stateLabel: UILabel!
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var imageMaskView: UIView!
    
    enum Constant {
        static let captureSessionLabel = "jp.ac.kyusan-u.jrkkl.CaptureSessionQueue"
        static let videoDataOutputLabel = "jp.ac.kyusan-u.jrkkl.VideoDataOutputQueue"
        static let messages = ["serial": "４桁の番号を読み込んでね", "date": "日付を読み込んでね"]
    }

    // 図形の描画
    var maskLayer = CAShapeLayer()
    var imageMaskLayer = CAShapeLayer()
    // デバイスの向き(縦向き、ホームボタン下側)
    var currentOrientation = UIDeviceOrientation.portrait

    // MARK: - Capture related objects
    // デバイスからの入力と出力を管理するオブジェクトの作成
    private let captureSession = AVCaptureSession()
    
    let captureSessionQueue = DispatchQueue(label: Constant.captureSessionLabel)
    // カメラデバイスを管理するオブジェクトの作成
    var captureDevice: AVCaptureDevice?
    // 出力データを受け取るオブジェクトの作成
    var videoDataOutput = AVCaptureVideoDataOutput()
    let videoDataOutputQueue = DispatchQueue(label: Constant.videoDataOutputLabel)

    // MARK: - Region of interest (ROI) and text orientation 読み取り領域とテキストの向き
    // 読み取る部分のカメラ領域
    var regionOfInterest = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
    // キャプチャー時と同じ向きで画像を表示
    var textOrientation = CGImagePropertyOrientation.up

    // MARK: - Coordinate transforms 座標変換
    var bufferAspectRatio: Double!
    // 元の状態（座標）に戻す
    var uiRotationTransform = CGAffineTransform.identity
    // x方向に１倍、y方向に−１倍
    var bottomToTopTransform = CGAffineTransform(scaleX: 1.0, y: -1.0).translatedBy(x: 0.0, y: -1.0)
    
    var roiToGlobalTransform = CGAffineTransform.identity

    var visionToAVFTransform = CGAffineTransform.identity

    var stateArray = ["date", "serial"]
    var state = ""
    var isHiddenErrorMessage = true // 連続表示の制御
    var result: Dictionary<String, String> = [:]

    // MARK: - View controller methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        stopCaptureSession()
    }

    private func stopCaptureSession() {
        captureSessionQueue.async {
            // キャプチャセッションの終了
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }
        }
    }

    private func setup() {
        previewView.session = captureSession

        cutoutView.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        maskLayer.backgroundColor = UIColor.clear.cgColor
        // 重なった回数が偶数ならくりぬく（塗りつぶさない）
        maskLayer.fillRule = .evenOdd
        cutoutView.layer.mask = maskLayer

        imageMaskLayer.fillRule = .evenOdd
        backgroundImageView.layer.mask = imageMaskLayer
        // メインスレッドのブロックを防ぐためcaptureSessionQueueで実行
        captureSessionQueue.async {
            self.setupCamera()

//            // Calculate region of interest now that the camera is setup.
//            DispatchQueue.main.async {
//                // Figure out initial ROI.
//                // 検出する範囲を計算
//                self.calculateRegionOfInterest()
//                self.stateLabel.text = self.state
//            }
        }
    }

    // viewのサイズが変更されようとしていることを通知
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        let deviceOrientation = UIDevice.current.orientation
        // デバイスが縦向きまたは横向きのとき
        if deviceOrientation.isPortrait || deviceOrientation.isLandscape {
            currentOrientation = deviceOrientation
        }
        // デバイスの向きを処理
        if let videoPreviewLayerConnection = previewView.videoPreviewLayer.connection {
            if let newVideoOrientation = AVCaptureVideoOrientation(deviceOrientation: deviceOrientation) {
                videoPreviewLayerConnection.videoOrientation = newVideoOrientation
            }
        }
        // 方向が変更されると新たな領域を見つける
        calculateRegionOfInterest()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        updateCutout()
    }

    // MARK: - Setup
    // 検出する範囲を指定
    func calculateRegionOfInterest() {
        let desiredHeightRatio = 0.2
        let desiredWidthRatio = 0.6
        let maxPortraitWidth = 0.8

        let size: CGSize
        if currentOrientation.isPortrait || currentOrientation == .unknown {
            size = CGSize(width: min(desiredWidthRatio * bufferAspectRatio, maxPortraitWidth), height: desiredHeightRatio / bufferAspectRatio)
        } else {
            size = CGSize(width: desiredWidthRatio, height: desiredHeightRatio)
        }
        // 中心座標と大きさからCGRectを生成
        regionOfInterest.origin = CGPoint(x: (1 - size.width) / 2, y: (1 - size.height) / 2)
        regionOfInterest.size = size

        setupOrientationAndTransform()

        // 検出する範囲に一致するようにCutoutを更新
        DispatchQueue.main.async {
            self.updateCutout()
        }
    }

    func updateCutout() {
        // レイヤー座標で切り出しの終了位置を把握する。
        let roiRectTransform = bottomToTopTransform.concatenating(uiRotationTransform)
        let cutout = previewView.videoPreviewLayer.layerRectConverted(fromMetadataOutputRect: regionOfInterest.applying(roiRectTransform))

        // maskの作成
        let path = UIBezierPath(rect: cutoutView.frame)
        path.append(UIBezierPath(rect: cutout))
        maskLayer.path = path.cgPath

        // cutoutの下にnumberLabelを移動
        var numFrame = cutout
        numFrame.origin.y += numFrame.size.height
        numberLabel.frame = numFrame

        let imagePath = UIBezierPath(rect: backgroundImageView.frame)
        let roundRectangle = UIBezierPath(roundedRect: imageMaskView.frame,
                                          cornerRadius: 10.0)
        imagePath.append(roundRectangle)
        imageMaskLayer.path = imagePath.cgPath
    }

    func setupOrientationAndTransform() {
        // 検出する領域の補正
        let roi = regionOfInterest
        roiToGlobalTransform = CGAffineTransform(translationX: roi.origin.x, y: roi.origin.y).scaledBy(x: roi.width, y: roi.height)

        // orientationの補正
        switch currentOrientation {
        case .landscapeLeft:
            textOrientation = CGImagePropertyOrientation.up
            uiRotationTransform = CGAffineTransform.identity
        case .landscapeRight:
            textOrientation = CGImagePropertyOrientation.down
            uiRotationTransform = CGAffineTransform(translationX: 1, y: 1).rotated(by: CGFloat.pi)
        case .portraitUpsideDown:
            textOrientation = CGImagePropertyOrientation.left
            uiRotationTransform = CGAffineTransform(translationX: 1, y: 0).rotated(by: CGFloat.pi / 2)
        default: // We default everything else to .portraitUp
            textOrientation = CGImagePropertyOrientation.right
            uiRotationTransform = CGAffineTransform(translationX: 0, y: 1).rotated(by: -CGFloat.pi / 2)
        }

        // ROI->AVF変換
        visionToAVFTransform = roiToGlobalTransform.concatenating(bottomToTopTransform).concatenating(uiRotationTransform)
    }

    func setupCamera() {
        state = stateArray.randomElement()!
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back) else {
            print("Could not create capture device.")
            return
        }
        self.captureDevice? = captureDevice

        // デバイスの映像出力が(4K)に対応しているか
        if captureDevice.supportsSessionPreset(.hd4K3840x2160) {
            captureSession.sessionPreset = AVCaptureSession.Preset.hd4K3840x2160
            bufferAspectRatio = 3840.0 / 2160.0
        } else {
            captureSession.sessionPreset = AVCaptureSession.Preset.hd1920x1080
            bufferAspectRatio = 1920.0 / 1080.0
        }

        guard let deviceInput = try? AVCaptureDeviceInput(device: captureDevice) else {
            print("Could not create device input.")
            return
        }
        if captureSession.canAddInput(deviceInput) {
            captureSession.addInput(deviceInput)
        }

        // 出力データについて設定する
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]
        if captureSession.canAddOutput(videoDataOutput) {
            captureSession.addOutput(videoDataOutput)
            // 手ブレ修正モードOFF
            videoDataOutput.connection(with: AVMediaType.video)?.preferredVideoStabilizationMode = .off
        } else {
            print("Could not add VDO output")
            return
        }

        // ZoomとAutoFocusを設定して小さな文字に焦点を合わせる
        do {
            try captureDevice.lockForConfiguration()
            captureDevice.videoZoomFactor = 2
            captureDevice.autoFocusRangeRestriction = .near
            captureDevice.unlockForConfiguration()
        } catch {
            print("Could not set zoom level due to error: \(error)")
            return
        }
        // キャプチャセッションの開始
        captureSession.startRunning()

        // カメラがセットアップされたら検出する領域を計算
        DispatchQueue.main.async {
            // 検出する範囲を計算
            self.calculateRegionOfInterest()
            self.stateLabel.text = ScanViewController.Constant.messages[self.state]
        }
    }

    // MARK: - UI drawing and interaction

    func showMessage(value: String) {
        print("state: \(state) string: \(value)")
        print("Today: \(DateInfo.todayString())")
        // 切符の「-」部分を比較するために０に置換
        if state == "serial" || (state == "date" && DateInfo.todayString() == value.replacingOccurrences(of: "-", with: "0")) {
            captureSessionQueue.sync {
                // キャプチャセッションの終了
                captureSession.stopRunning()

                stateArray.removeAll(where: { $0 == state })
                result.updateValue(value, forKey: state) // 結果を保存

                if stateArray.count != 0 {
                    state = stateArray.randomElement()!
                }

                DispatchQueue.main.async {
                    self.numberLabel.text = "タップして次へ\n\n(\(value))"
                    self.numberLabel.backgroundColor = UIColor(named: "Jrq2ndColor") ?? .darkGray
                    self.numberLabel.textColor = .white
                    self.numberLabel.layer.cornerRadius = self.numberLabel.frame.height * 0.1
                    self.numberLabel.clipsToBounds = true
                    self.numberLabel.isHidden = false
                    self.stateLabel.text = ScanViewController.Constant.messages[self.state]
                }
            }
        } else {
            // 今日の切符じゃない場合
            if isHiddenErrorMessage {
                isHiddenErrorMessage = false
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseInOut, animations: {
                        self.errorImageView.alpha = 1.0
                    }, completion: { _ in
                        UIView.animate(withDuration: 2.0, delay: 1.0, options: .curveEaseInOut, animations: {
                            self.errorImageView.alpha = 0.0
                        }, completion: { _ in
                            self.isHiddenErrorMessage = true
                        })
                    })
                }
            }
        }
    }

    private func showLotViewController(_ minimumStateArrayCount: Int) {
        numberLabel.isHidden = true

        captureSessionQueue.async {
            if self.stateArray.count <= minimumStateArrayCount {
                // キャプチャセッションの終了
                if self.captureSession.isRunning {
                    self.captureSession.stopRunning()
                }

                DispatchQueue.main.async {
                    // LotViewControllerへ遷移
                    let storyboard = UIStoryboard(name: "LOT", bundle: .main)
                    let lotViewController = storyboard.instantiateViewController(withIdentifier: "LotViewController") as! LotViewController
                    lotViewController.dateString = self.result["date"]?.replacingOccurrences(of: "-", with: "0") ?? "000"
                    lotViewController.serialString = self.result["serial"] ?? "111"
                    self.present(lotViewController, animated: true, completion: nil)
                }
            } else {
                // キャプチャセッションの開始
                if !self.captureSession.isRunning {
                    self.captureSession.startRunning()
                }
            }
        }
    }

    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        showLotViewController(0)
    }

    @IBAction func testButton(_ sender: UIButton) {
        showLotViewController(10)
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension ScanViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // VisionViewControllerに実装
    }
}
