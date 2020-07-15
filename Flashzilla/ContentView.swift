//
//  ContentView.swift
//  Flashzilla
//
//  Created by Chris Wu on 7/8/20.
//  Copyright © 2020 Chris Wu. All rights reserved.
//

import SwiftUI

let startingTime = 100

struct ContentView: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var scale: CGFloat = 1
    @State private var cards = [Card](repeating: Card.example, count: 10)
    @State private var timeRemaining = startingTime
    @State private var isActive = true
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geo in  // not in lesson
            ZStack {
                Image("background")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("Time: \(self.timeRemaining)")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(Color.black)
                                .opacity(0.75)
                    )
                    
                    ZStack {
                        ForEach(0..<self.cards.count, id: \.self) { index in
                            CardView(card: self.cards[index]) {
                                withAnimation {
                                    self.removeCard(at: index)
                                }
                            }
                            .stacked(at: index, in: self.cards.count)
                        }
                    }
                    .allowsHitTesting(self.timeRemaining > 0)
                    
                    if self.cards.isEmpty {
                        Button("Start Again", action: self.resetCards)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.black)
                            .clipShape(Capsule())
                    }
                }
                
                if self.differentiateWithoutColor {
                    VStack {
                        Spacer()
                        HStack {
                            Image(systemName: "xmark.circle")
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .clipShape(Circle())
                            Spacer()
                            Image(systemName: "checkmark.circle")
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                        .foregroundColor(.white)
                        .font(.largeTitle)
                        .padding()
                        
                    }
                    .frame(width: geo.size.width)
                }
            }
            .onReceive(self.timer) { time in
                guard self.isActive else { return }
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                self.isActive = false
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                if self.cards.isEmpty == false {
                    self.isActive = true
                }
            }
        }
    }
    
    func removeCard(at index : Int) {
        cards.remove(at: index)
        
        if cards.isEmpty {
            isActive = false
        }
    }
    
    func resetCards() {
        cards = [Card](repeating: Card.example, count: 10)
        timeRemaining = startingTime
        isActive = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension View {
    func stacked(at position: Int, in total: Int) -> some View {
        let offset = CGFloat(total - position)
        return self.offset(CGSize(width: 0, height: offset * 10))
    }
}
