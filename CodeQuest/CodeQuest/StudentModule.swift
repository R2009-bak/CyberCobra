import SwiftUI

// MARK: - 🏠 Главный экран ученика
struct StudentHomeView: View {

    @StateObject private var progressStore = StudentProgressStore()
    @StateObject private var topicsStore = AdminTopicsStore()
    @StateObject private var questStore = QuestStore()
    
    private var allTopics: [Topic] {
        Level.allCases.flatMap {
            topicsStore.topicsByLevel[$0] ?? []
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {

                    // 🎮 Логотип
                    VStack(spacing: 6) {
                        Text("🎮")
                            .font(.system(size: 60))

                        Text("CodeQuest")
                            .font(.largeTitle.bold())
                            .foregroundColor(.blue)
                    }

                    // MARK: - 🤖 Коллекция персонажей
                    VStack(alignment: .leading, spacing: 12) {

                        Text("🤖 Коллекция персонажей")
                            .font(.headline)
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(allTopics) { topic in
                                    let progress = progressStore.progress(for: topic)

                                    CharacterCardView(
                                        topic: topic,
                                        title: topic.title,
                                        progress: progress
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top)

                    // 👤 Профиль ученика
                    profileCard

                    // ▶️ Кнопки
                    NavigationLink {
                        StudentTopicsView(
                            topicsStore: topicsStore,
                            questStore: questStore
                        )
                        .environmentObject(progressStore)
                    } label: {
                        mainButton("📘 Темы обучения")
                    }

                    Spacer()
                }
                .padding()
            }
        }
    }

    // MARK: - Profile Card
    private var profileCard: some View {
        VStack(alignment: .leading, spacing: 14) {

            HStack {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 45))
                    .foregroundColor(.blue)

                VStack(alignment: .leading) {
                    Text("Ученик")
                        .font(.title2.bold())
                    Text("Продолжай учиться! ✨")
                        .foregroundColor(.gray)
                }

                Spacer()
            }

            Divider()

            ForEach(Level.allCases, id: \.self) { level in
                let topics = topicsStore.topicsByLevel[level, default: []]
                let completed = topics.filter {
                    progressStore.isTopicCompleted(for: $0)
                }.count

                HStack {
                    Text(level.title)
                    Spacer()
                    Text("\(completed)/\(topics.count)")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemGray6))
                .shadow(radius: 4)
        )
    }

    // MARK: - Buttons
    private func mainButton(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(16)
            .shadow(radius: 3)
    }
}

// MARK: - 📚 Список тем
struct StudentTopicsView: View {

