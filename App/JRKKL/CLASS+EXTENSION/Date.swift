import Foundation

public class DateInfo {
    class func thisMonthInt() -> Int {
        let dateFormatter = DateFormatter()
        /// カレンダー、ロケール、タイムゾーンの設定（未指定時は端末の設定が採用される）
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.timeZone = TimeZone(identifier:  "Asia/Tokyo")
        
        /// 変換フォーマット定義（未設定の場合は自動フォーマットが採用される）
        dateFormatter.dateFormat = "MM"
        
        /// データ変換（Date→Int）
        let dateInt = Int(dateFormatter.string(from: Date())) ?? 0
        print("Month: \(dateInt)")   // 04...
        return dateInt
    }
    
    class func thisYearMonthString() -> String {
        let dateFormatter = DateFormatter()
        /// カレンダー、ロケール、タイムゾーンの設定（未指定時は端末の設定が採用される）
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.timeZone = TimeZone(identifier:  "Asia/Tokyo")
        
        /// 変換フォーマット定義（未設定の場合は自動フォーマットが採用される）
        dateFormatter.dateFormat = "yyMM"
        
        /// データ変換（Date→String）
        let dateString = dateFormatter.string(from: Date())
        print("Month: \(dateString)")   // 2104...
        return dateString
    }
    
    class func todayString() -> String {
        let dateFormatter = DateFormatter()
        /// カレンダー、ロケール、タイムゾーンの設定（未指定時は端末の設定が採用される）
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.timeZone = TimeZone(identifier:  "Asia/Tokyo")
        
        /// 変換フォーマット定義（未設定の場合は自動フォーマットが採用される）
        dateFormatter.dateFormat = "yyyyMMdd"
        
        /// データ変換（Date→String）
        let dateString = dateFormatter.string(from: Date())
        print("Today: \(dateString)")   // 2104...
        return dateString
    }
}
