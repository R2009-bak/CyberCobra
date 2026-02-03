import Foundation
import SwiftUI
import Combine

// MARK: - L1 — Викторина
struct L1QuizQuestion: Identifiable, Codable {
    let id: String
    var question: String
    var options: [String]
    var correctIndex: Int

    init(
        id: String = UUID().uuidString,
        question: String,
        options: [String],
        correctIndex: Int
    ) {
        self.id = id
        self.question = question
        self.options = options
        self.correctIndex = correctIndex
    }

    enum CodingKeys: String, CodingKey {
        case question
        case options
        case correctIndex
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID().uuidString
        self.question = try container.decode(String.self, forKey: .question)
        self.options = try container.decode([String].self, forKey: .options)
        self.correctIndex = try container.decode(Int.self, forKey: .correctIndex)
    }
}

// MARK: - L2 — Собери порядок
struct L2OrderTask: Identifiable, Codable {
    let id: String
    var steps: [String]

    init(
        id: String = UUID().uuidString,
        steps: [String]
    ) {
        self.id = id
        self.steps = steps
    }

    enum CodingKeys: String, CodingKey {
        case steps
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID().uuidString
        self.steps = try container.decode([String].self, forKey: .steps)
    }
}


// MARK: - L3 — Соедини пары
struct L3MatchPair: Identifiable, Codable {
    let id: String
    var left: String
    var right: String

    init(
        id: String = UUID().uuidString,
        left: String,
        right: String
    ) {
        self.id = id
        self.left = left
        self.right = right
    }

    enum CodingKeys: String, CodingKey {
        case left
        case right
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID().uuidString
        self.left = try container.decode(String.self, forKey: .left)
        self.right = try container.decode(String.self, forKey: .right)
    }
}

// MARK: - L4 — Исправь ошибку
struct L4FixErrorTask: Identifiable, Codable {

    let id: String

    var brokenCode: String
    var expectedCode: String

    init(
        id: String = UUID().uuidString,
        brokenCode: String,
        expectedCode: String,
    ) {
        self.id = id
        self.brokenCode = brokenCode
        self.expectedCode = expectedCode
    }
    enum CodingKeys: String, CodingKey {
        case brokenCode
        case expectedCode
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID().uuidString
        self.brokenCode = try container.decode(String.self, forKey: .brokenCode)
        self.expectedCode = try container.decode(String.self, forKey: .expectedCode)
    }
}


// MARK: - QuestModel
struct QuestModel: Codable {
    var l1: [L1QuizQuestion] = []
    var l2: [L2OrderTask] = []
    var l3: [L3MatchPair] = []
    var l4: [L4FixErrorTask] = []


    static let empty = QuestModel()
}

struct Topic: Identifiable, Codable {
    let id: String
    var title: String
    var theory: String
    var tests: [TestQuestion]
    var quest: QuestModel
    let style: CharacterStyle
    let colorHue: Double
}


// ---------------------------------------------------------
// MARK: - LEVELS (basic, middle, advanced, olymp)
// ---------------------------------------------------------

enum Level: String, CaseIterable, Codable, Identifiable {
    case basic
    case middle
    case advanced
    case olymp

    var id: String { rawValue }

    var title: String {
        switch self {
        case .basic: return "Базовый уровень"
        case .middle: return "Средний уровень"
        case .advanced: return "Продвинутый уровень"
        case .olymp: return "Олимпиадный уровень"
        }
    }

    var icon: String {
        switch self {
        case .basic: return "leaf"
        case .middle: return "graduationcap"
        case .advanced: return "brain.head.profile"
        case .olymp: return "trophy"
        }
    }
}
extension Level {
    static func previous(of level: Level) -> Level? {
        switch level {
        case .basic: return nil
        case .middle: return .basic
        case .advanced: return .middle
        case .olymp: return .advanced
        }
    }
}


// ---------------------------------------------------------
// MARK: - TEST QUESTION MODEL
// ---------------------------------------------------------

