import SwiftUI

enum EventCategory: String {
    case ancient  = "باستانی"
    case national = "ملی"
    case global   = "جهانی"

    var color: Color {
        switch self {
        case .ancient:  return Color(red: 0.80, green: 0.51, blue: 0.20)
        case .national: return .blue
        case .global:   return .purple
        }
    }
}

struct CalendarEvent: Identifiable {
    let id = UUID()
    let month: Int
    let day: Int
    let title: String
    let category: EventCategory
    let holiday: Bool
}

enum EventsStore {
    static let all: [CalendarEvent] = [
        .init(month: 1, day: 1,  title: "نوروز — آغاز سال نو", category: .ancient, holiday: true),
        .init(month: 1, day: 2,  title: "نوروز — جشن زادروز آتش", category: .ancient, holiday: false),
        .init(month: 1, day: 3,  title: "نوروز — جشن زادروز آب", category: .ancient, holiday: false),
        .init(month: 1, day: 4,  title: "نوروز — جشن زادروز گیاه", category: .ancient, holiday: false),
        .init(month: 1, day: 5,  title: "نوروز — جشن زادروز زمین", category: .ancient, holiday: false),
        .init(month: 1, day: 6,  title: "زادروز اشو زرتشت", category: .ancient, holiday: false),
        .init(month: 1, day: 13, title: "سیزده‌بدر", category: .ancient, holiday: true),
        .init(month: 2, day: 1,  title: "بزرگداشت شیخ سعدی", category: .national, holiday: false),
        .init(month: 2, day: 2,  title: "جشن اردیبهشت‌گان", category: .ancient, holiday: false),
        .init(month: 2, day: 11, title: "روز جهانی کارگر", category: .global, holiday: false),
        .init(month: 2, day: 25, title: "روز پاسداشت زبان فارسی — بزرگداشت فردوسی", category: .national, holiday: false),
        .init(month: 3, day: 6,  title: "جشن خردادگان", category: .ancient, holiday: false),
        .init(month: 4, day: 13, title: "جشن تیرگان (آب‌پاشانک)", category: .ancient, holiday: false),
        .init(month: 5, day: 7,  title: "جشن مردادگان", category: .ancient, holiday: false),
        .init(month: 6, day: 4,  title: "جشن شهریورگان", category: .ancient, holiday: false),
        .init(month: 6, day: 27, title: "روز شعر و ادب فارسی", category: .national, holiday: false),
        .init(month: 7, day: 16, title: "جشن مهرگان — بزرگ‌جشن باستانی", category: .ancient, holiday: false),
        .init(month: 7, day: 20, title: "روز بزرگداشت حافظ", category: .national, holiday: false),
        .init(month: 8, day: 7,  title: "بزرگداشت مولانا", category: .national, holiday: false),
        .init(month: 8, day: 10, title: "جشن آبان‌گان", category: .ancient, holiday: false),
        .init(month: 9, day: 9,  title: "جشن آذرگان", category: .ancient, holiday: false),
        .init(month: 9, day: 30, title: "شب یلدا — شب چلّه", category: .ancient, holiday: false),
        .init(month: 10, day: 1, title: "جشن خرم‌روز (دی‌گان)", category: .ancient, holiday: false),
        .init(month: 10, day: 11, title: "آغاز سال نو میلادی", category: .global, holiday: false),
        .init(month: 11, day: 2, title: "جشن بهمن‌گان", category: .ancient, holiday: false),
        .init(month: 11, day: 10, title: "جشن سده — جشن بزرگ آتش", category: .ancient, holiday: false),
        .init(month: 12, day: 5, title: "جشن اسفندگان — بزرگداشت زمین و مادر", category: .ancient, holiday: false),
        .init(month: 12, day: 29, title: "روز ملی شدن صنعت نفت", category: .national, holiday: false)
    ]

    static func events(month: Int, day: Int) -> [CalendarEvent] {
        all.filter { $0.month == month && $0.day == day }
    }

    static func events(inMonth m: Int) -> [CalendarEvent] {
        all.filter { $0.month == m }
    }
}
