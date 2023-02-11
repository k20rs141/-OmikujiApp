import Foundation

extension Character {
    func getSimilarCharacterIfNotIn(allowedChars: String) -> Character {
        // 許容される文字のリストが与えられたら、selfをリストにある文字に変換
        let conversionTable = [
            "s": "S",
            "S": "5",
            "5": "S",
            "o": "O",
            "Q": "O",
            "O": "0",
            "0": "O",
            "l": "I",
            "I": "1",
            "1": "I",
            "B": "8",
            "8": "B",
        ]
        // 's' -> 'S' -> '5' を処理するために最大2つの置換を許容
        let maxSubstitutions = 2
        var current = String(self)
        var counter = 0
        while !allowedChars.contains(current) && counter < maxSubstitutions {
            if let altChar = conversionTable[current] {
                current = altChar
                counter += 1
            } else {
                break
            }
        }
        return current.first!
    }
}

extension String {
    // 切符の中の日付やシリアル番号を抽出し、タプルとして返す
    func extractTicketNumber(state: String) -> (Range<String.Index>, String)? {
        var pattern = ""
        switch state {
        case "date":
            pattern = "\\b(\\d{4}).(-?)(\\d{1,2}).(-?)(\\d{1,2})\\b"
            break
        case "serial":
            pattern = "\\b(\\d{4})\\b"
        default:
            break
        }

        guard let range = range(of: pattern, options: .regularExpression, range: nil, locale: nil) else {
            return nil
        }
        
        // 空白などの除去
        var ticketNumberDigits = ""
        let substring = String(self[range])
        let nsrange = NSRange(substring.startIndex..., in: substring)
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            if let match = regex.firstMatch(in: substring, options: [], range: nsrange) {
                for rangeInd in 1 ..< match.numberOfRanges {
                    let range = match.range(at: rangeInd)
                    let matchString = (substring as NSString).substring(with: range)
                    ticketNumberDigits += matchString as String
                }
            }
        } catch {
            print("Error \(error) when creating pattern")
        }
        
        // 誤認識される文字を代入
        var result = ""
        let allowedChars = "0123456789-"
        for var char in ticketNumberDigits {
            char = char.getSimilarCharacterIfNotIn(allowedChars: allowedChars)
            guard allowedChars.contains(char) else {
                return nil
            }
            result.append(char)
        }
        return (range, result)
    }
}

class StringTracker {
    typealias StringObservation = (lastSeen: Int64, count: Int64)

    // 安定した認識を得るために使用
    var frameIndex: Int64 = 0
    var seenStrings = [String: StringObservation]()
    var bestCount = Int64(0)
    var bestString = ""

    func logFrame(strings: [String]) {
        for string in strings {
            if seenStrings[string] == nil {
                seenStrings[string] = (lastSeen: Int64(0), count: Int64(-1))
            }
            seenStrings[string]?.lastSeen = frameIndex
            seenStrings[string]?.count += 1
            print("Seen \(string) \(seenStrings[string]?.count ?? 0) times")
        }

        var obsoleteStrings = [String]()

        for (string, obs) in seenStrings {
            // 30 フレーム (~1s) 後、前に見たテキストを削除
            if obs.lastSeen < frameIndex - 30 {
                obsoleteStrings.append(string)
            }
            // 最大カウントを持つStringを見つける
            let count = obs.count
            if !obsoleteStrings.contains(string) && count > bestCount {
                bestCount = Int64(count)
                bestString = string
            }
        }
        // 古い文字列の削除
        for string in obsoleteStrings {
            seenStrings.removeValue(forKey: string)
        }
        frameIndex += 1
    }

    func getStableString() -> String? {
        // 同じ文字列を10回以上は見ることを要求
        if bestCount >= 10 {
            return bestString
        } else {
            return nil
        }
    }

    func reset(string: String) {
        seenStrings.removeValue(forKey: string)
        bestCount = 0
        bestString = ""
    }
}