struct TestQuestion: Identifiable, Codable, Equatable {
    let id: String
    var question: String
    var options: [String]
    var correctIndex: Int
    init(
        id: String = UUID().uuidString,
        question: String,
        options: [String],
        correctIndex: Int
    ) {
        self.id = id
        self.question = question
        self.options = options
        self.correctIndex = correctIndex
    }

    // 👇 ВАЖНО
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = UUID().uuidString   // ⬅️ генерируем сами
        self.question = try container.decode(String.self, forKey: .question)
        self.options = try container.decode([String].self, forKey: .options)
        self.correctIndex = try container.decode(Int.self, forKey: .correctIndex)
    }
}

final class QuestStore: ObservableObject {

    @Published var quests: [String : QuestModel] = [:] {
        didSet { save() }
    }

    private let storageKey = "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"

    init() {
        load()
    }

    func quest(for quest: String) -> QuestModel {
        quests[quest] ?? .empty
    }

    func updateQuest(_ quest: QuestModel, for topicId: String) {
        quests[topicId] = quest
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(quests) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private func load() {
        if
            let data = UserDefaults.standard.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode([String : QuestModel].self, from: data)
        {
            quests = decoded
        }
    }
}



// ---------------------------------------------------------
// MARK: - ADMIN TOPICS STORE (UserDefaults storage)
// ---------------------------------------------------------

final class AdminTopicsStore: ObservableObject {

    @Published var topicsByLevel: [Level: [Topic]] = [:] {
        didSet { save() }
    }

    private let storageKey = "topics_storage_key"

    init() { load() }

    // MARK: - CRUD

    func addTopic(_ title: String, to level: Level) {
        guard !title.isEmpty else { return }

        let topic = Topic(
            id: UUID().uuidString,
            title: title,
            theory: "",
            tests: [],
            quest: .empty,
            style: .robot,
            colorHue: Double.random(in: 0...1)
        )

        topicsByLevel[level, default: []].append(topic)
    }


    func updateTopic(_ topic: Topic, level: Level) {
        guard var topics = topicsByLevel[level] else { return }
        guard let index = topics.firstIndex(where: { $0.id == topic.id }) else { return }

        topics[index] = topic
        topicsByLevel[level] = topics
    }

    func updateTopicTitle(index: Int, level: Level, newTitle: String) {
        guard !newTitle.isEmpty else { return }
        topicsByLevel[level]?[index].title = newTitle
    }

    func deleteTopic(at index: Int, level: Level) {
        topicsByLevel[level]?.remove(at: index)
    }

    func moveTopic(from: Int, to: Int, level: Level) {
        guard
            var list = topicsByLevel[level],
            from >= 0, to >= 0,
            from < list.count, to < list.count
        else { return }

        let removed = list.remove(at: from)
        list.insert(removed, at: to)
        topicsByLevel[level] = list
    }

    // MARK: - RESET TO DEFAULT

    func resetToDefault() {
        topicsByLevel = defaultTopics()
    }

    // MARK: - SAVE & LOAD

    private func save() {
        guard let data = try? JSONEncoder().encode(topicsByLevel) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([Level: [Topic]].self, from: data)
        else {
            topicsByLevel = defaultTopics()
            return
        }

        topicsByLevel = decoded
    }

    // MARK: - DEFAULT TOPICS (BASIC + MIDDLE)

