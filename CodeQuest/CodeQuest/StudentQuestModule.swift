import SwiftUI
import UniformTypeIdentifiers

// MARK: - Кнопка уровня квеста
struct QuestLevelButton: View {
    let number: String
    let title: String
    let unlocked: Bool
    let completed: Bool
    let action: () -> Void

    var body: some View {
        Button {
            if unlocked { action() }
        } label: {
            HStack {
                Text(number)
                    .font(.title3.bold())
                    .frame(width: 40, height: 40)
                    .background(unlocked ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .clipShape(Circle())

                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)
                    if completed {
                        Text("Пройдено ✔")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }

                Spacer()

                Image(systemName: unlocked ? "chevron.right" : "lock.fill")
                    .foregroundColor(unlocked ? .blue : .gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
            )
        }
        .disabled(!unlocked)
    }
}

struct QuestMapView: View {

    let topic: Topic
    @ObservedObject var progressStore: StudentProgressStore

    @State private var goL1 = false
    @State private var goL2 = false
    @State private var goL3 = false
    @State private var goL4 = false
    
    private var quest: QuestModel {
        topic.quest
    }

    var body: some View {

        let progress = progressStore.progress(for: topic)
        let unlocked = progress.unlockedLevel

        ScrollView {
            VStack(spacing: 24) {

                Text("🌍 Приключение: \(topic.title)")
                    .font(.title2.bold())

                QuestLevelButton(
                    number: "L1",
                    title: "🧩 Викторина",
                    unlocked: true,
                    completed: progress.completedLevels.contains(.l1)
                ) { goL1 = true }

                QuestLevelButton(
                    number: "L2",
                    title: "🧱 Собери код",
                    unlocked: unlocked >= .l2,
                    completed: progress.completedLevels.contains(.l2)
                ) { goL2 = true }

                QuestLevelButton(
                    number: "L3",
                    title: "🔍 Найди совпадение",
                    unlocked: unlocked >= .l3,
                    completed: progress.completedLevels.contains(.l3)
                ) { goL3 = true }

                QuestLevelButton(
                    number: "L4",
                    title: "🐞 Исправь ошибку",
                    unlocked: unlocked >= .l4,
                    completed: progress.completedLevels.contains(.l4)
                ) { goL4 = true }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Карта квеста")
        .navigationBarTitleDisplayMode(.inline)

        Group {
            NavigationLink("", destination:
                StudentQuestL1View(topic: topic, quest: quest, progressStore: progressStore),
                isActive: $goL1
            ).hidden()

            NavigationLink("", destination:
                StudentQuestL2View(topic: topic, quest: quest, progressStore: progressStore),
                isActive: $goL2
            ).hidden()

            NavigationLink("", destination:
                StudentQuestL3View(topic: topic, quest: quest, progressStore: progressStore),
                isActive: $goL3
            ).hidden()

            NavigationLink("", destination:
                StudentQuestL4View(topic: topic, quest: quest, progressStore: progressStore),
                isActive: $goL4
            ).hidden()
        }
    }
}



// MARK: - L1 — Викторина
import SwiftUI

struct StudentQuestL1View: View {

    let topic: Topic
    let quest: QuestModel
    
    @ObservedObject var progressStore: StudentProgressStore

    @State private var index = 0
    @State private var score = 0
    @State private var selectedIndex: Int? = nil
    @State private var finished = false

    private var questions: [L1QuizQuestion] {
        quest.l1
    }


    var body: some View {
        VStack(spacing: 20) {

            if questions.isEmpty {
                Text("Для этой темы нет заданий")
                    .foregroundColor(.gray)
                Spacer()
            } else {

                Text("Вопрос \(index + 1) из \(questions.count)")
                    .font(.headline)

                Text(questions[index].question)
                    .font(.title3)

                ForEach(questions[index].options.indices, id: \.self) { i in
                    answerButton(
                        index: i,
                        text: questions[index].options[i],
                        correctIndex: questions[index].correctIndex
                    )
                }

                Spacer()

                Button(action: nextStep) {
                    Text(index == questions.count - 1 ? "Завершить" : "Далее")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedIndex == nil ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
                .disabled(selectedIndex == nil)
            }
        }
        .padding()
        .navigationTitle("L1 — Викторина")
        .alert("Результат", isPresented: $finished) {
            Button("OK") {}
        } message: {
            Text("Правильно: \(score) из \(questions.count)")
        }
    }

    private func answerButton(
        index: Int,
        text: String,
        correctIndex: Int
    ) -> some View {
        Button {
            selectedIndex = index
        } label: {
            HStack {
                Text(text)
                Spacer()
                if let selected = selectedIndex {
                    if index == correctIndex {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else if index == selected {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                }
            }
            .padding()
            .background(Color.blue.opacity(0.15))
            .cornerRadius(12)
        }
        .disabled(selectedIndex != nil)
    }

    private func nextStep() {
        if selectedIndex == questions[index].correctIndex {
            score += 1
        }

        if index < questions.count - 1 {
            index += 1
            selectedIndex = nil
        } else {
            progressStore.complete(level: .l1, for: topic)
            finished = true
        }
    }
}




import SwiftUI

struct StudentQuestL2View: View {

    let topic: Topic
    let quest: QuestModel
    @ObservedObject var progressStore: StudentProgressStore

    @State private var task: L2OrderTask?
    @State private var steps: [String] = []
    @State private var correctSteps: [String] = []

    @State private var finished = false
    @State private var failed = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                Text("🧱 Собери правильный порядок")
                    .font(.title3.bold())

                // 📋 Список шагов со стрелками
                VStack(spacing: 12) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        stepRow(step: step, index: index)
                    }
                }

                // ✅ Проверка
                Button("Проверить") {
                    checkAnswer()
                }
                .buttonStyle(.borderedProminent)
                .padding(.top)
            }
            .padding()
        }
        .onAppear(perform: loadTask)

        // 🎉 Успех
        .alert("Готово! 🎉", isPresented: $finished) {
            Button("Продолжить") {}
        } message: {
            Text("Ты правильно собрал порядок!")
        }

        // ❌ Ошибка
        .alert("Ошибка 😕", isPresented: $failed) {
            Button("Попробовать снова") {}
        } message: {
            Text("Порядок неверный. Попробуй ещё раз.")
        }
        .navigationTitle("L2 — Порядок")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Одна строка со стрелками
    private func stepRow(step: String, index: Int) -> some View {
        HStack {

            Text(step)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 6) {

                Button {
                    moveUp(index)
                } label: {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 16, weight: .bold))
                }
                .disabled(index == 0)

                Button {
                    moveDown(index)
                } label: {
                    Image(systemName: "arrow.down")
                        .font(.system(size: 16, weight: .bold))
                }
                .disabled(index == steps.count - 1)
            }
            .foregroundColor(.blue)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemGray6))
        )
    }

    // MARK: - Загрузка задания
    private func loadTask() {
        guard let task = quest.l2.first else { return }
        correctSteps = task.steps
        steps = task.steps.shuffled()
    }

    // MARK: - Проверка
    private func checkAnswer() {
        if steps == correctSteps {
            progressStore.complete(level: .l2, for: topic)
            finished = true
        } else {
            failed = true
        }
    }

    // MARK: - Перемещение
    private func moveUp(_ index: Int) {
        guard index > 0 else { return }
        withAnimation {
            steps.swapAt(index, index - 1)
        }
    }

    private func moveDown(_ index: Int) {
        guard index < steps.count - 1 else { return }
        withAnimation {
            steps.swapAt(index, index + 1)
        }
    }
}


