import SwiftUI

public class Haptics {
    static private let shared = Haptics()
    // UISelectionFeedbackGeneratorはUIの値が変化した時に使用
    private let selection = UISelectionFeedbackGenerator()
    private let light = UIImpactFeedbackGenerator(style: .light)
    
    private init() {
        selection.prepare()
        light.prepare()
    }
    
    public static func selection() {
        shared.selection.selectionChanged()
    }
    
    public static func lightImpact() {
        shared.light.impactOccurred()
    }
}