    private func defaultTopics() -> [Level: [Topic]] {
        [
            .basic: [
                Topic(
                    id: UUID().uuidString,
                    title: "Что такое программа",
                    theory: """
                    Программа - это подробная инструкция для компьютера.
                    Она состоит из команд, которые компьютер
                    выполняет строго по порядку.
                    Программы помогают:
                    — считать
                    — играть
                    — рисовать
                    — работать

                    Пример:

                    print("Привет, мир!")
                    """,
                    tests: [
                        TestQuestion(
                            id: UUID().uuidString,
                            question: "Что такое программа?",
                            options: [
                                "Инструкция для компьютера",
                                "Игра",
                                "Картинка",
                                "Видео"
                            ],
                            correctIndex: 0
                        ),
                        TestQuestion(
                            id: UUID().uuidString,
                            question: "Что НЕ является программой?",
                            options: [
                                "Игра",
                                "Калькулятор",
                                "Компьютер",
                                "Приложение"
                            ],
                            correctIndex: 2
                        )
                    ],
                    quest:  QuestModel(
                        l1: [
                            L1QuizQuestion(
                                question: "Что такое программа?",
                                options: [
                                    "Инструкция для компьютера",
                                    "Компьютерная игра",
                                    "Интернет-сайт",
                                    "Графический файл"
                                ],
                                correctIndex: 0
                            ),
                            L1QuizQuestion(
                                question: "Кто создаёт программы?",
                                options: [
                                    "Программисты",
                                    "Художники",
                                    "Музыканты",
                                    "Спортсмены"
                                ],
                                correctIndex: 0
                            )
                        ],
                        l2: [
                            L2OrderTask(
                                steps: [
                                    "Получить данные",
                                    "Обработать данные",
                                    "Вывести результат"
                                ]
                            )
                        ],
                        l3: [
                            L3MatchPair(left: "Код", right: "Набор команд"),
                            L3MatchPair(left: "Алгоритм", right: "Последовательность действий"),
                            L3MatchPair(left: "Компилятор", right: "Преобразует код в программу")
                        ],
                        l4: [
                            L4FixErrorTask(
                                brokenCode: """
                                print("Hello")
                                pritn("Error")
                                print("Done")
                                """,
                                expectedCode: """
                                print("Hello")
                                print("Error")
                                print("Done")
                                """
                            )
                        ]
                    ),
                    style: .robot,
                    colorHue: Double.random(in: 0...1)
                ),

                Topic(
                    id: UUID().uuidString,
                    title: "Переменные",
                    theory: """
                    Переменная — имя для хранения значения.
                    
                    В переменной можно хранить:
                    — число
                    — текст
                    — результат вычислений

                    У переменной есть имя и значение.

                    Пример в Python:
                    age = 15
                    name = "Аня"

                    Значение можно изменить:
                    age = 16
                    """,
                    tests: [
                        TestQuestion(
                            id: UUID().uuidString,
                            question: "Что такое переменная?",
                            options: [
                                "Имя для хранения значения",
                                "Команда вывода",
                                "Тип данных",
                                "Ошибка"
                            ],
                            correctIndex: 0
                        ),
                        TestQuestion(
                            id: UUID().uuidString,
                            question: "Что можно хранить в переменной?",
                            options: [
                                "Только числа",
                                "Только текст",
                                "Только команды",
                                "Числа и текст"
                            ],
                            correctIndex: 3
                        ),
                    ],
                    quest: QuestModel(
                        l1: [
                            L1QuizQuestion(
                                question: "Что такое переменная?",
                                options: [
                                    "Имя для хранения значения",
                                    "Команда вывода",
                                    "Ошибка в программе",
                                    "Файл"
                                ],
                                correctIndex: 0
                            ),
                            L1QuizQuestion(
                                question: "Что можно хранить в переменной?",
                                options: [
                                    "Только числа",
                                    "Только текст",
                                    "Числа и текст",
                                    "Только команды"
                                ],
                                correctIndex: 2
                            )
                        ],
                        l2: [
                            L2OrderTask(
                                steps: [
                                    "age = 10",
                                    "print(age)"
                                ]
                            )
                        ],
                        l3: [
                            L3MatchPair(left: "age = 10", right: "переменная age равна 10"),
                            L3MatchPair(left: "name = \"Аня\"", right: "переменная name хранит текст"),
                            L3MatchPair(left: "score = 5", right: "переменная score равна 5")
                        ],
                        l4: [
                            L4FixErrorTask(
                                brokenCode: """
                                age = 10
                                print(ag)
                                """,
                                expectedCode: """
                                age = 10
                                print(age)
                                """
                            )
                        ]
                    ),
                    
                    style: .robot,
                    colorHue: Double.random(in: 0...1)
                )
            ],

            .middle: [
                Topic(
                    id: UUID().uuidString,
                    title: "Функции",
                    theory: """
                    Функция - это блок кода, который выполняет определённую задачу.
                    Функции помогают не повторять один и тот же код много раз.

                    Функцию можно вызвать в любой момент программы.

                    В Python функция создаётся с помощью ключевого слова def.

                    Пример:
                    def greet():
                        print("Привет!")
                    greet()

                    В этом примере:
                    — def — объявляет функцию
                    — greet — имя функции
                    — () — параметры (пока пустые)
                    — : — начало тела функции
                    — код внутри функции пишется с отступом

                    Функции могут принимать параметры:
                    def greet(name):
                        print("Привет,", name)
                    greet("Аня")
                    greet("Петя")

                    Функции могут возвращать значение с помощью return:
                    def add(a, b):
                        return a + b

                    result = add(3, 5)
                    print(result)

                    Зачем нужны функции:
                    — чтобы не повторять код
                    — чтобы программа была понятной
                    — чтобы разбивать программу на части

                    """,
                    tests: [
                        TestQuestion(
                            id: UUID().uuidString,
                            question: "Что такое функция?",
                            options: [
                                "Блок кода, который можно вызывать",
                                "Переменная для хранения значения",
                                "Тип данных",
                                "Ошибка в программе"
                            ],
                            correctIndex: 0
                        ),
                        TestQuestion(
                            id: UUID().uuidString,
                            question: "Зачем нужны функции?",
                            options: [
                                "Чтобы хранить данные",
                                "Чтобы не повторять код",
                                "Чтобы выводить текст",
                                "Чтобы создавать переменные"
                            ],
                            correctIndex: 1
                        )

                    ],
                    quest: QuestModel(
                        l1: [
                            L1QuizQuestion(
                                question: "Что такое функция?",
                                options: [
                                    "Блок кода, который можно вызывать",
                                    "Переменная для хранения числа",
                                    "Ошибка в программе",
                                    "Тип данных"
                                ],
                                correctIndex: 0
                            ),
                            L1QuizQuestion(
                                question: "Зачем нужны функции?",
                                options: [
                                    "Чтобы программа была красивой",
                                    "Чтобы не повторять код",
                                    "Чтобы хранить данные",
                                    "Чтобы выводить текст"
                                ],
                                correctIndex: 1
                            )
                        ],
                        l2: [
                            L2OrderTask(
                                steps: [
                                    "def greet():",
                                    "    print(\"Привет\")",
                                    "greet()"
                                ]
                            )
                        ],
                        l3: [
                            L3MatchPair(left: "def", right: "ключевое слово для объявления функции"),
                            L3MatchPair(left: "()", right: "скобки для параметров функции"),
                            L3MatchPair(left: "return", right: "возвращает значение из функции")
                        ],
                        l4: [
                            L4FixErrorTask(
                                brokenCode: """
                                def hello()
                                    print("Hello")
                                hello()
                                """,
                                expectedCode: """
                                def hello():
                                    print("Hello")
                                hello()
                                """
                            )
                        ]

                    )
,
                    style: .robot,
                    colorHue: Double.random(in: 0...1)
                )
            ],

            .advanced: [],
            .olymp: []
        ]
    }
}

// ---------------------------------------------------------
// MARK: - THEORY EDITOR VIEW
// ---------------------------------------------------------

import SwiftUI

struct TheoryEditorView: View {