// MARK: - L3 — Соедини пары
struct StudentQuestL3View: View {

    let topic: Topic
    let quest: QuestModel

    @ObservedObject var progressStore: StudentProgressStore

    @State private var pairs: [L3MatchPair] = []
    @State private var rightOptions: [String] = []

    @State private var leftSelected: String?
    @State private var matchedLeft: Set<String> = []
    @State private var matchedRight: Set<String> = []

    @State private var wrongLeft: String?
    @State private var wrongRight: String?

    @State private var correctCount = 0
    @State private var finished = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                Text("🔍 Найди совпадение")
                    .font(.title3.bold())

                if pairs.isEmpty {
                    Text("❗ Для этой темы нет заданий L3")
                        .foregroundColor(.red)
                    Spacer()
                } else {
                    HStack(alignment: .top, spacing: 20) {

                        // LEFT
                        VStack(spacing: 12) {
                            ForEach(pairs, id: \.id) { p in
                                Button {
                                    if !matchedLeft.contains(p.left) {
                                        leftSelected = p.left
                                        wrongLeft = nil
                                        wrongRight = nil
                                    }
                                } label: {
                                    Text(p.left)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(backgroundLeft(for: p.left))
                                        .cornerRadius(10)
                                        .foregroundColor(.black)
                                }
                                .disabled(matchedLeft.contains(p.left))
                            }
                        }

                        // RIGHT
                        VStack(spacing: 12) {
                            ForEach(rightOptions, id: \.self) { r in
                                Button {
                                    guard let left = leftSelected else { return }
                                    checkMatch(left: left, right: r)
                                } label: {
                                    Text(r)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(backgroundRight(for: r))
                                        .cornerRadius(10)
                                        .foregroundColor(.black)
                                }
                                .disabled(matchedRight.contains(r))
                            }
                        }
                    }
                }

