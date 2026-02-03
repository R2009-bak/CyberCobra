import Foundation
import SwiftUI
import Combine

// MARK: - Уровни квеста
enum QuestLevel: Int, CaseIterable, Codable, Comparable {
    case l1 = 1
    case l2
    case l3
    case l4

    static func < (lhs: QuestLevel, rhs: QuestLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - Прогресс для одной темы
struct StudentTopicProgress: Identifiable, Codable {
    let id: String   // topic.id

    // тест
    var testAttempts: Int = 0
    var bestTestScore: Int = 0
    var isTestPassed: Bool = false

    // квест
    var completedLevels: Set<QuestLevel> = []
    var unlockedLevel: QuestLevel = .l1
    var isTopicCompleted: Bool = false
}

// MARK: - Хранилище прогресса студента
final class StudentProgressStore: ObservableObject {

    @Published private(set) var topicsProgress: [String : StudentTopicProgress] = [:] {
        didSet { save() }
    }

    private let storageKey = "student_progress_storage"

    init() {
        load()
    }

    // MARK: - Получить прогресс
    func progress(for topic: Topic) -> StudentTopicProgress {
        if let saved = topicsProgress[topic.id] {
            return saved
        }
        let new = StudentTopicProgress(id: topic.id)
        topicsProgress[topic.id] = new
        return new
    }

    // MARK: - Обновить прогресс
    func update(_ progress: StudentTopicProgress, for topic: Topic) {
        topicsProgress[topic.id] = progress
    }

    // MARK: - Проверки
    func isTestPassed(for topic: Topic) -> Bool {
        progress(for: topic).isTestPassed
    }

    func isTopicCompleted(for topic: Topic) -> Bool {
        progress(for: topic).isTopicCompleted
    }

    // MARK: - ✅ ЕДИНСТВЕННЫЙ ПРАВИЛЬНЫЙ МЕТОД ПРОХОЖДЕНИЯ УРОВНЯ
    func complete(level: QuestLevel, for topic: Topic) {

        var p = progress(for: topic)

        // если уже сохранён — ничего не делаем
        if p.completedLevels.contains(level) {
            return
        }

        // сохранить уровень
        p.completedLevels.insert(level)

        // 🔓 открыть следующий уровень
        if let next = QuestLevel(rawValue: level.rawValue + 1) {
            p.unlockedLevel = max(p.unlockedLevel, next)
        }

        // 🎉 финал темы
        if level == .l4 {
            p.isTopicCompleted = true
        }

        update(p, for: topic)

        print("✅ QUEST COMPLETED:", topic.id, "LEVEL:", level)
    }

    // MARK: - СБРОС
    func resetAll() {
        topicsProgress = [:]
    }

    // MARK: - СОХРАНЕНИЕ
    private func save() {
        guard let data = try? JSONEncoder().encode(topicsProgress) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
    
    // MARK: - Проверка прохождения уровня
    func isLevelCompleted(_ level: Level, topics: [Topic]) -> Bool {
        // topics уже соответствуют переданному уровню; просто проверяем завершение всех тем
        guard !topics.isEmpty else { return false }
        return topics.allSatisfy { topic in
            isTopicCompleted(for: topic)
        }
    }

    

    // MARK: - ЗАГРУЗКА
    private func load() {
        if
            let data = UserDefaults.standard.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode([String : StudentTopicProgress].self, from: data)
        {
            topicsProgress = decoded
        }
    }
}