    // =================================================
    // MARK: - Input
    // =================================================

    let topicTitle: String
    let onSave: (String) -> Void

    // =================================================
    // MARK: - State
    // =================================================

    @State private var text: String
    @State private var isGenerating = false
    @State private var showGenerateConfirm = false

    @Environment(\.dismiss) private var dismiss

    // =================================================
    // MARK: - Init
    // =================================================

    init(
        topicTitle: String,
        theory: String,
        onSave: @escaping (String) -> Void
    ) {
        self.topicTitle = topicTitle
        self.onSave = onSave
        _text = State(initialValue: theory)
    }

    // =================================================
    // MARK: - Body
    // =================================================

    var body: some View {
        NavigationStack {
            VStack {
                TextEditor(text: $text)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3))
                    )
                    .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("Теория")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

                // ❌ Закрыть
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }

                // 🤖 ИИ
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showGenerateConfirm = true
                    } label: {
                        Group {
                            if isGenerating {
                                ProgressView()
                            } else {
                                Image(systemName: "sparkles")
                            }
                        }
                    }
                    .disabled(isGenerating)
                }

                // ✅ Сохранить
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        onSave(text)
                        dismiss()
                    }
                }
            }
            .alert("Сгенерировать теорию?", isPresented: $showGenerateConfirm) {
                Button("Отмена", role: .cancel) {}
                Button("Сгенерировать", role: .destructive) {
                    generateTheory()
                }
            } message: {
                Text("Текущая теория будет заменена.")
            }
        }
    }

    // =================================================
    // MARK: - AI
    // =================================================

    private func generateTheory() {
        isGenerating = true

        AIGenerator.shared.generateTheory(topic: topicTitle) { result in
            isGenerating = false

            switch result {
            case .success(let theory):
                text = theory   //

            case .failure(let error):
                print("AI theory error:", error)
            }
        }
    }

}


