import SwiftUI

struct ConverterScreen: View {
    var onMenu: () -> Void

    private let kinds = ["هجری شمسی", "شاهنشاهی", "میلادی"]
    @State private var kind = 0
    @State private var yText = ""
    @State private var mText = ""
    @State private var dText = ""
    @State private var errMsg = ""
    @State private var showErr = false
    @State private var result: ConvResult?

    struct ConvResult {
        let jy: Int, jm: Int, jd: Int
        let imperialYear: Int
        let gy: Int, gm: Int, gd: Int
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                TopBar(title: "تبدیل تاریخ", onMenu: onMenu)

                VStack(spacing: 12) {
                    Picker("", selection: $kind) {
                        ForEach(0..<kinds.count, id: \.self) { Text(kinds[$0]) }
                    }
                    .pickerStyle(.segmented)

                    HStack(spacing: 10) {
                        field("سال", $yText)
                        field("ماه", $mText)
                        field("روز", $dText)
                    }

                    Text(hintText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    Button(action: convert) {
                        Label("تبدیل کن", systemImage: "arrow.left.arrow.right")
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(16)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(20)
                .padding(.horizontal)

                if let r = result { resultCard(r) }
            }
            .padding(.bottom, 28)
        }
        .background(Color(.systemGroupedBackground))
        .environment(\.layoutDirection, .rightToLeft)
        .alert("خطای ورودی", isPresented: $showErr) {
            Button("باشد", role: .cancel) {}
        } message: {
            Text(errMsg)
        }
    }

    private var hintText: String {
        switch kind {
        case 1:  return "مثال: ۲۵۸۵ / ۶ / ۱۵ (شاهنشاهی = شمسی + ۱۱۸۰)"
        case 2:  return "مثال: ۲۰۲۶ / ۹ / ۶"
        default: return "مثال: ۱۴۰۵ / ۶ / ۱۵"
        }
    }

    private func field(_ p: String, _ t: Binding<String>) -> some View {
        TextField(p, text: t)
            .keyboardType(.numberPad)
            .multilineTextAlignment(.center)
            .padding()
            .background(Color(.systemGroupedBackground))
            .cornerRadius(12)
    }

    private func convert() {
        guard let yv = Int(yText.replacingPersianDigits()),
              let mv = Int(mText.replacingPersianDigits()),
              let dv = Int(dText.replacingPersianDigits()) else {
            err("لطفاً سال، ماه و روز را به عدد وارد کنید.")
            return
        }
        guard mv >= 1 && mv <= 12 else {
            err("ماه باید بین ۱ تا ۱۲ باشد.")
            return
        }

        if kind == 2 {
            var cal = Calendar(identifier: .gregorian)
            cal.timeZone = TimeZone(secondsFromGMT: 0)!
            guard let date = cal.date(from: DateComponents(year: yv, month: mv, day: dv)),
                  cal.dateComponents([.day], from: date).day == dv else {
                err("تاریخ میلادی نامعتبر است (مثلاً ۳۰ فوریه).")
                return
            }
            let j = ImperialCalendarEngine.gregorianToJalali(gy: yv, gm: mv, gd: dv)
            result = ConvResult(jy: j.year, jm: j.month, jd: j.day,
                                imperialYear: ImperialCalendarEngine.imperialYear(fromJalali: j.year),
                                gy: yv, gm: mv, gd: dv)
            return
        }

        var jy = yv
        if kind == 1 {
            jy = ImperialCalendarEngine.jalaliYear(fromImperial: yv)
            guard jy >= 1 else {
                err("کمترین سال معتبر شاهنشاهی، ۱۱۸۱ است.")
                return
            }
        }
        guard jy >= 1 else {
            err("سال نامعتبر است.")
            return
        }
        guard dv >= 1 && dv <= ImperialCalendarEngine.jalaliMonthLength(jy: jy, jm: mv) else {
            err("روز واردشده در این ماه معتبر نیست (اسفند کبیسه ۳۰ روزه است).")
            return
        }
        let g = ImperialCalendarEngine.jalaliToGregorian(jy: jy, jm: mv, jd: dv)
        result = ConvResult(jy: jy, jm: mv, jd: dv,
                            imperialYear: ImperialCalendarEngine.imperialYear(fromJalali: jy),
                            gy: g.gy, gm: g.gm, gd: g.gd)
    }

    private func err(_ m: String) {
        errMsg = m
        showErr = true
    }

    private func resultCard(_ r: ConvResult) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            row("گاه شمار شاهنشاهی",
                "\(r.jd.persianDigits) \(ImperialCalendarEngine.monthNames[r.jm - 1]) \(r.imperialYear.persianDigits)")
            row("هجری شمسی",
                "\(r.jy.persianDigits)/\(r.jm.persianDigits)/\(r.jd.persianDigits)")
            row("میلادی",
                "\(r.gd.persianDigits) \(ImperialCalendarEngine.gregorianMonthNames[r.gm - 1]) \(r.gy.persianDigits)")
            row("روز هفته",
                ImperialCalendarEngine.weekdayNames[ImperialCalendarEngine.weekday0(of: JalaliDate(year: r.jy, month: r.jm, day: r.jd))])
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(20)
        .padding(.horizontal)
    }

    private func row(_ label: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.footnote)
                .foregroundColor(.secondary)
            Spacer(minLength: 10)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .multilineTextAlignment(.trailing)
        }
    }
}
