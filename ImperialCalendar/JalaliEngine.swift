import Foundation

struct JalaliDate {
    var year: Int   // سال خورشیدی (هجری شمسی)
    var month: Int  // 1...12
    var day: Int    // 1...31
}

enum ImperialCalendarEngine {

    /// اختلاف تقویم شاهنشاهی (مبدأ کوروش ۵۵۹ ق.م) با هجری شمسی
    static let imperialOffset = 559

    static let monthNames = [
        "فروردین", "اردیبهشت", "خرداد", "تیر", "مرداد", "شهریور",
        "مهر", "آبان", "آذر", "دی", "بهمن", "اسفند"
    ]

    static let imperialEraName = "شاهنشاهی"

    // MARK: - تبدیل میلادی → شمسی
    static func gregorianToJalali(gy: Int, gm: Int, gd: Int) -> JalaliDate {
        let gdm = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334]
        var gyv = gy
        var jy = gyv <= 1600 ? 0 : 979
        gyv -= gyv <= 1600 ? 621 : 1600
        let gy2 = gm > 2 ? gyv + 1 : gyv
        var days = 365 * gyv + (gy2 + 3) / 4 - (gy2 + 99) / 100
        days += (gy2 + 399) / 400 - 80 + gd + gdm[gm - 1]
        jy += 33 * (days / 12053)
        days %= 12053
        jy += 4 * (days / 1461)
        days %= 1461
        if days > 365 {
            jy += (days - 1) / 365
            days = (days - 1) % 365
        }
        let jm = days < 186 ? 1 + days / 31 : 7 + (days - 186) / 30
        let jd = 1 + (days < 186 ? days % 31 : (days - 186) % 30)
        return JalaliDate(year: jy, month: jm, day: jd)
    }

    // MARK: - تبدیل شمسی → میلادی
    static func jalaliToGregorian(jy jyIn: Int, jm: Int, jd: Int) -> (gy: Int, gm: Int, gd: Int) {
        let gyBase = jyIn <= 979 ? 621 : 1600
        let jy = jyIn - (jyIn <= 979 ? 0 : 979)
        var days = 365 * jy + (jy / 33) * 8 + ((jy % 33) + 3) / 4
        days += jm < 7 ? (jm - 1) * 31 : (jm - 7) * 30 + 186
        days += jd - 1
        var gy = gyBase + 400 * (days / 146097)
        days %= 146097
        if days > 36524 {
            gy += 100 * ((days - 1) / 36524)
            days = days - (days - 1) / 36524 * 36524
            if days >= 365 { days += 1 }
        }
        gy += 4 * (days / 1461)
        days %= 1461
        if days > 365 {
            gy += (days - 1) / 365
            days = (days - 1) % 365
        }
        var gd = days + 1
        let leap = (gy % 4 == 0 && gy % 100 != 0) || (gy % 400 == 0)
        let salA = [0, 31, leap ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
        var gm = 0
        while gm < 13 && gd > salA[gm] {
            gd -= salA[gm]
            gm += 1
        }
        return (gy, gm, gd)
    }

    // MARK: - طول سال/ماه شمسی (برای اسفند ۲۹/۳۰)
    static func gregorianDayNumber(gy: Int, gm: Int, gd: Int) -> Int {
        let gdm = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334]
        let gy2 = gm > 2 ? gy + 1 : gy
        return 365 * gy + (gy2 + 3) / 4 - (gy2 + 99) / 100
             + (gy2 + 399) / 400 + gdm[gm - 1] + gd
    }

    static func jalaliYearLength(_ jy: Int) -> Int {
        let g1 = jalaliToGregorian(jy: jy, jm: 1, jd: 1)
        let g2 = jalaliToGregorian(jy: jy + 1, jm: 1, jd: 1)
        return gregorianDayNumber(gy: g2.gy, gm: g2.gm, gd: g2.gd)
             - gregorianDayNumber(gy: g1.gy, gm: g1.gm, gd: g1.gd)
    }

    static func isJalaliLeap(_ jy: Int) -> Bool {
        jalaliYearLength(jy) == 366
    }

    static func jalaliMonthLength(jy: Int, jm: Int) -> Int {
        switch jm {
        case 1...6:  return 31
        case 7...11: return 30
        default:     return isJalaliLeap(jy) ? 30 : 29
        }
    }

    // MARK: - خروجی شاهنشاهی
    static func imperialYear(fromJalali jy: Int) -> Int { jy + imperialOffset }

    /// تاریخ امروز به شمسی
    static func todayJalali() -> JalaliDate {
        let cal = Calendar(identifier: .gregorian)
        let now = Date()
        return gregorianToJalali(
            gy: cal.component(.year, from: now),
            gm: cal.component(.month, from: now),
            gd: cal.component(.day, from: now)
        )
    }

    static func weekdayNameOfToday() -> String {
        let idx = Calendar(identifier: .gregorian).component(.weekday, from: Date())
        let names = ["یکشنبه", "دوشنبه", "سه‌شنبه", "چهارشنبه",
                     "پنجشنبه", "جمعه", "شنبه"] // weekday=1 یعنی یکشنبه
        return names[idx - 1]
    }
}

extension String {
    var persianDigits: String {
        let en = ["0","1","2","3","4","5","6","7","8","9"]
        let fa = ["۰","۱","۲","۳","۴","۵","۶","۷","۸","۹"]
        var s = self
        for (i, e) in en.enumerated() { s = s.replacingOccurrences(of: e, with: fa[i]) }
        return s
    }
}

extension BinaryInteger {
    var persianDigits: String {
        String(self).persianDigits
    }
}
