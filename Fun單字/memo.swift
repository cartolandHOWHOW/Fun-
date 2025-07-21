////
////  memo.swift
////  Fun單字
////
////  Created by max on 2025/7/21.
////
//import SwiftUI
//import AVFoundation
//
//// MARK: - 語音播放管理器
//class SpeechManager: ObservableObject {
//    private let synthesizer = AVSpeechSynthesizer()
//    @Published var isSpeaking = false
//    
//    init() {
//        // 設置音頻會話
//        do {
//            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
//            try AVAudioSession.sharedInstance().setActive(true)
//        } catch {
//            print("音頻會話設置失敗: \(error)")
//        }
//    }
//    
//    func speak(text: String, language: String = "en-US") {
//        // 停止當前播放
//        if synthesizer.isSpeaking {
//            synthesizer.stopSpeaking(at: .immediate)
//        }
//        
//        let utterance = AVSpeechUtterance(string: text)
//        utterance.voice = AVSpeechSynthesisVoice(language: language)
//        utterance.rate = 0.5 // 語速調慢一點
//        utterance.volume = 1.0
//        
//        isSpeaking = true
//        synthesizer.speak(utterance)
//        
//        // 設置完成回調
//        DispatchQueue.main.asyncAfter(deadline: .now() + Double(text.count) * 0.1 + 1.0) {
//            self.isSpeaking = false
//        }
//    }
//    
//    func stopSpeaking() {
//        synthesizer.stopSpeaking(at: .immediate)
//        isSpeaking = false
//    }
//}
//
//// MARK: - 數據模型
//struct QuizQuestion: Codable, Identifiable {
//    let id = UUID()
//    let question: String
//    let options: [String]
//    let correctAnswer: Int
//    let explanation: String?
//    
//    enum CodingKeys: String, CodingKey {
//        case question, options, correctAnswer, explanation
//    }
//}
//
//// MARK: - 單字項目結構
//struct VocabItem: Codable, Identifiable {
//    var id = UUID()
//    let english_word: String
//    let part_of_speech: String
//    let chinese_meaning: String
//    let example_sentence: String
//}
//
//// MARK: - 難度級別枚舉
//enum DifficultyLevel: String, CaseIterable {
//    case b1 = "B1Level"
//    case b2 = "B2Level"
//    case c1 = "C1Level"
//    case c2 = "C2Level"
//    
//    var displayName: String {
//        switch self {
//        case .b1: return "B1級"
//        case .b2: return "B2級"
//        case .c1: return "C1級"
//        case .c2: return "C2級"
//        }
//    }
//    
//    var fileName: String {
//        return self.rawValue + ".json"
//    }
//}
//
//// MARK: - 數據加載器
//class QuizDataLoader: ObservableObject {
//    @Published var questions: [QuizQuestion] = []
//    @Published var currentQuestionIndex = 0
//    @Published var selectedAnswers: [Int?] = []
//    @Published var score = 0
//    @Published var isLoading = false
//    @Published var errorMessage: String?
//    
//    func loadQuestions(for level: DifficultyLevel) {
//        isLoading = true
//        errorMessage = nil
//        
//        guard let url = Bundle.main.url(forResource: level.rawValue, withExtension: "json") else {
//            errorMessage = "找不到 \(level.fileName) 檔案"
//            isLoading = false
//            return
//        }
//        
//        do {
//            let data = try Data(contentsOf: url)
//            let vocabItems = try JSONDecoder().decode([VocabItem].self, from: data)
//            let allOptions = vocabItems.map { $0.chinese_meaning }
//            
//            let questions: [QuizQuestion] = vocabItems.shuffled().prefix(10).map { item in
//                var options = [item.chinese_meaning]
//                let otherOptions = allOptions.filter { $0 != item.chinese_meaning }.shuffled().prefix(3)
//                options.append(contentsOf: otherOptions)
//                options.shuffle()
//                let correctIndex = options.firstIndex(of: item.chinese_meaning) ?? 0
//                
//                return QuizQuestion(
//                    question: "\(item.english_word)",
//                    options: options,
//                    correctAnswer: correctIndex,
//                    explanation: item.example_sentence
//                )
//            }
//            
//            DispatchQueue.main.async {
//                self.questions = questions
//                self.selectedAnswers = Array(repeating: nil, count: questions.count)
//                self.currentQuestionIndex = 0
//                self.score = 0
//                self.isLoading = false
//            }
//        } catch {
//            DispatchQueue.main.async {
//                self.errorMessage = "載入數據時發生錯誤: \(error.localizedDescription)"
//                self.isLoading = false
//            }
//        }
//    }
//    
//    func selectAnswer(_ answerIndex: Int) {
//        guard currentQuestionIndex < selectedAnswers.count else { return }
//        selectedAnswers[currentQuestionIndex] = answerIndex
//    }
//    
//    func nextQuestion() {
//        if currentQuestionIndex < questions.count - 1 {
//            currentQuestionIndex += 1
//        }
//    }
//    
//    func previousQuestion() {
//        if currentQuestionIndex > 0 {
//            currentQuestionIndex -= 1
//        }
//    }
//    
//    func calculateScore() {
//        score = 0
//        for (index, question) in questions.enumerated() {
//            if let selectedAnswer = selectedAnswers[index],
//               selectedAnswer == question.correctAnswer {
//                score += 1
//            }
//        }
//    }
//    
//    func resetQuiz() {
//        currentQuestionIndex = 0
//        selectedAnswers = Array(repeating: nil, count: questions.count)
//        score = 0
//    }
//}
//
//// MARK: - 主頁面
//struct ContentView: View {
//    @State private var animateTitle = false
//    @State private var animateButtons = false
//    
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                // 漸層背景
//                LinearGradient(
//                    gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
//                    startPoint: .topLeading,
//                    endPoint: .bottomTrailing
//                )
//                .ignoresSafeArea()
//                
//                VStack(spacing: 40) {
//                    // 應用標題
//                    VStack(spacing: 15) {
//                        Text("Fun單字")
//                            .font(.system(size: 48, weight: .bold, design: .rounded))
//                            .foregroundColor(.white)
//                            .scaleEffect(animateTitle ? 1.0 : 0.8)
//                            .opacity(animateTitle ? 1.0 : 0.0)
//                            .animation(.easeOut(duration: 0.8), value: animateTitle)
//                        
//                        Text("讓學習英語變得有趣")
//                            .font(.title3)
//                            .foregroundColor(.white.opacity(0.8))
//                            .scaleEffect(animateTitle ? 1.0 : 0.8)
//                            .opacity(animateTitle ? 1.0 : 0.0)
//                            .animation(.easeOut(duration: 0.8).delay(0.2), value: animateTitle)
//                    }
//                    .padding(.top, 50)
//                    
//                    Spacer()
//                    
//                    // 功能按鈕
//                    VStack(spacing: 25) {
//                        NavigationLink(destination: TestSelectionView()) {
//                            MenuButton(
//                                title: "開始測驗",
//                                icon: "play.circle.fill",
//                                description: "測試您的英語水平",
//                                colors: [Color.orange, Color.red]
//                            )
//                        }
//                        .scaleEffect(animateButtons ? 1.0 : 0.8)
//                        .opacity(animateButtons ? 1.0 : 0.0)
//                        .animation(.easeOut(duration: 0.6).delay(0.4), value: animateButtons)
//                        
//                        NavigationLink(destination: VocabStorageView()) {
//                            MenuButton(
//                                title: "單字書櫃",
//                                icon: "book.fill",
//                                description: "複習已學習的單字",
//                                colors: [Color.green, Color.blue]
//                            )
//                        }
//                        .scaleEffect(animateButtons ? 1.0 : 0.8)
//                        .opacity(animateButtons ? 1.0 : 0.0)
//                        .animation(.easeOut(duration: 0.6).delay(0.6), value: animateButtons)
//                        
//                        NavigationLink(destination: LearningStatsView()) {
//                            MenuButton(
//                                title: "學習統計",
//                                icon: "chart.bar.fill",
//                                description: "查看您的學習進度",
//                                colors: [Color.purple, Color.pink]
//                            )
//                        }
//                        .scaleEffect(animateButtons ? 1.0 : 0.8)
//                        .opacity(animateButtons ? 1.0 : 0.0)
//                        .animation(.easeOut(duration: 0.6).delay(0.8), value: animateButtons)
//                    }
//                    
//                    Spacer()
//                    
//                    // 底部資訊
//                    VStack(spacing: 8) {
//                        HStack(spacing: 20) {
//                            Label("CEFR 標準", systemImage: "checkmark.seal.fill")
//                                .font(.caption)
//                                .foregroundColor(.white.opacity(0.7))
//                            
//                            Label("智慧學習", systemImage: "brain.head.profile")
//                                .font(.caption)
//                                .foregroundColor(.white.opacity(0.7))
//                            
//                            Label("進度追蹤", systemImage: "chart.line.uptrend.xyaxis")
//                                .font(.caption)
//                                .foregroundColor(.white.opacity(0.7))
//                        }
//                        
//                        Text("版本 1.0.0")
//                            .font(.caption2)
//                            .foregroundColor(.white.opacity(0.5))
//                    }
//                    .padding(.bottom, 30)
//                }
//                .padding(.horizontal, 20)
//            }
//            .navigationBarHidden(true)
//            .onAppear {
//                withAnimation {
//                    animateTitle = true
//                    animateButtons = true
//                }
//            }
//        }
//    }
//}
//
//// MARK: - 測驗難度選擇視圖
//struct TestSelectionView: View {
//    @State private var selectedLevel: DifficultyLevel? = nil
//    @State private var navigateToQuiz = false
//
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                // 漸層背景
//                LinearGradient(
//                    gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
//                    startPoint: .topLeading,
//                    endPoint: .bottomTrailing
//                )
//                .ignoresSafeArea()
//                
//                VStack(spacing: 40) {
//                    Text("選擇難度級別")
//                        .font(.largeTitle)
//                        .fontWeight(.bold)
//                        .foregroundColor(.white)
//                        .padding(.top, 40)
//                    
//                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
//                        ForEach(DifficultyLevel.allCases, id: \.self) { level in
//                            Button(action: {
//                                selectedLevel = level
//                                navigateToQuiz = true
//                            }) {
//                                VStack(spacing: 12) {
//                                    Image(systemName: "brain.head.profile")
//                                        .font(.system(size: 40))
//                                        .foregroundColor(.white)
//                                    
//                                    Text(level.displayName)
//                                        .font(.headline)
//                                        .fontWeight(.semibold)
//                                        .foregroundColor(.white)
//                                }
//                                .frame(maxWidth: .infinity, minHeight: 120)
//                                .background(
//                                    RoundedRectangle(cornerRadius: 20)
//                                        .fill(Color.white.opacity(0.2))
//                                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
//                                )
//                            }
//                        }
//                    }
//                    .padding(.horizontal)
//                    
//                    Spacer()
//                }
//                .padding()
//            }
//            .navigationTitle("選擇難度")
//            .navigationBarTitleDisplayMode(.inline)
//            .navigationDestination(isPresented: $navigateToQuiz) {
//                QuizView(level: selectedLevel ?? .b1)
//            }
//        }
//    }
//}
//
//// MARK: - 測驗視圖
//struct QuizView: View {
//    @StateObject private var dataLoader = QuizDataLoader()
//    @StateObject private var speechManager = SpeechManager()
//    @State private var showingResults = false
//    let level: DifficultyLevel
//    
//    var body: some View {
//        ZStack {
//            // 漸層背景
//            LinearGradient(
//                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
//                startPoint: .topLeading,
//                endPoint: .bottomTrailing
//            )
//            .ignoresSafeArea()
//            
//            Group {
//                if dataLoader.isLoading {
//                    ProgressView("載入中...")
//                        .font(.title2)
//                        .foregroundColor(.white)
//                } else if let errorMessage = dataLoader.errorMessage {
//                    VStack(spacing: 20) {
//                        Image(systemName: "exclamationmark.triangle")
//                            .font(.system(size: 50))
//                            .foregroundColor(.red)
//                        
//                        Text(errorMessage)
//                            .font(.headline)
//                            .foregroundColor(.white)
//                            .multilineTextAlignment(.center)
//                        
//                        Button("重試") {
//                            dataLoader.loadQuestions(for: level)
//                        }
//                        .buttonStyle(.borderedProminent)
//                    }
//                    .padding()
//                } else if dataLoader.questions.isEmpty {
//                    Text("沒有找到題目")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                } else {
//                    QuizContentView(dataLoader: dataLoader, speechManager: speechManager, showingResults: $showingResults)
//                }
//            }
//        }
//        .navigationTitle("\(level.displayName) 測驗")
//        .navigationBarTitleDisplayMode(.inline)
//        .onAppear {
//            dataLoader.loadQuestions(for: level)
//        }
//        .sheet(isPresented: $showingResults) {
//            QuizResultsView(dataLoader: dataLoader) {
//                dataLoader.resetQuiz()
//                showingResults = false
//            }
//        }
//    }
//}
//
//// MARK: - 測驗內容視圖
//struct QuizContentView: View {
//    @ObservedObject var dataLoader: QuizDataLoader
//    @ObservedObject var speechManager: SpeechManager
//    @Binding var showingResults: Bool
//
//    @State private var selectedOption: Int? = nil
//    @State private var isAnswering = false
//    @State private var showResultColor = false
//
//    var currentQuestion: QuizQuestion {
//        dataLoader.questions[dataLoader.currentQuestionIndex]
//    }
//
//    var body: some View {
//        VStack(spacing: 20) {
//            // 進度條
//            VStack(spacing: 8) {
//                ProgressView(value: Double(dataLoader.currentQuestionIndex + 1),
//                           total: Double(dataLoader.questions.count))
//                    .progressViewStyle(LinearProgressViewStyle(tint: .white))
//                Text("第 \(dataLoader.currentQuestionIndex + 1) 題 / 共 \(dataLoader.questions.count) 題")
//                    .font(.caption)
//                    .foregroundColor(.white.opacity(0.8))
//            }
//
//            // 題目和發音按鈕
//            HStack(spacing: 15) {
//                Text(currentQuestion.question)
//                    .font(.title2)
//                    .fontWeight(.medium)
//                    .foregroundColor(.white)
//                    .multilineTextAlignment(.center)
//                
//                // 發音按鈕
//                Button(action: {
//                    speechManager.speak(text: currentQuestion.question)
//                }) {
//                    Image(systemName: speechManager.isSpeaking ? "speaker.wave.3.fill" : "speaker.wave.2.fill")
//                        .font(.title2)
//                        .foregroundColor(.white)
//                        .frame(width: 44, height: 44)
//                        .background(
//                            Circle()
//                                .fill(Color.white.opacity(0.2))
//                                .overlay(
//                                    Circle()
//                                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
//                                )
//                        )
//                        .scaleEffect(speechManager.isSpeaking ? 1.1 : 1.0)
//                        .animation(.easeInOut(duration: 0.2), value: speechManager.isSpeaking)
//                }
//                .disabled(speechManager.isSpeaking)
//            }
//            .padding(.horizontal)
//
//            // 選項
//            VStack(spacing: 12) {
//                ForEach(Array(currentQuestion.options.enumerated()), id: \.offset) { index, option in
//                    Button(action: {
//                        if isAnswering { return }
//                        isAnswering = true
//                        selectedOption = index
//                        dataLoader.selectAnswer(index)
//                        let isCorrect = index == currentQuestion.correctAnswer
//                        if isCorrect {
//                            // 答對直接跳下一題
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
//                                goToNext()
//                            }
//                        } else {
//                            // 答錯顯示顏色，1秒後跳下一題
//                            showResultColor = true
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                                showResultColor = false
//                                goToNext()
//                            }
//                        }
//                    }) {
//                        HStack {
//                            Text(option)
//                                .font(.body)
//                                .foregroundColor(.primary)
//                                .multilineTextAlignment(.leading)
//                            Spacer()
//                            if selectedOption == index {
//                                Image(systemName: "checkmark.circle.fill")
//                                    .foregroundColor(.blue)
//                            }
//                        }
//                        .padding()
//                        .background(
//                            RoundedRectangle(cornerRadius: 10)
//                                .fill(buttonColor(index: index))
//                        )
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 10)
//                                .stroke(selectedOption == index ? Color.blue : Color.clear, lineWidth: 2)
//                        )
//                    }
//                    .buttonStyle(PlainButtonStyle())
//                    .disabled(isAnswering)
//                }
//            }
//
//            Spacer()
//        }
//        .padding()
//        .onChange(of: dataLoader.currentQuestionIndex) { _, _ in
//            // 當題目變更時，自動播放單字發音
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                speechManager.speak(text: currentQuestion.question)
//            }
//        }
//        .onAppear {
//            // 第一次進入時也播放發音
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                speechManager.speak(text: currentQuestion.question)
//            }
//        }
//    }
//
//    private func goToNext() {
//        if dataLoader.currentQuestionIndex == dataLoader.questions.count - 1 {
//            dataLoader.calculateScore()
//            showingResults = true
//        } else {
//            dataLoader.nextQuestion()
//            selectedOption = nil
//            isAnswering = false
//        }
//    }
//
//    private func buttonColor(index: Int) -> Color {
//        guard let selected = selectedOption else {
//            return Color.white.opacity(0.9)
//        }
//        if showResultColor {
//            if index == selected && selected != currentQuestion.correctAnswer {
//                return Color.red.opacity(0.6) // 答錯紅色
//            }
//            if index == currentQuestion.correctAnswer {
//                return Color.green.opacity(0.6) // 正確綠色
//            }
//        }
//        if selected == index {
//            return Color.blue.opacity(0.2)
//        }
//        return Color.white.opacity(0.9)
//    }
//}
//
//// MARK: - 結果視圖
//struct QuizResultsView: View {
//    @ObservedObject var dataLoader: QuizDataLoader
//    let onRestart: () -> Void
//    
//    var scorePercentage: Double {
//        guard !dataLoader.questions.isEmpty else { return 0 }
//        return Double(dataLoader.score) / Double(dataLoader.questions.count) * 100
//    }
//    
//    var body: some View {
//        NavigationView {
//            ZStack {
//                // 漸層背景
//                LinearGradient(
//                    gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
//                    startPoint: .topLeading,
//                    endPoint: .bottomTrailing
//                )
//                .ignoresSafeArea()
//                
//                VStack(spacing: 30) {
//                    // 分數顯示
//                    VStack(spacing: 10) {
//                        Text("測驗完成！")
//                            .font(.title)
//                            .fontWeight(.bold)
//                            .foregroundColor(.white)
//                        
//                        Text("\(dataLoader.score) / \(dataLoader.questions.count)")
//                            .font(.system(size: 48, weight: .bold))
//                            .foregroundColor(scorePercentage >= 70 ? .green : .orange)
//                        
//                        Text("正確率: \(Int(scorePercentage))%")
//                            .font(.headline)
//                            .foregroundColor(.white.opacity(0.8))
//                    }
//                    
//                    // 成績評語
//                    VStack(spacing: 12) {
//                        Image(systemName: scorePercentage >= 90 ? "star.fill" :
//                              scorePercentage >= 70 ? "hand.thumbsup.fill" : "hand.wave.fill")
//                            .font(.system(size: 50))
//                            .foregroundColor(scorePercentage >= 90 ? .yellow :
//                                            scorePercentage >= 70 ? .green : .white)
//                        
//                        Text(scorePercentage >= 90 ? "優秀！" :
//                             scorePercentage >= 70 ? "良好！" : "繼續努力！")
//                            .font(.title2)
//                            .fontWeight(.medium)
//                            .foregroundColor(.white)
//                    }
//                    
//                    Spacer()
//                    
//                    // 按鈕
//                    VStack(spacing: 15) {
//                        Button("重新開始") {
//                            onRestart()
//                        }
//                        .buttonStyle(.borderedProminent)
//                        .frame(maxWidth: .infinity)
//                        
//                        Button("查看詳細答案") {
//                            // 這裡可以導航到詳細答案頁面
//                        }
//                        .buttonStyle(.bordered)
//                        .frame(maxWidth: .infinity)
//                    }
//                }
//                .padding()
//            }
//            .navigationTitle("測驗結果")
//            .navigationBarTitleDisplayMode(.inline)
//        }
//    }
//}
//
//// MARK: - 單字書櫃視圖
//struct VocabStorageView: View {
//    @State private var searchText = ""
//    @State private var vocabItems: [VocabItem] = []
//    @State private var selectedLevel: DifficultyLevel = .b1
//    
//    var filteredItems: [VocabItem] {
//        if searchText.isEmpty {
//            return vocabItems
//        } else {
//            return vocabItems.filter {
//                $0.english_word.lowercased().contains(searchText.lowercased()) ||
//                $0.chinese_meaning.contains(searchText)
//            }
//        }
//    }
//    
//    var body: some View {
//        NavigationView {
//            ZStack {
//                // 漸層背景
//                LinearGradient(
//                    gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
//                    startPoint: .topLeading,
//                    endPoint: .bottomTrailing
//                )
//                .ignoresSafeArea()
//                
//                VStack {
//                    // 搜尋欄
//                    HStack {
//                        Image(systemName: "magnifyingglass")
//                            .foregroundColor(.gray)
//                        
//                        TextField("搜尋單字...", text: $searchText)
//                            .textFieldStyle(RoundedBorderTextFieldStyle())
//                    }
//                    .padding()
//                    
//                    // 難度選擇
//                    Picker("難度", selection: $selectedLevel) {
//                        ForEach(DifficultyLevel.allCases, id: \.self) { level in
//                            Text(level.displayName).tag(level)
//                        }
//                    }
//                    .pickerStyle(SegmentedPickerStyle())
//                    .padding(.horizontal)
//                    
//                    // 單字列表
//                    List(filteredItems) { item in
//                        VStack(alignment: .leading, spacing: 8) {
//                            HStack {
//                                Text(item.english_word)
//                                    .font(.headline)
//                                    .fontWeight(.semibold)
//                                
//                                Spacer()
//                                
//                                Text(item.part_of_speech)
//                                    .font(.caption)
//                                    .padding(.horizontal, 8)
//                                    .padding(.vertical, 4)
//                                    .background(Color.blue.opacity(0.2))
//                                    .cornerRadius(8)
//                            }
//                            
//                            Text(item.chinese_meaning)
//                                .font(.subheadline)
//                                .foregroundColor(.secondary)
//                            
//                            Text(item.example_sentence)
//                                .font(.caption)
//                                .foregroundColor(.secondary)
//                                .italic()
//                        }
//                        .padding(.vertical, 4)
//                    }
//                    .background(Color.clear)
//                }
//            }
//            .navigationTitle("單字書櫃")
//            .navigationBarTitleDisplayMode(.inline)
//            .onAppear {
//                loadVocabItems()
//            }
//            .onChange(of: selectedLevel) { _, newValue in
//                loadVocabItems()
//            }
//        }
//    }
//    
//    private func loadVocabItems() {
//        guard let url = Bundle.main.url(forResource: selectedLevel.rawValue, withExtension: "json") else {
//            return
//        }
//        
//        do {
//            let data = try Data(contentsOf: url)
//            let items = try JSONDecoder().decode([VocabItem].self, from: data)
//            vocabItems = items
//        } catch {
//            print("載入單字數據時發生錯誤: \(error)")
//        }
//    }
//}
//
//// MARK: - 學習統計視圖
//struct LearningStatsView: View {
//    var body: some View {
//        NavigationView {
//            ZStack {
//                // 漸層背景
//                LinearGradient(
//                    gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
//                    startPoint: .topLeading,
//                    endPoint: .bottomTrailing
//                )
//                .ignoresSafeArea()
//                
//                VStack(spacing: 30) {
//                    // 統計卡片
//                    VStack(spacing: 20) {
//                        StatCard(title: "總測驗次數", value: "12", icon: "play.circle.fill")
//                        StatCard(title: "平均分數", value: "85%", icon: "chart.bar.fill")
//                        StatCard(title: "學習天數", value: "7", icon: "calendar")
//                        StatCard(title: "掌握單字", value: "142", icon: "book.fill")
//                    }
//                    
//                    Spacer()
//                    
//                    Text("持續學習，進步更快！")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                        .multilineTextAlignment(.center)
//                }
//                .padding()
//            }
//            .navigationTitle("學習統計")
//            .navigationBarTitleDisplayMode(.inline)
//        }
//    }
//}
//
//// MARK: - 統計卡片
//struct StatCard: View {
//    let title: String
//    let value: String
//    let icon: String
//    
//    var body: some View {
//        HStack {
//            Image(systemName: icon)
//                .font(.system(size: 24))
//                .foregroundColor(.white)
//                .frame(width: 40, height: 40)
//                .background(
//                    Circle()
//                        .fill(Color.white.opacity(0.2))
//                )
//            
//            VStack(alignment: .leading) {
//                Text(title)
//                    .font(.caption)
//                    .foregroundColor(.white.opacity(0.8))
//                
//                Text(value)
//                    .font(.title2)
//                    .fontWeight(.bold)
//                    .foregroundColor(.white)
//            }
//            
//            Spacer()
//        }
//        .padding()
//        .background(
//            RoundedRectangle(cornerRadius: 15)
//                .fill(Color.white.opacity(0.1))
//        )
//    }
//}
//
//// MARK: - 選單按鈕組件
//struct MenuButton: View {
//    let title: String
//    let icon: String
//    let description: String
//    let colors: [Color]
//
//    var body: some View {
//        HStack(spacing: 15) {
//            // 圖標
//            Image(systemName: icon)
//                .font(.system(size: 24))
//                .foregroundColor(.white)
//                .frame(width: 40
//                    .background(
//                        Circle()
//                            .fill(Color.white.opacity(0.2))
//                    )
//
//                // 文字內容
//                VStack(alignment: .leading, spacing: 4) {
//                    Text(title)
//                        .font(.title2)
//                        .fontWeight(.semibold)
//                        .foregroundColor(.white)
//
//                    Text(description)
//                        .font(.caption)
//                        .foregroundColor(.white.opacity(0.8))
//                }
//
//                Spacer()
//
//                // 箭頭
//                Image(systemName: "chevron.right")
//                    .font(.title3)
//                    .foregroundColor(.white.opacity(0.6))
//            }
//            .padding(.horizontal, 20)
//            .padding(.vertical, 18)
//            .background(
//                RoundedRectangle(cornerRadius: 20)
//                    .fill(
//                        LinearGradient(
//                            gradient: Gradient(colors: colors),
//                            startPoint: .leading,
//                            endPoint: .trailing
//                        )
//                    )
//                    .shadow(color: colors.first?.opacity(0.3) ?? .clear, radius: 8, x: 0, y: 4)
//            )
//            // 移除以下兩行，讓 NavigationLink 處理點擊效果
//            // .scaleEffect(isPressed ? 0.95 : 1.0)
//            // .animation(.easeInOut(duration: 0.1), value: isPressed)
//            // 移除 onTapGesture 區塊
//            // .onTapGesture {
//            //     isPressed = true
//            //     DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            //         isPressed = false
//            //     }
//            // }
//        }
//    }
