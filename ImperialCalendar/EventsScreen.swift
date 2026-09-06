import SwiftUI

struct EventRowView: View {
    let e: CalendarEvent

    var body: some View {
        HStack(spacing: 8) {
            Circle().fill(e.category.color).frame(width: 9, height: 9)
            Text(e.day.persianDigits)
                .font(.subheadline.bold())
                .frame(width: 24, alignment: .leading)
            Text(e.title)
                .font(.subheadline)
            Spacer()
            Text(e.category.rawValue)
                .font(.caption2)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(e.category.color.opacity(0.14))
                .foregroundColor(e.category.color)
                .cornerRadius(6)
            if e.holiday {
                Text("تعطیل")
                    .font(.caption2.bold())
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.red.opacity(0.14))
                    .foregroundColor(.red)
                    .cornerRadius(6)
            }
        }
    }
}

struct EventsScreen: View {
    var onMenu: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                TopBar(title: "رویدادها", onMenu: onMenu)
                Text("جشن‌ها و بزرگداشت‌های سراسر سال (هر سال تکرار می‌شوند)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                ForEach(1...12, id: \.self) { m in
                    monthSection(m)
                }
            }
            .padding(.bottom, 28)
        }
        .background(Color(.systemGroupedBackground))
        .environment(\.layoutDirection, .rightToLeft)
    }

    private func monthSection(_ m: Int) -> some View {
        let evs = EventsStore.events(inMonth: m).sorted { $0.day < $1.day }
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(ImperialCalendarEngine.monthNames[m - 1]).font(.headline)
                Spacer()
                Text("\(evs.count.persianDigits) رویداد")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            if evs.isEmpty {
                Text("رویدادی ثبت نشده")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            } else {
                ForEach(evs) { EventRowView(e: $0) }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(18)
        .padding(.horizontal)
    }
}

struct AboutScreen: View {
    var onMenu: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                TopBar(title: "درباره", onMenu: onMenu)
                Image("Logo")
                    .resizable()
                    .frame(width: 110, height: 110)
                    .cornerRadius(24)
                    .padding(.top, 6)
                Text("گاه شمار شاهنشاهی")
                    .font(.title.bold())

                card(title: "گاه‌شماری چیست؟",
                     text: "سال یکم این گاه‌شمار به سال بنیان‌گذاری شاهنشاهی هخامنشی به دست کوروش بزرگ در ۵۵۹ پیش از میلاد برمی‌گردد. ماه‌ها و روزها دقیقاً همان تقویم خورشیدی ایران است و تنها شمار سال متفاوت است.")
                card(title: "چگونه محاسبه می‌شود؟",
                     text: "سال شاهنشاهی = سال هجری شمسی + ۱۱۸۰\nنمونه امروزی: ۱۴۰۵ شمسی = ۲۵۸۵ شاهنشاهی\nنمونه تاریخی: ۲۵۳۵ شاهنشاهی = ۱۳۵۵ شمسی (۱۹۷۶م) — سال‌هایی که این گاه‌شمار در دوره پهلوی رسمی شد.")
                card(title: "رویدادها",
                     text: "نوروز و شش‌گانه آن، سیزده‌بدر، اردیبهشت‌گان، خردادگان، تیرگان، مردادگان، مهرگان، آبان‌گان، آذرگان، یلدا، سده، اسفندگان و بزرگداشت‌های ملی و جهانی در این برنامه گنجانده شده است.")

                Text("نسخه ۲٫۰")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 28)
        }
        .background(Color(.systemGroupedBackground))
        .environment(\.layoutDirection, .rightToLeft)
    }

    private func card(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(18)
        .padding(.horizontal)
    }
}
