import SwiftUI
import AVFoundation

// MARK: - Data Models
struct VocabularyData: Codable {
    let vocabulary: [VocabularyItem]
}

struct VocabularyItem: Codable, Identifiable {
    let id = UUID()
    let englishWord: String
    let partOfSpeech: String
    let chineseMeaning: String
    let englishExample: String
    
    enum CodingKeys: String, CodingKey {
        case englishWord = "英文單字"
        case partOfSpeech = "詞性"
        case chineseMeaning = "中文意思"
        case englishExample = "英文例句"
    }
}

// MARK: - Quiz Question
struct QuizQuestion {
    let word: String
    let correctAnswer: String
    let options: [String]
    let example: String
}

// MARK: - Quiz View Model
class QuizViewModel: ObservableObject {
    @Published var questions: [QuizQuestion] = []
    @Published var currentQuestionIndex = 0
    @Published var score = 0
    @Published var showingResult = false
    @Published var selectedAnswer: String?
    @Published var isAnswered = false
    @Published var isLoading = true
    @Published var errorMessage: String?
    
    private var vocabularyItems: [VocabularyItem] = []
    private let speechSynthesizer = AVSpeechSynthesizer()
    private let testLevel: String
    
    init(testLevel: String = "B1") {
        self.testLevel = testLevel
        loadVocabulary()
    }
    
    func loadVocabulary() {
        // 檢查檔案是否存在
        guard let url = Bundle.main.url(forResource: "vocab", withExtension: "json") else {
            errorMessage = "找不到 vocab.json 檔案，請確認檔案已加入專案"
            isLoading = false
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            print("JSON 檔案大小: \(data.count) bytes") // 除錯用
            
            let vocabularyData = try JSONDecoder().decode(VocabularyData.self, from: data)
            self.vocabularyItems = vocabularyData.vocabulary
            print("成功載入 \(vocabularyItems.count) 個詞彙") // 除錯用
            
            generateQuestions()
            isLoading = false
        } catch let decodingError as DecodingError {
            print("JSON 解碼錯誤: \(decodingError)") // 除錯用
            errorMessage = "JSON 格式錯誤: \(decodingError.localizedDescription)"
            isLoading = false
        } catch {
            print("其他錯誤: \(error)") // 除錯用
            errorMessage = "讀取 JSON 檔案失敗: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func generateQuestions() {
        let shuffledItems = vocabularyItems.shuffled()
        questions = shuffledItems.prefix(10).map { item in
            var options = [item.chineseMeaning]
            
            // 隨機選擇其他選項
            let otherItems = vocabularyItems.filter { $0.englishWord != item.englishWord }
            let randomOptions = otherItems.shuffled().prefix(3).map { $0.chineseMeaning }
            options.append(contentsOf: randomOptions)
            
            return QuizQuestion(
                word: item.englishWord,
                correctAnswer: item.chineseMeaning,
                options: options.shuffled(),
                example: item.englishExample
            )
        }
    }
    
    func selectAnswer(_ answer: String) {
        selectedAnswer = answer
        isAnswered = true
        
        if answer == questions[currentQuestionIndex].correctAnswer {
            score += 1
        }
    }
    
    func nextQuestion() {
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            selectedAnswer = nil
            isAnswered = false
        } else {
            showingResult = true
        }
    }
    
    func restartQuiz() {
        currentQuestionIndex = 0
        score = 0
        selectedAnswer = nil
        isAnswered = false
        showingResult = false
        generateQuestions()
    }
    
    func speakWord(_ word: String) {
        // 停止當前朗讀
        speechSynthesizer.stopSpeaking(at: .immediate)
        
        let utterance = AVSpeechUtterance(string: word)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5 // 稍慢一點的語速
        utterance.volume = 1.0
        
        speechSynthesizer.speak(utterance)
    }
}

// MARK: - Main Quiz View
struct QuizView: View {
    let testLevel: String
    @StateObject private var viewModel: QuizViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(testLevel: String = "B1") {
        self.testLevel = testLevel
        self._viewModel = StateObject(wrappedValue: QuizViewModel(testLevel: testLevel))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if viewModel.isLoading {
                    LoadingView()
                } else if let errorMessage = viewModel.errorMessage {
                    ErrorView(message: errorMessage) {
                        viewModel.loadVocabulary()
                    }
                } else if viewModel.showingResult {
                    ResultView(score: viewModel.score, total: viewModel.questions.count) {
                        viewModel.restartQuiz()
                    }
                } else {
                    QuizContentView(viewModel: viewModel)
                }
            }
            .navigationTitle("\(testLevel) 英文測驗")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                            Text("返回")
                                .font(.body)
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Loading View
struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.5)
            Text("載入中...")
                .foregroundColor(.secondary)
                .padding(.top)
        }
    }
}

