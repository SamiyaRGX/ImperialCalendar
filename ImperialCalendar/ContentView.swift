import SwiftUI

struct ContentView: View {
    @State private var tab = 0
    @State private var jyText = ""
    @State private var jmText = ""
    @State private var jdText = ""
    @State private var gyText = ""
    @State private var gmText = ""
    @State private var gdText = ""
    @State private var resultText = ""
    @State private var showError = false
    @State private var errorMsg = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {

                    // کارت تاریخ امروز
                    VStack(spacing: 8) {
                        let t = ImperialCalendarEngine.todayJalali()
                        Text(ImperialCalendarEngine.weekdayNameOfToday())
                            .font(.title3)
                            .foregroundColor(.secondary)
                        Text("\(t.day.persianDigits) \(ImperialCalendarEngine.monthNames[t.month - 1])")
                            .font(.system(size: 44, weight: .bold))
                        HStack(spacing: 6) {
                            Text("\(ImperialCalendarEngine.imperialYear(fromJalali: t.year).persianDigits)")
                                .font(.title2.bold())
                            Text("سال \(ImperialCalendarEngine.imperialEraName)")
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                        Text("معادل شمسی: \(t.year.persianDigits)/\(t.month.persianDigits)/\(t.day.persianDigits)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(24)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(20)
                    .padding(.horizontal)

                    Picker("", selection: $tab) {
                        Text("شمسی → شاهنشاهی").tag(0)
                        Text("میلادی → شاهنشاهی").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    if tab == 0 {
                        inputRow(y: $jyText, m: $jmText, d: $jdText)
                        Button {
                            convertJalali()
                        } label: {
                            Label("تبدیل کن", systemImage: "arrow.left.arrow.right")
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.horizontal)
                    } else {
                        inputRow(y: $gyText, m: $gmText, d: $gdText)
                        Button {
                            convertGregorian()
                        } label: {
                            Label("تبدیل کن", systemImage: "arrow.left.arrow.right")
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.horizontal)
                    }

                    if !resultText.isEmpty {
                        Text(resultText)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(16)
                            .background(Color.accentColor.opacity(0.12))
                            .cornerRadius(16)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("تقویم شاهنشاهی")
            .alert("خطای ورودی", isPresented: $showError) {
                Button("باشد", role: .cancel) {}
            } message: {
                Text(errorMsg)
            }
        }
    }

    @ViewBuilder
    private func inputRow(y: Binding<String>, m: Binding<String>, d: Binding<String>) -> some View {
        HStack(spacing: 10) {
            field(placeholder: "سال", text: y)
            field(placeholder: "ماه", text: m)
            field(placeholder: "روز", text: d)
        }
        .padding(.horizontal)
    }

    private func field(placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .keyboardType(.numberPad)
            .multilineTextAlignment(.center)
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
    }

    // MARK: - منطق تبدیل‌ها
    private func convertJalali() {
        guard let jy = Int(jyText.replacingPersianDigits()),
              let jm = Int(jmText.replacingPersianDigits()),
              let jd = Int(jdText.replacingPersianDigits()) else {
            showErr("لطفاً سال، ماه و روز را به رقم وارد کنید.")
            return
        }
        guard jm >= 1 && jm <= 12 else {
            showErr("ماه باید بین ۱ تا ۱۲ باشد.")
            return
        }
        guard jd >= 1 && jd <= ImperialCalendarEngine.jalaliMonthLength(jy: jy, jm: jm) else {
            showErr("روز واردشده در این ماه معتبر نیست (اسفند سال کبیسه ۳۰ روزه است).")
            return
        }
        let g = ImperialCalendarEngine.jalaliToGregorian(jy: jy, jm: jm, jd: jd)
        resultText = "\(jd.persianDigits) \(ImperialCalendarEngine.monthNames[jm - 1]) " +
                     "\(ImperialCalendarEngine.imperialYear(fromJalali: jy).persianDigits) " +
                     "\(ImperialCalendarEngine.imperialEraName)\n" +
                     "میلادی: \(g.gd) \(monthNameEn(g.gm)) \(g.gy)"
    }

    private func convertGregorian() {
        guard let gy = Int(gyText.replacingPersianDigits()),
              let gm = Int(gmText.replacingPersianDigits()),
              let gd = Int(gdText.replacingPersianDigits()) else {
            showErr("لطفاً سال، ماه و روز میلادی را وارد کنید.")
            return
        }
        guard gm >= 1 && gm <= 12 else {
            showErr("ماه باید بین ۱ تا ۱۲ باشد.")
            return
        }
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        guard let date = cal.date(from: DateComponents(year: gy, month: gm, day: gd)),
              cal.dateComponents([.year, .month, .day], from: date).day == gd else {
            showErr("تاریخ میلادی واردشده وجود ندارد (مثلاً ۳۰ فوریه).")
            return
        }
        let j = ImperialCalendarEngine.gregorianToJalali(gy: gy, gm: gm, gd: gd)
        resultText = "\(j.day.persianDigits) \(ImperialCalendarEngine.monthNames[j.month - 1]) " +
                     "\(ImperialCalendarEngine.imperialYear(fromJalali: j.year).persianDigits) " +
                     "\(ImperialCalendarEngine.imperialEraName)\n" +
                     "شمسی: \(j.year.persianDigits)/\(j.month.persianDigits)/\(j.day.persianDigits)"
    }

    private func showErr(_ msg: String) {
        errorMsg = msg
        showError = true
    }

    private func monthNameEn(_ m: Int) -> String {
        let names = ["January","February","March","April","May","June",
                     "July","August","September","October","November","December"]
        return names[m - 1]
    }
}

extension String {
    func replacingPersianDigits() -> String {
        let fa = ["۰":"0","۱":"1","۲":"2","۳":"3","۴":"4","۵":"5","۶":"6","۷":"7","۸":"8","۹":"9",
                  "٠":"0","١":"1","٢":"2","٣":"3","٤":"4","٥":"5","٦":"6","٧":"7","٨":"8","٩":"9"]
        return self.map { fa[String($0)] ?? String($0) }.joined()
    }
}
