//
//  ContentView.swift
//  Flashzilla
//
//  Created by Chris Wu on 7/8/20.
//  Copyright © 2020 Chris Wu. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var scale: CGFloat = 1
    @State private var cards = [Card](repeating: Card.example, count: 10)
    
    var body: some View {
        GeometryReader { geo in  // not in lesson
            ZStack {
                Image("background")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
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
                    .frame(width: geo.size.width) // not in lesson
                }
            }
        }
    }
    
    func removeCard(at index : Int) {
        cards.remove(at: index)
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