// MARK: - Error View
struct ErrorView: View {
    let message: String
    let retry: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("發生錯誤")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button("重新嘗試", action: retry)
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

// MARK: - Quiz Content View
struct QuizContentView: View {
    @ObservedObject var viewModel: QuizViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress Bar
            VStack {
                HStack {
                    Text("問題 \(viewModel.currentQuestionIndex + 1)/\(viewModel.questions.count)")
                        .font(.headline)
                    Spacer()
                    Text("分數: \(viewModel.score)")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                
                ProgressView(value: Double(viewModel.currentQuestionIndex + 1), total: Double(viewModel.questions.count))
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
            }
            .padding()
            
            // Question Card - 使用 ScrollView 確保內容不會被遮擋
            ScrollView {
                VStack(spacing: 20) {
                    if viewModel.currentQuestionIndex < viewModel.questions.count {
                        QuestionCard(
                            question: viewModel.questions[viewModel.currentQuestionIndex],
                            selectedAnswer: viewModel.selectedAnswer,
                            isAnswered: viewModel.isAnswered,
                            onSelectAnswer: viewModel.selectAnswer,
                            onSpeakWord: viewModel.speakWord
                        )
                    }
                    
                    // 在 ScrollView 內部加入一些額外空間
                    Color.clear.frame(height: 100)
                }
            }
            
            // Next Button - 固定在底部
            if viewModel.isAnswered {
                VStack {
                    Button(action: viewModel.nextQuestion) {
                        Text(viewModel.currentQuestionIndex == viewModel.questions.count - 1 ? "查看結果" : "下一題")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                }
                .background(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: -2)
            }
        }
    }
}

// MARK: - Question Card
struct QuestionCard: View {
    let question: QuizQuestion
    let selectedAnswer: String?
    let isAnswered: Bool
    let onSelectAnswer: (String) -> Void
    let onSpeakWord: (String) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Word with Speaker Button
            HStack {
                Text(question.word)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Button(action: {
                    onSpeakWord(question.word)
                }) {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .padding(8)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Example sentence
            Text(question.example)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            
            // Options
            VStack(spacing: 15) {
                ForEach(question.options, id: \.self) { option in
                    OptionButton(
                        text: option,
                        isSelected: selectedAnswer == option,
                        isCorrect: isAnswered && option == question.correctAnswer,
                        isWrong: isAnswered && selectedAnswer == option && option != question.correctAnswer,
                        isDisabled: isAnswered
                    ) {
                        if !isAnswered {
                            onSelectAnswer(option)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
}

// MARK: - Option Button
struct OptionButton: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool
    let isWrong: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.body)
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity)
                .padding()
                .background(backgroundColor)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(borderColor, lineWidth: 2)
                )
        }
        .disabled(isDisabled)
    }
    
    private var textColor: Color {
        if isCorrect {
            return .white
        } else if isWrong {
            return .white
        } else if isSelected {
            return .blue
        } else {
            return .primary
        }
    }
    
    private var backgroundColor: Color {
        if isCorrect {
            return .green
        } else if isWrong {
            return .red
        } else if isSelected {
            return .blue.opacity(0.1)
        } else {
            return .gray.opacity(0.1)
        }
    }
    
    private var borderColor: Color {
        if isCorrect {
            return .green
        } else if isWrong {
            return .red
        } else if isSelected {
            return .blue
        } else {
            return .gray.opacity(0.3)
        }
    }
}

// MARK: - Result View
struct ResultView: View {
    let score: Int
    let total: Int
    let onRestart: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Text("測驗完成！")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(spacing: 20) {
                Text("你的分數")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Text("\(score)/\(total)")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(scoreColor)
                
                Text(performanceText)
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(radius: 5)
            
            Button("重新開始", action: onRestart)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
        }
        .padding()
    }
    
    private var scoreColor: Color {
        let percentage = Double(score) / Double(total)
        if percentage >= 0.8 {
            return .green
        } else if percentage >= 0.6 {
            return .orange
        } else {
            return .red
        }
    }
    
    private var performanceText: String {
        let percentage = Double(score) / Double(total)
        if percentage >= 0.8 {
            return "太棒了！"
        } else if percentage >= 0.6 {
            return "不錯喔！"
        } else {
            return "再接再厲！"
        }
    }
}

// MARK: - Preview
struct QuizView_Previews: PreviewProvider {
    static var previews: some View {
        QuizView(testLevel: "B1")
    }
}
