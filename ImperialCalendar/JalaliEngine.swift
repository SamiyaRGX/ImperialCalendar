import Foundation

struct JalaliDate: Equatable {
    var year: Int
    var month: Int
    var day: Int
}

enum ImperialCalendarEngine {

    /// سال شاهنشاهی = هجری شمسی + ۱۱۸۰ (مبدأ: ۵۵۹ پیش از میلاد)
    static let imperialOffset = 1180

    static let monthNames = [
        "فروردین", "اردیبهشت", "خرداد", "تیر", "مرداد", "شهریور",
        "مهر", "آبان", "آذر", "دی", "بهمن", "اسفند"
    ]

    static let gregorianMonthNames = [
        "ژانویه", "فوریه", "مارس", "آوریل", "مه", "ژوئن",
        "ژوئیه", "اوت", "سپتامبر", "اکتبر", "نوامبر", "دسامبر"
    ]

    static let weekdayNames = ["شنبه", "یکشنبه", "دوشنبه", "سه‌شنبه",
                               "چهارشنبه", "پنجشنبه", "جمعه"]

    private static let gregCal: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(secondsFromGMT: 0)!
        return c
    }()

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

    // MARK: - طول ماه و سال
    static func gregorianDayNumber(gy: Int, gm: Int, gd: Int) -> Int {
        let gdm = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334]
        let gy2 = gm > 2 ? gy + 1 : gy
        return 365 * gy + (gy2 + 3) / 4 - (gy2 + 99) / 100
             + (gy2 + 399) / 400 + gdm[gm - 1] + gd
    }

    static func isJalaliLeap(_ jy: Int) -> Bool {
        let g1 = jalaliToGregorian(jy: jy, jm: 1, jd: 1)
        let g2 = jalaliToGregorian(jy: jy + 1, jm: 1, jd: 1)
        return gregorianDayNumber(gy: g2.gy, gm: g2.gm, gd: g2.gd)
             - gregorianDayNumber(gy: g1.gy, gm: g1.gm, gd: g1.gd) == 366
    }

    static func jalaliMonthLength(jy: Int, jm: Int) -> Int {
        switch jm {
        case 1...6:  return 31
        case 7...11: return 30
        default:     return isJalaliLeap(jy) ? 30 : 29
        }
    }

    // MARK: - شاهنشاهی
    static func imperialYear(fromJalali jy: Int) -> Int { jy + imperialOffset }
    static func jalaliYear(fromImperial iy: Int) -> Int { iy - imperialOffset }

    // MARK: - امروز و روز هفته
    static func todayJalali() -> JalaliDate {
        let cal = Calendar(identifier: .gregorian)
        let now = Date()
        return gregorianToJalali(
            gy: cal.component(.year, from: now),
            gm: cal.component(.month, from: now),
            gd: cal.component(.day, from: now)
        )
    }

    /// ۰ = شنبه ... ۶ = جمعه
    static func weekday0(of j: JalaliDate) -> Int {
        let g = jalaliToGregorian(jy: j.year, jm: j.month, jd: j.day)
        let date = gregCal.date(from: DateComponents(year: g.gy, month: g.gm, day: g.gd))!
        return gregCal.component(.weekday, from: date) % 7
    }

    static func firstWeekday0OfMonth(jy: Int, jm: Int) -> Int {
        weekday0(of: JalaliDate(year: jy, month: jm, day: 1))
    }

    static func longString(of j: JalaliDate) -> String {
        "\(weekdayNames[weekday0(of: j)]) \(j.day.persianDigits) \(monthNames[j.month - 1])"
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

    func replacingPersianDigits() -> String {
        let fa = ["۰":"0","۱":"1","۲":"2","۳":"3","۴":"4","۵":"5","۶":"6","۷":"7","۸":"8","۹":"9",
                  "٠":"0","١":"1","٢":"2","٣":"3","٤":"4","٥":"5","٦":"6","٧":"7","٨":"8","٩":"9"]
        return self.map { fa[String($0)] ?? String($0) }.joined()
    }
}

extension BinaryInteger {
    var persianDigits: String { String(self).persianDigits }
}
