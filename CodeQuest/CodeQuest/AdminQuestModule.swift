import SwiftUI
import Foundation

// =====================================================
// MARK: - ADMIN QUEST EDITOR (ENTRY POINT)
// =====================================================

import SwiftUI

struct AdminQuestEditorView: View {

    // =================================================
    // MARK: - Input
    // =================================================

    let topic: Topic
    let level: Level
    @ObservedObject var topicsStore: AdminTopicsStore

    // =================================================
    // MARK: - State
    // =================================================

    @Environment(\.dismiss) private var dismiss

    @State private var localQuest: QuestModel

    @State private var isGeneratingAI = false
    @State private var showQuestCountInput = false
    @State private var showAIGenerateConfirm = false

    // =================================================
    // MARK: - Init
    // =================================================

    init(topic: Topic, level: Level, topicsStore: AdminTopicsStore) {
        self.topic = topic
        self.level = level
        self.topicsStore = topicsStore
        _localQuest = State(initialValue: topic.quest)
    }

    // =================================================
    // MARK: - Body
    // =================================================

    var body: some View {
        NavigationStack {
            List {

                NavigationLink("🧠 L1 — Викторина") {
                    AdminL1EditorView(questions: $localQuest.l1)
                }

                NavigationLink("🧱 L2 — Собери порядок") {
                    AdminL2EditorView(tasks: $localQuest.l2)
                }

                NavigationLink("🔗 L3 — Соедини пары") {
                    AdminL3EditorView(pairs: $localQuest.l3)
                }

                NavigationLink("🐞 L4 — Исправь ошибку") {
                    AdminL4EditorView(tasks: $localQuest.l4)
                }
            }
            .navigationTitle("Квест: \(topic.title)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

                // 🤖 ИИ
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showAIGenerateConfirm = true
                    } label: {
                        Group {
                            if isGeneratingAI {
                                ProgressView()
                            } else {
                                Image(systemName: "sparkles")
                            }
                        }
                    }
                    .disabled(isGeneratingAI)
                }

                // 💾 Сохранить
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        saveQuest()
                        dismiss()
                    }
                }
            }
            .alert("Сгенерировать задания квеста?", isPresented: $showAIGenerateConfirm) {
                Button("Отмена", role: .cancel) {}
                Button("Сгенерировать", role: .destructive) {
                    // Present count input sheet; after confirm we call AI
                    showQuestCountInput = true
                }
            } message: {
                Text("Все задания L1–L4 будут перезаписаны.")
            }
            .sheet(isPresented: $showQuestCountInput) {
                QuestCountInputView { l1, l2, l3, l4 in
                    generateQuestWithAI(l1: l1, l2: l2, l3: l3, l4: l4)
                }
            }
        }
    }
    
    private func generateQuestWithAI(
        l1: Int,
        l2: Int,
        l3: Int,
        l4: Int
    ) {
        isGeneratingAI = true

        AIGenerator.shared.generateQuest(
            topic: topic.title,
            l1: l1,
            l2: l2,
            l3: l3,
            l4: l4
        ) { result in
            isGeneratingAI = false

            switch result {
            case .success(let quest):
                localQuest = quest   // 🔥 UI обновляется сразу

            case .failure(let error):
                print("AI quest error:", error)
            }
        }
    }


    // =================================================
    // MARK: - Save
    // =================================================

    private func saveQuest() {
        var updatedTopic = topic
        updatedTopic.quest = localQuest
        topicsStore.updateTopic(updatedTopic, level: level)
    }
}


/////////////////////////////////////////////////////////
// MARK: - L1 EDITOR
/////////////////////////////////////////////////////////

struct AdminL1EditorView: View {

    @Binding var questions: [L1QuizQuestion]

    var body: some View {
        List {
            ForEach(questions.indices, id: \.self) { index in
                NavigationLink {
                    AdminL1QuestionEditView(question: $questions[index])
                } label: {
                    Text(questions[index].question)
                        .lineLimit(1)
                }
            }
            .onDelete { questions.remove(atOffsets: $0) }

            Button("➕ Добавить вопрос") {
                questions.append(
                    L1QuizQuestion(
                        question: "",
                        options: ["", ""],
                        correctIndex: 0
                    )
                )
            }
        }
        .navigationTitle("L1 — Викторина")
    }
}

struct AdminL1QuestionEditView: View {

    @Binding var question: L1QuizQuestion

    var body: some View {
        Form {
            Section("Вопрос") {
                TextField("Текст вопроса", text: $question.question)
            }

            Section("Ответы") {
                ForEach(question.options.indices, id: \.self) { i in
                    HStack {
                        TextField(
                            "Ответ",
                            text: Binding(
                                get: { question.options[i] },
                                set: { question.options[i] = $0 }
                            )
                        )

                        Button {
                            question.correctIndex = i
                        } label: {
                            Image(systemName:
                                question.correctIndex == i
                                ? "checkmark.circle.fill"
                                : "circle"
                            )
                        }
                    }
                }

                Button("➕ Добавить вариант") {
                    question.options.append("")
                }
            }
        }
        .navigationTitle("Вопрос")
    }
}

