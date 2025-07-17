//
//  ContentView.swift
//  Fun單字
//
//  Created by max on 2025/7/17.
//

import SwiftUI

struct MainMenuView: View {
    var body: some View {
            NavigationStack{
                VStack{
                    Text("Fun單字")
                        .font(.title)
                    NavigationLink(destination: TestSelectionView()){
                        Text("開始測驗")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth:200)
                            .background(.brown)
                            .cornerRadius(20)
                }
                    NavigationLink(destination: VocabStorageView()){
                        Text("單字書櫃")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth:200)
                            .background(.brown)
                            .cornerRadius(20)
                }

            }
        }
    }
}

#Preview {
    MainMenuView()
}