// ---------------------------------------------------------
// MARK: - TEST EDITOR (list of questions)
// ---------------------------------------------------------

struct TestEditorView: View {

    @Environment(\.dismiss) private var dismiss
    
    @State private var tests: [TestQuestion]
    let onSave: ([TestQuestion]) -> Void

    init(tests: [TestQuestion], onSave: @escaping ([TestQuestion]) -> Void) {
        _tests = State(initialValue: tests)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            List {

                // 🔹 Список вопросов
                ForEach(tests) { test in
                    NavigationLink {
                        SingleTestEditorView(test: binding(for: test))
                    } label: {
                        VStack(alignment: .leading) {
                            Text(test.question)
                                .font(.body)
                                .lineLimit(2)
                        }
                    }
                }
                .onDelete { offsets in
                    tests.remove(atOffsets: offsets)
                }

                // 🔹 Добавить новый вопрос
                Button {
                    addTest()
                } label: {
                    Label("Добавить вопрос", systemImage: "plus.circle")
                }
            }
            .navigationTitle("Тесты")
            .toolbar {

                // ❌ Закрыть без сохранения
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрыть") { dismiss() }
                }

                // ✅ Сохранить тесты
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        onSave(tests)
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Добавить вопрос
    private func addTest() {
        tests.append(
            TestQuestion(
                id: UUID().uuidString,
                question: "Новый вопрос",
                options: ["Ответ 1", "Ответ 2"],
                correctIndex: 0
            )
        )
    }

    // MARK: - Binding для редактирования одного вопроса
    private func binding(for test: TestQuestion) -> Binding<TestQuestion> {
        guard let index = tests.firstIndex(of: test) else {
            return .constant(test)
        }
        return $tests[index]
    }
}


// ---------------------------------------------------------
// MARK: - SINGLE TEST EDITOR (one question)
// ---------------------------------------------------------

struct SingleTestEditorView: View {

    @Binding var test: TestQuestion

    var body: some View {
        Form {

            // 🔹 Редактирование вопроса
            Section("Вопрос") {
                TextField("Введите вопрос", text: $test.question)
            }

            // 🔹 Варианты ответов
            Section("Варианты ответов") {
                ForEach(test.options.indices, id: \.self) { index in
                    HStack {

                        TextField("Ответ", text: Binding(
                            get: { test.options[index] },
                            set: { test.options[index] = $0 }
                        ))

                        // 🔘 выбор правильного ответа
                        Button {
                            test.correctIndex = index
                        } label: {
                            Image(systemName:
                                test.correctIndex == index
                                ? "checkmark.circle.fill"
                                : "circle"
                            )
                        }
                        .buttonStyle(.borderless)
                    }
                }

                // ➕ Добавить новый вариант
                Button {
                    test.options.append("Новый вариант")
                } label: {
                    Label("Добавить вариант", systemImage: "plus")
                }
            }
        }
        .navigationTitle("Редактор вопроса")
        .navigationBarTitleDisplayMode(.inline)
    }
}
// ---------------------------------------------------------
// MARK: - TOPIC ROW (карточка темы)
// ---------------------------------------------------------

import SwiftUI

struct TopicRow: View {

