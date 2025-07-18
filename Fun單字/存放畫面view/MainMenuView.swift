import SwiftUI

// MARK: - MainMenuView
struct MainMenuView: View {
    @State private var animateTitle = false
    @State private var animateButtons = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 漸層背景 - 與其他頁面統一
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    // 應用標題
                    VStack(spacing: 15) {
                        Text("Fun單字")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .scaleEffect(animateTitle ? 1.0 : 0.8)
                            .opacity(animateTitle ? 1.0 : 0.0)
                            .animation(.easeOut(duration: 0.8), value: animateTitle)
                        
                        Text("讓學習英語變得有趣")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.8))
                            .scaleEffect(animateTitle ? 1.0 : 0.8)
                            .opacity(animateTitle ? 1.0 : 0.0)
                            .animation(.easeOut(duration: 0.8).delay(0.2), value: animateTitle)
                    }
                    .padding(.top, 50)
                    
                    Spacer()
                    
                    // 功能按鈕
                    VStack(spacing: 25) {
                        NavigationLink(destination: TestSelectionView()) {
                            MenuButton(
                                title: "開始測驗",
                                icon: "play.circle.fill",
                                description: "測試您的英語水平",
                                colors: [Color.orange, Color.red]
                            )
                        }
                        .scaleEffect(animateButtons ? 1.0 : 0.8)
                        .opacity(animateButtons ? 1.0 : 0.0)
                        .animation(.easeOut(duration: 0.6).delay(0.4), value: animateButtons)
                        
                        NavigationLink(destination: VocabStorageView()) {
                            MenuButton(
                                title: "單字書櫃",
                                icon: "book.fill",
                                description: "複習已學習的單字",
                                colors: [Color.green, Color.blue]
                            )
                        }
                        .scaleEffect(animateButtons ? 1.0 : 0.8)
                        .opacity(animateButtons ? 1.0 : 0.0)
                        .animation(.easeOut(duration: 0.6).delay(0.6), value: animateButtons)
                        
                        // 額外功能按鈕（可選）
                        Button(action: {
                            // 設定頁面或其他功能
                            print("設定功能")
                        }) {
                            MenuButton(
                                title: "學習統計",
                                icon: "chart.bar.fill",
                                description: "查看您的學習進度",
                                colors: [Color.purple, Color.pink]
                            )
                        }
                        .scaleEffect(animateButtons ? 1.0 : 0.8)
                        .opacity(animateButtons ? 1.0 : 0.0)
                        .animation(.easeOut(duration: 0.6).delay(0.8), value: animateButtons)
                    }
                    
                    Spacer()
                    
                    // 底部資訊
                    VStack(spacing: 8) {
                        HStack(spacing: 20) {
                            Label("CEFR 標準", systemImage: "checkmark.seal.fill")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                            
                            Label("智慧學習", systemImage: "brain.head.profile")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                            
                            Label("進度追蹤", systemImage: "chart.line.uptrend.xyaxis")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        Text("版本 1.0.0")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.bottom, 30)
                }
                .padding(.horizontal, 20)
            }
            .navigationBarHidden(true)
            .onAppear {
                withAnimation {
                    animateTitle = true
                    animateButtons = true
                }
            }
        }
    }
}

// MARK: - MenuButton Component
struct MenuButton: View {
    let title: String
    let icon: String
    let description: String
    let colors: [Color]
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 15) {
            // 圖標
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.2))
                )
            
            // 文字內容
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            // 箭頭
            Image(systemName: "chevron.right")
                .font(.title3)
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: colors),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: colors.first?.opacity(0.3) ?? .clear, radius: 8, x: 0, y: 4)
        )
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
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



#Preview {
    MainMenuView()
}