                Spacer()
            }
            .padding()
        }
        .onAppear(perform: loadData)
        .alert("Молодец!", isPresented: $finished) {
            Button("Продолжить") { }
        } message: {
            Text("Ты нашёл все пары! (\(correctCount)/\(pairs.count))")
        }
        .navigationTitle("L3 — Соответствия")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - DATA
    private func loadData() {
        pairs = quest.l3
        rightOptions = quest.l3.map { $0.right }.shuffled()
    }

    // MARK: - MATCH
    private func checkMatch(left: String, right: String) {

        guard let match = pairs.first(where: { $0.left == left }) else { return }

        if match.right == right {
            matchedLeft.insert(left)
            matchedRight.insert(right)
            correctCount += 1
            leftSelected = nil
        } else {
            wrongLeft = left
            wrongRight = right

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                wrongLeft = nil
                wrongRight = nil
            }
        }

        // ✅ ЕДИНСТВЕННОЕ МЕСТО СОХРАНЕНИЯ
        if correctCount == pairs.count {
            progressStore.complete(level: .l3, for: topic)
            finished = true
        }
    }

    // MARK: - COLORS
    private func backgroundLeft(for left: String) -> Color {
        if matchedLeft.contains(left) { return .green.opacity(0.4) }
        if wrongLeft == left { return .red.opacity(0.4) }
        if leftSelected == left { return .blue.opacity(0.3) }
        return .blue.opacity(0.15)
    }

    private func backgroundRight(for right: String) -> Color {
        if matchedRight.contains(right) { return .green.opacity(0.4) }
        if wrongRight == right { return .red.opacity(0.4) }
        return .green.opacity(0.15)
    }
}

// MARK: - L4 — Исправь ошибку
import SwiftUI

// MARK: - L4 — Исправь ошибку
import SwiftUI

struct StudentQuestL4View: View {

    let topic: Topic
    let quest: QuestModel

    @ObservedObject var progressStore: StudentProgressStore

    @State private var taskIndex: Int = 0
    @State private var task: L4FixErrorTask?
    @State private var userCode: String = ""

    @State private var failed = false
    @State private var success = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                Text("🐞 Исправь ошибку в коде")
                    .font(.title3.bold())

                if let task {

                    // 🔢 Индикатор прогресса L4
                    Text("Задание \(taskIndex + 1) из \(quest.l4.count)")
                        .font(.caption)
                        .foregroundColor(.gray)

                    // 🧑‍💻 Редактор кода
                    CodeEditor(code: $userCode)

                    // ✅ Проверка
                    Button {
                        checkAnswer()
                    } label: {
                        Text("Проверить")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                    }

                } else {
                    Text("❗ Нет доступных заданий L4")
                        .foregroundColor(.red)
                }
            }
            .padding()
        }
        .navigationTitle("L4 — Исправь ошибку")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadTask()
        }

        // ❌ Ошибка
        .alert("Неверно", isPresented: $failed) {
            Button("Попробовать снова") { }
        } message: {
            Text("Код всё ещё содержит ошибку. Проверь внимательно.")
        }

        // ✅ Успех
        .alert("Отлично!", isPresented: $success) {
            Button("Готово") { }
        } message: {
            Text("Все задания уровня выполнены. Отличная работа! 🎉")
        }
    }

    // MARK: - Load Task
    private func loadTask() {
        guard quest.l4.indices.contains(taskIndex) else {
            task = nil
            return
        }

        task = quest.l4[taskIndex]
        userCode = task?.brokenCode ?? ""
    }

    // MARK: - Check Answer
    private func checkAnswer() {
        guard let task else { return }

        if normalize(userCode) == normalize(task.expectedCode) {

            // 👉 Если есть ещё задания — идём дальше
            if taskIndex < quest.l4.count - 1 {
                taskIndex += 1
                loadTask()
            } else {
                // ✅ Все L4-задания выполнены
                progressStore.complete(level: .l4, for: topic)
                success = true
            }

        } else {
            failed = true
        }
    }

    // MARK: - Normalize Code
    private func normalize(_ code: String) -> String {
        code
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: " ", with: "")
    }
}


struct CodeEditor: View {

    @Binding var code: String

    var body: some View {
        TextEditor(text: $code)
            .font(.system(.body, design: .monospaced))
            .padding()
            .frame(minHeight: 220)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.gray.opacity(0.3))
            )
    }
}