    // =================================================
    // MARK: - Input
    // =================================================

    let topic: Topic
    let index: Int
    let total: Int
    let level: Level
    let store: AdminTopicsStore

    // =================================================
    // MARK: - State
    // =================================================

    @State private var titleText: String
    @State private var isEditing = false

    @State private var showTheoryEditor = false
    @State private var showTestEditor = false
    @State private var showQuestEditor = false

    @State private var showTestCountInput = false
    @State private var isGeneratingAI = false

    // =================================================
    // MARK: - Init
    // =================================================

    init(topic: Topic, index: Int, total: Int, level: Level, store: AdminTopicsStore) {
        self.topic = topic
        self.index = index
        self.total = total
        self.level = level
        self.store = store
        _titleText = State(initialValue: topic.title)
    }

    // =================================================
    // MARK: - Body
    // =================================================

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // ================= Title =================
            HStack {
                if isEditing {
                    TextField("Название темы", text: $titleText)
                        .textFieldStyle(.roundedBorder)
                } else {
                    Text(topic.title)
                        .font(.headline)
                }
                Spacer()
            }

            // ================= Actions =================
            HStack(spacing: 16) {

                actionButton("Теория") {
                    showTheoryEditor = true
                }

                actionButton("Тест") {
                    if topic.tests.isEmpty {
                        showTestCountInput = true
                    } else {
                        showTestEditor = true
                    }
                }

                actionButton("Квест") {
                    showQuestEditor = true
                }


                // ⬆️
                Button {
                    store.moveTopic(from: index, to: index - 1, level: level)
                } label: {
                    Image(systemName: "chevron.up")
                }
                .disabled(index == 0)

                // ⬇️
                Button {
                    store.moveTopic(from: index, to: index + 1, level: level)
                } label: {
                    Image(systemName: "chevron.down")
                }
                .disabled(index == total - 1)

                // ✏️
                Button {
                    if isEditing {
                        var updated = topic
                        updated.title = titleText
                        store.updateTopic(updated, level: level)
                    }
                    isEditing.toggle()
                } label: {
                    Image(systemName: isEditing ? "checkmark" : "pencil")
                }

                // 🗑
                Button {
                    store.deleteTopic(at: index, level: level)
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemGray6))
        )

        // =================================================
        // MARK: - Sheets
        // =================================================

        .sheet(isPresented: $showTheoryEditor) {
            TheoryEditorView(
                topicTitle: topic.title,
                theory: topic.theory
            ) { newTheory in
                update { $0.theory = newTheory }
            }
        }

        .sheet(isPresented: $showTestCountInput) {
            TestCountInputView { count in
                generateTestsWithAI(count: count)
            }
        }

        .sheet(isPresented: $showTestEditor) {
            TestEditorView(tests: topic.tests) { newTests in
                update { $0.tests = newTests }
            }
        }

        .sheet(isPresented: $showQuestEditor) {
            AdminQuestEditorView(
                topic: topic,
                level: level,
                topicsStore: store
            )
        }
    }
    
    // MARK: - AI Logic   
    private func generateTestsWithAI(count: Int) {
        isGeneratingAI = true

        AIGenerator.shared.generateTests(
            topic: topic.title,
            count: count
        ) { result in
            isGeneratingAI = false

            switch result {
            case .success(let tests):
                var updated = topic
                updated.tests = tests
                store.updateTopic(updated, level: level)

                showTestCountInput = false
                showTestEditor = true

            case .failure(let error):
                print("AI tests error:", error)
            }
        }
    }

    // =================================================
    // MARK: - Helpers
    // =================================================

    private func update(_ block: (inout Topic) -> Void) {
        var updated = topic
        block(&updated)
        store.updateTopic(updated, level: level)
    }

    @ViewBuilder
    private func actionButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.blue)
        }
    }
}





