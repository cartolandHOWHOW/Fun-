import SwiftUI

struct TestSelectionView: View {
    // CEFR 等級測驗資料
    let testCategories = [
        TestCategory(title: "B1", subtitle: "中級", description: "工作學習應用", correctAnswers: 0, totalQuestions: 30, color: .orange),
        TestCategory(title: "B2", subtitle: "中級進階", description: "複雜主題討論", correctAnswers: 0, totalQuestions: 35, color: .purple),
        TestCategory(title: "C1", subtitle: "高級", description: "流利自然表達", correctAnswers: 0, totalQuestions: 40, color: .red),
        TestCategory(title: "C2", subtitle: "精通", description: "母語水準運用", correctAnswers: 0, totalQuestions: 45, color: .pink)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 漸層背景 - 與 QuizView 相同
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // 標題區域
                    VStack(spacing: 10) {
                        Text("CEFR 英語能力測驗")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("選擇您的目標等級開始測驗")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top, 20)
                    
                    // 2x3 網格佈局
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 15),
                        GridItem(.flexible(), spacing: 15)
                    ], spacing: 20) {
                        ForEach(testCategories.indices, id: \.self) { index in
                            CategoryButton(category: testCategories[index])
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // CEFR 說明
                    VStack(alignment: .leading, spacing: 8) {
                        Text("CEFR 等級說明")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("歐洲共同語言參考標準，從 A1 基礎到 C2 精通，幫您準確評估英語能力")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.leading)
                        Text("app尚不支援A1與A2")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                            
                    }
                    .padding(.horizontal, 20)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.black.opacity(0.2))
                    )
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .overlay(
                // 自定義返回按鈕
                VStack {
                    HStack {
                        NavigationLink(destination: MainMenuView()) {
                            HStack(spacing: 5) {
                                Image(systemName: "chevron.left")
                                    .font(.title2)
                                Text("返回")
                                    .font(.body)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.black.opacity(0.3))
                            )
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    Spacer()
                }
            )
        }
    }
}

struct CategoryButton: View {
    let category: TestCategory
    @State private var isPressed = false
    
    var body: some View {
        NavigationLink(destination: QuizView(testLevel: category.title)) {
            VStack(spacing: 12) {
                // 等級標題
                Text(category.title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                // 等級描述
                Text(category.subtitle)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.9))
                
                // 詳細說明
                Text(category.description)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                // 進度顯示
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("\(category.correctAnswers) / \(category.totalQuestions)")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                category.color.opacity(0.8),
                                category.color.opacity(0.6)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: category.color.opacity(0.3), radius: 8, x: 0, y: 4)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onTapGesture {
            // 觸覺反饋
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        }
        .pressEvents {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
        } onRelease: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = false
            }
        }
    }
}

struct TestCategory {
    let title: String
    let subtitle: String
    let description: String
    let correctAnswers: Int
    let totalQuestions: Int
    let color: Color
}

// 按鈕按壓效果的輔助擴展
extension View {
    func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        self.simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in onPress() }
                .onEnded { _ in onRelease() }
        )
    }
}

#Preview {
    NavigationStack {
        TestSelectionView()
    }
}
