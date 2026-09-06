import SwiftUI

struct CalendarScreen: View {
    var onMenu: () -> Void

    @State private var selected = ImperialCalendarEngine.todayJalali()
    @State private var cursor = ImperialCalendarEngine.todayJalali()

    private let cols: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    private let weekDays = ["ش", "ی", "د", "س", "چ", "پ", "ج"]

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                TopBar(title: "گاه شمار شاهنشاهی", onMenu: onMenu)
                heroCard.padding(.horizontal)
                monthNav.padding(.horizontal)
                gridCard.padding(.horizontal)
                detailCard.padding(.horizontal)
            }
            .padding(.bottom, 28)
        }
        .background(Color(.systemGroupedBackground))
        .environment(\.layoutDirection, .rightToLeft)
    }

    // MARK: کارت امروز
    private var heroCard: some View {
        VStack(spacing: 6) {
            Image("Logo")
                .resizable()
                .frame(width: 64, height: 64)
                .cornerRadius(14)
                .padding(.bottom, 4)

            Text(ImperialCalendarEngine.weekdayNames[ImperialCalendarEngine.weekday0(of: selected)])
                .font(.title3)
                .foregroundColor(.secondary)

            Text("\(selected.day.persianDigits) \(ImperialCalendarEngine.monthNames[selected.month - 1])")
                .font(.system(size: 40, weight: .bold))

            HStack(spacing: 6) {
                Text(ImperialCalendarEngine.imperialYear(fromJalali: selected.year).persianDigits)
                    .font(.title2.bold())
                    .foregroundColor(.accentColor)
                Text("گاه شمار شاهنشاهی")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Text("شمسی: \(selected.year.persianDigits)/\(selected.month.persianDigits)/\(selected.day.persianDigits)")
                .font(.caption)
                .foregroundColor(.secondary)
            Text("میلادی: \(gregorianLong(of: selected))")
                .font(.caption)
                .foregroundColor(.secondary)

            let tEvs = EventsStore.events(month: selected.month, day: selected.day)
            if !tEvs.isEmpty {
                Divider().padding(.vertical, 4)
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(tEvs) { EventRowView(e: $0) }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(18)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(20)
    }

    private func gregorianLong(of j: JalaliDate) -> String {
        let g = ImperialCalendarEngine.jalaliToGregorian(jy: j.year, jm: j.month, jd: j.day)
        return "\(g.gd.persianDigits) \(ImperialCalendarEngine.gregorianMonthNames[g.gm - 1]) \(g.gy.persianDigits)"
    }

    // MARK: نوار ماه
    private var monthNav: some View {
        HStack {
            Button(action: prevMonth) {
                Image(systemName: "chevron.right")
                    .font(.title3).foregroundColor(.accentColor)
            }
            .buttonStyle(.plain)
            Spacer()
            VStack(spacing: 2) {
                Text("\(ImperialCalendarEngine.monthNames[cursor.month - 1]) \(ImperialCalendarEngine.imperialYear(fromJalali: cursor.year).persianDigits)")
                    .font(.title3.bold())
                Text("معادل میلادی: \(gregorianRange)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button(action: nextMonth) {
                Image(systemName: "chevron.left")
                    .font(.title3).foregroundColor(.accentColor)
            }
            .buttonStyle(.plain)
        }
    }

    private var gregorianRange: String {
        let g = ImperialCalendarEngine.jalaliToGregorian(jy: cursor.year, jm: cursor.month, jd: 15)
        return "\(ImperialCalendarEngine.gregorianMonthNames[g.gm - 1]) \(g.gy.persianDigits)"
    }

    private func prevMonth() {
        guard !(cursor.year <= 1 && cursor.month == 1) else { return }
        if cursor.month == 1 {
            cursor = JalaliDate(year: cursor.year - 1, month: 12, day: 1)
        } else {
            cursor = JalaliDate(year: cursor.year, month: cursor.month - 1, day: 1)
        }
    }

    private func nextMonth() {
        if cursor.month == 12 {
            cursor = JalaliDate(year: cursor.year + 1, month: 1, day: 1)
        } else {
            cursor = JalaliDate(year: cursor.year, month: cursor.month + 1, day: 1)
        }
    }

    // MARK: جدول ماه
    private var gridCard: some View {
        VStack(spacing: 6) {
            LazyVGrid(columns: cols, spacing: 4) {
                ForEach(0..<7, id: \.self) { i in
                    Text(weekDays[i])
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            LazyVGrid(columns: cols, spacing: 4) { gridCells }
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(20)
    }

    @ViewBuilder
    private var gridCells: some View {
        let lead = ImperialCalendarEngine.firstWeekday0OfMonth(jy: cursor.year, jm: cursor.month)
        let count = ImperialCalendarEngine.jalaliMonthLength(jy: cursor.year, jm: cursor.month)
        ForEach(0..<(lead + count), id: \.self) { i in
            if i < lead {
                Color.clear.frame(height: 44)
            } else {
                dayCell(day: i - lead + 1)
            }
        }
    }

    private func dayCell(day d: Int) -> some View {
        let isToday = d == selected.day && cursor.month == selected.month && cursor.year == selected.year
        let evs = EventsStore.events(month: cursor.month, day: d)
        return Button {
            selected = JalaliDate(year: cursor.year, month: cursor.month, day: d)
        } label: {
            VStack(spacing: 3) {
                Text(d.persianDigits)
                    .font(.subheadline.weight(isToday ? .bold : .regular))
                    .frame(width: 34, height: 34)
                    .background(isToday ? Color.accentColor : Color.clear)
                    .clipShape(Circle())
                    .foregroundColor(isToday ? Color.white : Color.primary)
                Circle()
                    .fill(dotColor(evs))
                    .frame(width: 5, height: 5)
                    .opacity(evs.isEmpty ? 0 : 1)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    private func dotColor(_ evs: [CalendarEvent]) -> Color {
        if evs.contains(where: { $0.holiday }) { return .red }
        return evs.first?.category.color ?? .clear
    }

    // MARK: جزئیات روز انتخاب‌شده
    private var detailCard: some View {
        let evs = EventsStore.events(month: selected.month, day: selected.day)
        return VStack(alignment: .leading, spacing: 10) {
            Text(ImperialCalendarEngine.longString(of: selected))
                .font(.headline)
            Text("\(ImperialCalendarEngine.imperialYear(fromJalali: selected.year).persianDigits) — گاه شمار شاهنشاهی")
                .font(.subheadline)
                .foregroundColor(.accentColor)
            Text("شمسی: \(selected.year.persianDigits)/\(selected.month.persianDigits)/\(selected.day.persianDigits)")
                .font(.caption)
                .foregroundColor(.secondary)
            Text("میلادی: \(gregorianLong(of: selected))")
                .font(.caption)
                .foregroundColor(.secondary)

            Divider()

            if evs.isEmpty {
                Text("رویدادی برای این روز ثبت نشده است.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            } else {
                ForEach(evs) { EventRowView(e: $0) }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(20)
    }
}