    @EnvironmentObject var progressStore: StudentProgressStore
    @ObservedObject var topicsStore: AdminTopicsStore
    @ObservedObject var questStore: QuestStore

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {

                ForEach(Level.allCases, id: \.self) { level in
                    levelSection(level)
                }

                // 🔁 Сброс прогресса
                Button(role: .destructive) {
                    progressStore.resetAll()
                } label: {
                    Text("🔁 Сбросить весь прогресс")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
                .padding(.top, 20)
            }
            .padding()
        }
        .navigationTitle("Темы обучения")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Секция уровня
    private func levelSection(_ level: Level) -> some View {
        let topics = topicsStore.topicsByLevel[level, default: []]
        let unlocked = isLevelUnlocked(level)

        return VStack(alignment: .leading, spacing: 16) {

            HStack {
                Image(systemName: level.icon)
                    .foregroundColor(.purple)
                Text(level.title)
                    .font(.title3.bold())
                if !unlocked {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.gray)
                }
            }

            VStack(spacing: 12) {
                ForEach(topics.indices, id: \.self) { index in
                    if unlocked {
                            topicRow(topic: topics[index], index: index, topics: topics)
                                        } else {
                                            lockedCard(topics[index].title)
                                        }
                }
            }
        }
    }

    // MARK: - Строка темы
    @ViewBuilder
    private func topicRow(topic: Topic, index: Int, topics: [Topic]) -> some View {

        let locked = isTopicLocked(index: index, topics: topics)

        if locked {
            lockedCard(topic.title)
        } else {
            NavigationLink {
                StudentTheoryView(
                    topic: topic,
                    progressStore: progressStore,
                    questStore: questStore
                )
            } label: {
                unlockedCard(
                    topic.title,
                    completed: progressStore.isTopicCompleted(for: topic)
                )
            }
        }
    }

    // MARK: - UI карточек
    private func lockedCard(_ title: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Image(systemName: "lock.fill")
                .foregroundColor(.gray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray5))
        )
        .foregroundColor(.gray)
        .opacity(0.6)
    }

    private func unlockedCard(_ title: String, completed: Bool) -> some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
            Image(systemName: completed ? "checkmark.seal.fill" : "chevron.right")
                .foregroundColor(completed ? .green : .gray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
                .shadow(radius: 3)
        )
    }
    // MARK: - 🔐 Блокировка уровней
    private func isLevelUnlocked(_ level: Level) -> Bool {
        switch level {
        case .basic:
            return true

        case .middle:
            return isLevelCompleted(.basic)

        case .advanced:
            return isLevelCompleted(.middle)

        case .olymp:
            return isLevelCompleted(.advanced)
        }
    }
    
    private func isLevelCompleted(_ level: Level) -> Bool {
        let topics = topicsStore.topicsByLevel[level, default: []]
        guard !topics.isEmpty else { return false }
        return topics.allSatisfy {
            progressStore.isTopicCompleted(for: $0)
        }
    }
    
    // MARK: - ЛОГИКА БЛОКИРОВКИ
    private func isTopicLocked(index: Int, topics: [Topic]) -> Bool {
        if index == 0 { return false }
        let previous = topics[index - 1]
        return !progressStore.isTopicCompleted(for: previous)
    }
}

// MARK: - 📘 Теория
struct StudentTheoryView: View {

    let topic: Topic
    @ObservedObject var progressStore: StudentProgressStore
    @ObservedObject var questStore: QuestStore

    @State private var goToTest = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                Text(topic.title)
                    .font(.largeTitle.bold())

                Text(topic.theory)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray6))
                    )

                Button {
                    goToTest = true
                } label: {
                    primaryButton("📝 Пройти тест")
                }

                NavigationLink(
                    destination: StudentTestView(topic: topic, progressStore: progressStore),
                    isActive: $goToTest
                ) { EmptyView() }

                NavigationLink {
                    QuestMapView(
                        topic: topic,
                        progressStore: progressStore
                    )
                } label: {
                    primaryButton("🚀 Перейти к квесту")
                        .opacity(progressStore.isTestPassed(for: topic) ? 1 : 0.4)
                }
                .disabled(!progressStore.isTestPassed(for: topic))
            }
            .padding()
        }
        .navigationTitle("Теория")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func primaryButton(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(14)
    }
}

// MARK: - 🤖 Карточка персонажа
struct CharacterCardView: View {

    let topic: Topic
    let title: String
    let progress: StudentTopicProgress

    var body: some View {
        VStack(spacing: 10) {

            // 🟦 Карточка с персонажем
            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color.white.opacity(0.35), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.08), radius: 8, y: 6)

                CharacterProgressView(
                    progress: progress,
                    style: topic.style,
                    colorHue: topic.colorHue
                )
                .scaleEffect(0.92)
            }
            .frame(width: 104, height: 136)

            // 📝 Название темы
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 110, height: 34)

            // 🔢 Прогресс (SF Symbols)
            HStack(spacing: 4) {
                Image(systemName: progress.completedLevels.count == 4
                      ? "checkmark.seal.fill"
                      : "circle.dashed")
                    .font(.caption)
                    .foregroundColor(.blue)

                Text("\(progress.completedLevels.count) / 4")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.blue)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color(.systemBlue).opacity(0.15))
            )
        }
    }
}





