import SwiftUI

public class Haptics {
    static private let shared = Haptics()
    
    private let softHammer = UIImpactFeedbackGenerator(style: .soft)
    private let mediumHammer = UIImpactFeedbackGenerator(style: .medium)
    private let hardHammer = UIImpactFeedbackGenerator(style: .heavy)
    
    private init() {
        softHammer.prepare()
        mediumHammer.prepare()
        hardHammer.prepare()
    }
    
    public static func softRoll() {
        shared.softHammer.impactOccurred(intensity: 0.8)
    }
    
    public static func mediumRoll() {
        shared.mediumHammer.impactOccurred(intensity: 0.8)
    }
    
    public static func hit() {
        shared.hardHammer.impactOccurred(intensity: 0.9)
    }
}
