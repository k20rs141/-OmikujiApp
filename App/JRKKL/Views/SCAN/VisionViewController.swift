import AVFoundation
import Foundation
import UIKit
import Vision

class VisionViewController: ScanViewController {
    var request: VNRecognizeTextRequest!
    let numberTracker = StringTracker()

    override func viewDidLoad() {
        request = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)

        super.viewDidLoad()
    }

    // MARK: - Text recognition
    // VNRecognizeTextRequestに文字認識した結果を渡すHandler
    func recognizeTextHandler(request: VNRequest, error: Error?) {
        var numbers = [String]()
        var redBoxes = [CGRect]() // 認識した文字
        var greenBoxes = [CGRect]() // 条件に当てはまった文字

        // 認識したテキストの結果を反復
        guard let results = request.results as? [VNRecognizedTextObservation] else { return }
        
        let maximumCandidates = 1

        for visionResult in results {
            guard let candidate = visionResult.topCandidates(maximumCandidates).first else { continue }
            
            var numberIsSubstring = true

            if let result = candidate.string.extractTicketNumber(state: state) {
                let (range, number) = result
                // 文字同士の境界ボックスを抽出
                if let box = try? candidate.boundingBox(for: range)?.boundingBox {
                    numbers.append(number)
                    greenBoxes.append(box)
                    numberIsSubstring = !(range.lowerBound == candidate.string.startIndex && range.upperBound == candidate.string.endIndex)
                }
            }
            if numberIsSubstring {
                redBoxes.append(visionResult.boundingBox)
            }
        }

        // 認識した番号をログに記録
        numberTracker.logFrame(strings: numbers)
        show(boxGroups: [(color: UIColor.red.cgColor, boxes: redBoxes), (color: UIColor.green.cgColor, boxes: greenBoxes)])

        // 安定した数値があるかの確認
        if let sureNumber = numberTracker.getStableString() {
            showMessage(value: sureNumber)
            numberTracker.reset(string: sureNumber)
        }
    }

    override func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            // 認識レベルの速度
            request.recognitionLevel = .fast
            // 言語修正
            request.usesLanguageCorrection = false
            // 速度向上のための領域指定
            request.regionOfInterest = regionOfInterest

            let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: textOrientation, options: [:])
            do {
                try requestHandler.perform([request])
            } catch {
                print(error)
            }
        }
    }

    // MARK: - Bounding box drawing
    // 画面上にボックスを描画
    var boxLayer = [CAShapeLayer]()
    func draw(rect: CGRect, color: CGColor) {
        let layer = CAShapeLayer()
        layer.opacity = 0.5
        layer.borderColor = color
        layer.borderWidth = 1.0
        layer.frame = rect
        boxLayer.append(layer)
        previewView.videoPreviewLayer.insertSublayer(layer, at: 1)
    }

    // 描画されたボックスの削除
    func removeBoxes() {
        for layer in boxLayer {
            layer.removeFromSuperlayer()
        }
        boxLayer.removeAll()
    }

    typealias ColoredBoxGroup = (color: CGColor, boxes: [CGRect])

    // 色のついたボックスの描画
    func show(boxGroups: [ColoredBoxGroup]) {
        DispatchQueue.main.async {
            let layer = self.previewView.videoPreviewLayer
            self.removeBoxes()
            for boxGroup in boxGroups {
                let color = boxGroup.color
                for box in boxGroup.boxes {
                    let rect = layer.layerRectConverted(fromMetadataOutputRect: box.applying(self.visionToAVFTransform))
                    self.draw(rect: rect, color: color)
                }
            }
        }
    }
}