/////////////////////////////////////////////////////////
// MARK: - L2 EDITOR
/////////////////////////////////////////////////////////

struct AdminL2EditorView: View {

    @Binding var tasks: [L2OrderTask]

    var body: some View {
        List {
            ForEach(tasks.indices, id: \.self) { i in
                NavigationLink {
                    AdminL2TaskEditView(task: $tasks[i])
                } label: {
                    Text("Задание \(i + 1)")
                }
            }
            .onDelete { tasks.remove(atOffsets: $0) }

            Button("➕ Добавить задание") {
                tasks.append(L2OrderTask(steps: ["", ""]))
            }
        }
        .navigationTitle("L2 — Порядок")
    }
}

struct AdminL2TaskEditView: View {

    @Binding var task: L2OrderTask

    var body: some View {
        List {
            ForEach(task.steps.indices, id: \.self) { i in
                TextField(
                    "Шаг",
                    text: Binding(
                        get: { task.steps[i] },
                        set: { task.steps[i] = $0 }
                    )
                )
            }
            .onDelete { task.steps.remove(atOffsets: $0) }

            Button("➕ Добавить шаг") {
                task.steps.append("")
            }
        }
        .navigationTitle("Редактор шагов")
    }
}

/////////////////////////////////////////////////////////
// MARK: - L3 EDITOR
/////////////////////////////////////////////////////////

struct AdminL3EditorView: View {

    @Binding var pairs: [L3MatchPair]

    var body: some View {
        List {
            ForEach(pairs.indices, id: \.self) { i in
                VStack(spacing: 8) {
                    TextField("Левая часть", text: $pairs[i].left)
                    TextField("Правая часть", text: $pairs[i].right)
                }
            }
            .onDelete { pairs.remove(atOffsets: $0) }

            Button("➕ Добавить пару") {
                pairs.append(L3MatchPair(left: "", right: ""))
            }
        }
        .navigationTitle("L3 — Пары")
    }
}

/////////////////////////////////////////////////////////
// MARK: - L4 EDITOR
/////////////////////////////////////////////////////////

struct AdminL4EditorView: View {

    @Binding var tasks: [L4FixErrorTask]

    var body: some View {
        List {

            ForEach(tasks.indices, id: \.self) { i in
                NavigationLink {
                    AdminL4TaskEditView(task: $tasks[i])
                } label: {
                    Text("Задание \(i + 1)")
                }
            }
            .onDelete { tasks.remove(atOffsets: $0) }

            Button("➕ Добавить задание") {
                tasks.append(
                    L4FixErrorTask(
                        brokenCode: "",
                        expectedCode: ""
                    )
                )
            }
        }
        .navigationTitle("L4 — Исправь ошибку")
    }
}


import SwiftUI

struct AdminL4TaskEditView: View {

    @Binding var task: L4FixErrorTask

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                brokenCodeSection
                correctCodeSection
            }
            .padding()
        }
        .navigationTitle("Задание L4")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Broken Code
    private var brokenCodeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Код с ошибкой", systemImage: "exclamationmark.triangle")
                .font(.headline)

            TextEditor(text: $task.brokenCode)
                .font(.system(.body, design: .monospaced))
                .padding(8)
                .frame(minHeight: 180)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
        }
    }

    // MARK: - Correct Code
    private var correctCodeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Правильный код", systemImage: "checkmark.circle")
                .font(.headline)

            TextEditor(text: $task.expectedCode)
                .font(.system(.body, design: .monospaced))
                .padding(8)
                .frame(minHeight: 180)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
        }
    }
}



import SwiftUI

struct QuestCountInputView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var l1 = "3"
    @State private var l2 = "2"
    @State private var l3 = "2"
    @State private var l4 = "1"

    let onConfirm: (_ l1: Int, _ l2: Int, _ l3: Int, _ l4: Int) -> Void

    var body: some View {
        NavigationStack {
            Form {

                section("L1 — Викторина", text: $l1)
                section("L2 — Порядок", text: $l2)
                section("L3 — Пары", text: $l3)
                section("L4 — Ошибка", text: $l4)
            }
            .navigationTitle("Генерация квеста")
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
    // MARK: - Helpers
    // =================================================

    private func section(_ title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading) {
            Text(title).font(.headline)
            TextField("Количество", text: text)
                .keyboardType(.numberPad)
        }
    }

    private var isValid: Bool {
        [l1, l2, l3, l4].allSatisfy {
            Int($0).map { $0 > 0 } ?? false
        }
    }

    private func confirm() {
        guard
            let l1 = Int(l1),
            let l2 = Int(l2),
            let l3 = Int(l3),
            let l4 = Int(l4)
        else { return }

        onConfirm(l1, l2, l3, l4)
        dismiss()
    }
}