// ---------------------------------------------------------
// MARK: - QUEST VIEW (temporary placeholder)
// ---------------------------------------------------------

struct QuestView: View {

    let topic: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {

            Text("Редактор квестов")
                .font(.title.bold())

            Text("Тема: \(topic)")
                .font(.title3)
                .foregroundColor(.purple)

            Text("Этот модуль пока не реализован.\nЗдесь будет конструктор квестов.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)

            Button {
                dismiss()
            } label: {
                Text("Закрыть")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.purple.opacity(0.15))
                    .cornerRadius(12)
            }

            Spacer()
        }
        .padding()
    }
}


// ---------------------------------------------------------
// MARK: - ADMIN LOGIN VIEW (Главный экран администратора)
// ---------------------------------------------------------

struct AdminLoginView: View {

    @StateObject private var store = AdminTopicsStore()
    @State private var newTopicText: [Level: String] = [:]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // Заголовок
                Text("Администратор")
                    .font(.largeTitle.bold())

                Text("Управление темами и заданиями")
                    .foregroundColor(.gray)

                // Перебор всех уровней
                ForEach(Level.allCases) { level in
                    levelSection(level)
                }

                // Сбросить к стандартным темам
                Button(role: .destructive) {
                    store.resetToDefault()
                } label: {
                    Text("Сбросить к стандартным темам")
                }
                .padding(.top, 10)
            }
            .padding()
        }
        .navigationTitle("Уровни")
        .navigationBarTitleDisplayMode(.inline)
    }

    // ---------------------------------------------------------
    // MARK: - Блок уровня (карточка уровня)
    // ---------------------------------------------------------

    private func levelSection(_ level: Level) -> some View {
        let topics = store.topicsByLevel[level, default: []]

        return VStack(alignment: .leading, spacing: 16) {

            // Заголовок уровня
            HStack(spacing: 8) {
                Image(systemName: level.icon)
                    .foregroundColor(.purple)
                Text(level.title)
                    .font(.headline)
            }

            // Поле + кнопка для добавления новой темы
            HStack {
                TextField(
                    "Новая тема...",
                    text: Binding(
                        get: { newTopicText[level, default: ""] },
                        set: { newTopicText[level] = $0 }
                    )
                )
                .textFieldStyle(.roundedBorder)

                Button("Добавить") {
                    let title = newTopicText[level, default: ""]
                    store.addTopic(title, to: level)
                    newTopicText[level] = ""
                }
                .buttonStyle(.bordered)
            }

            // Список тем
            if topics.isEmpty {
                Text("Тем пока нет")
                    .foregroundColor(.secondary)
            } else {
                VStack(spacing: 12) {
                    ForEach(Array(topics.enumerated()), id: \.element.id) { index, topic in
                        TopicRow(
                            topic: topic,
                            index: index,
                            total: topics.count,
                            level: level,
                            store: store
                        )
                    }
                    .id(topics.map(\.id))

                }
            }

        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
        )
    }
}


import SwiftUI

struct TestCountInputView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var text: String = ""
    @State private var errorText: String?

    let onConfirm: (Int) -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {

                Text("Введите количество вопросов")
                    .font(.headline)

                TextField("Например: 5", text: $text)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)

                if let errorText {
                    Text(errorText)
                        .foregroundColor(.red)
                        .font(.footnote)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Генерация теста")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Сгенерировать") {
                        confirm()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }

    // =================================================
    // MARK: - Validation
    // =================================================

    private var isValid: Bool {
        Int(text) != nil && (Int(text) ?? 0) > 0
    }

    private func confirm() {
        guard let count = Int(text), count > 0 else {
            errorText = "Введите положительное число"
            return
        }
        onConfirm(count)
       
    }
}