import SwiftUI

struct StudentTestView: View {

    let topic: Topic

    @ObservedObject var progressStore: StudentProgressStore

    @State private var currentIndex = 0
    @State private var selectedIndex: Int? = nil
    @State private var showResult = false
    @State private var correctCount = 0

    var body: some View {
        VStack(spacing: 20) {

            Text("Тест: \(topic.title)")
                .font(.title2.bold())

            let question = topic.tests[currentIndex]

            // ❓ Вопрос
            Text(question.question)
                .font(.headline)
                .padding(.top, 8)

            // 🟦 Варианты
            ForEach(question.options.indices, id: \.self) { index in
                answerButton(text: question.options[index], index: index)
            }

            Spacer()

            // ▶️ Кнопка "Продолжить"
            Button(action: nextStep) {
                Text(currentIndex == topic.tests.count - 1 ? "Завершить" : "Далее")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedIndex == nil ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(14)
            }
            .disabled(selectedIndex == nil)
            .padding(.bottom, 20)
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
        .alert("Результат", isPresented: $showResult) {
            Button("OK") {
                if correctCount == topic.tests.count {
                    var p = progressStore.progress(for: topic)
                    p.isTestPassed = true
                    progressStore.update(p, for: topic)
                }

            }
        } message: {
            Text("Верно: \(correctCount) из \(topic.tests.count)")
        }
    }

    // MARK: - Answer Button
    private func answerButton(text: String, index: Int) -> some View {
        let question = topic.tests[currentIndex]

        return Button {
            selectedIndex = index
        } label: {
            HStack {
                Text(text)
                Spacer()

                if selectedIndex != nil {
                    if index == question.correctIndex {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else if index == selectedIndex {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
        }
        .disabled(selectedIndex != nil)
    }

    // MARK: - Переход к следующему вопросу
    private func nextStep() {
        if let selected = selectedIndex {
            if selected == topic.tests[currentIndex].correctIndex {
                correctCount += 1
            }
        }

        if currentIndex < topic.tests.count - 1 {
            // Следующий вопрос
            currentIndex += 1
            selectedIndex = nil
        } else {
            // Завершение теста
            showResult = true
        }
    }
}

// MARK: - 🔵 Универсальная красивая кнопка
struct PrimaryButton: View {

    let title: String
    var color: Color = .blue
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(color)
                .foregroundColor(.white)
                .cornerRadius(14)
                .shadow(radius: 3)
        }
    }
}

// MARK: - 📘 Карточка темы для StudentTopicsView
struct TopicCard: View {

    let title: String
    let locked: Bool
    let completed: Bool

    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()

            if locked {
                Image(systemName: "lock.fill")
                    .foregroundColor(.gray)
            } else if completed {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.green)
            } else {
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
                .shadow(radius: locked ? 0 : 3)
        )
        .foregroundColor(locked ? .gray : .primary)
        .opacity(locked ? 0.6 : 1)
    }
}


// MARK: - ✨ Анимационный модификатор появление
struct FadeRise: ViewModifier {
    let delay: Double

    @State private var visible = false

    func body(content: Content) -> some View {
        content
            .opacity(visible ? 1 : 0)
            .offset(y: visible ? 0 : 20)
            .animation(.easeOut(duration: 0.5).delay(delay), value: visible)
            .onAppear { visible = true }
    }
}

extension View {
    func animate(_ delay: Double = 0) -> some View {
        self.modifier(FadeRise(delay: delay))
    }
}


// MARK: - 🎨 Градиент фона (по желанию)
struct AppGradientBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(.systemGray6),
                Color(.systemGray5)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

// MARK: - 🔠 Заголовок секции
struct SectionTitle: View {
    var icon: String
    var title: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.purple)
            Text(title)
                .font(.title2.bold())
            Spacer()
        }
        .padding(.bottom, 6)
    }
}
