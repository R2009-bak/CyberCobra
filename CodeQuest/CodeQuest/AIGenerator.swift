import Foundation

final class AIGenerator {

    static let shared = AIGenerator()
    private init() {}

    private let apiKey = "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"
    
    // =================================================
    // MARK: - THEORY
    // =================================================

    func generateTheory(
        topic: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let prompt = """
        Ты — преподаватель программирования для начинающих.

        ТЕМА: "\(topic)"
        ЯЗЫК: Python

        Сгенерируй ТЕОРИЮ СТРОГО в формате:

        Определение:
        <2–3 предложения>

        Синтаксис:
        <пример кода>

        Пример:
        <пример кода>
        <короткое объяснение>

        ПРАВИЛА:
        - Без markdown
        - Без списков
        - Без лишнего текста
        """

        callText(prompt, completion)
    }

    // =================================================
    // MARK: - TESTS
    // =================================================

    func generateTests(
        topic: String,
        count: Int,
        completion: @escaping (Result<[TestQuestion], Error>) -> Void
    ) {
        let prompt = """
        Ты — преподаватель Python для начинающих.

        ТЕМА УРОКА: "\(topic)"

        Сгенерируй РОВНО \(count) тестовых вопросов,
        которые ОТНОСЯТСЯ ТОЛЬКО К ЭТОЙ ТЕМЕ.

        ❗ ЗАПРЕЩЕНО:
        - общие вопросы по Python
        - вопросы про переменные, если тема не переменные
        - повторяющиеся вопросы

        Формат JSON (СТРОГО):

        [
          {
            "question": "string",
            "options": ["string", "string", "string", "string"],
            "correctIndex": number
          }
        ]

        ПРАВИЛА:
        - Только JSON
        - Без комментариев
        - Вопросы должны проверять понимание темы "\(topic)"
        """

        callJSON(prompt, completion)
    }


    // =================================================
    // MARK: - QUEST
    // =================================================

    func generateQuest(
        topic: String,
        l1: Int,
        l2: Int,
        l3: Int,
        l4: Int,
        completion: @escaping (Result<QuestModel, Error>) -> Void
    ) {
        let prompt = """
        Ты — преподаватель Python для начинающих.

        ТЕМА: "\(topic)"

        Сгенерируй обучающий квест.

        КОЛИЧЕСТВО ЗАДАНИЙ:
        - L1 (викторина): \(l1)
        - L2 (порядок): \(l2)
        - L3 (пары): \(l3)
        - L4 (исправь ошибку): \(l4)

        ФОРМАТ JSON (СТРОГО):

        {
          "l1": [
            {
              "question": "string",
              "options": ["string", "string", "string", "string"],
              "correctIndex": number
            }
          ],
          "l2": [
            {
              "steps": ["string", "string", "string"]
            }
          ],
          "l3": [
            {
              "left": "string",
              "right": "string"
            }
          ],
          "l4": [
            {
              "brokenCode": "string",
              "expectedCode": "string"
            }
          ]
        }

        ПРАВИЛА:
        - Верни ТОЛЬКО JSON
        - Без markdown
        - Без пояснений
        - Количество элементов должно ТОЧНО совпадать
        """

        callJSON(prompt, completion)
    }


    // =================================================
    // MARK: - CORE NETWORK
    // =================================================

    private func callText(
        _ prompt: String,
        _ completion: @escaping (Result<String, Error>) -> Void
    ) {
        call(prompt) { completion($0) }
    }

    private func callJSON<T: Decodable>(
        _ prompt: String,
        _ completion: @escaping (Result<T, Error>) -> Void
    ) {
        call(prompt) { result in
            switch result {
            case .success(let text):
                do {
                    let data = Data(text.utf8)
                    let decoded = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func call(
        _ prompt: String,
        _ completion: @escaping (Result<String, Error>) -> Void
    ) {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)

        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": "Ты преподаватель Python."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.3
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }

            guard
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let choices = json["choices"] as? [[String: Any]],
                let message = choices.first?["message"] as? [String: Any],
                let content = message["content"] as? String
            else {
                DispatchQueue.main.async {
                    completion(.failure(NSError()))
                }
                return
            }

            DispatchQueue.main.async {
                completion(.success(content.trimmingCharacters(in: .whitespacesAndNewlines)))
            }
        }.resume()
    }
}
