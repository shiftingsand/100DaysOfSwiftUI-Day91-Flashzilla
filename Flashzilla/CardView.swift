//
//  CardView.swift
//  Flashzilla
//
//  Created by Chris Wu on 7/12/20.
//  Copyright © 2020 Chris Wu. All rights reserved.
//

import SwiftUI

struct CardView: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.accessibilityEnabled) var accessibilityEnabled
    let card: Card
    @Binding var retryFailures : Bool
    @State private var feedback = UINotificationFeedbackGenerator()
    @State private var isShowingAnswer = false
    @Binding var lastAnswerCorrect : Bool
    @State var offset = CGSize.zero
    var removal: (() -> Void)? = nil

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(
                    differentiateWithoutColor
                        ? Color.white
                        : Color.white
                            .opacity(1 - Double(abs(offset.width / 50)))
                    
            )
                .background(
                    differentiateWithoutColor
                        ? nil
                        : RoundedRectangle(cornerRadius: 25, style: .continuous)
                            .fill(offset.width > 0 ? Color.green : (offset.width == 0 ? Color.white : Color.red))
            )
                .shadow(radius: 10)

            VStack {
                if accessibilityEnabled {
                    Text(isShowingAnswer ? card.answer : card.prompt)
                        .font(.largeTitle)
                        .foregroundColor(.black)
                } else {
                    Text(card.prompt)
                        .font(.largeTitle)
                        .foregroundColor(.black)
                    
                    if isShowingAnswer {
                        Text(card.answer)
                            .font(.title)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(20)
            .multilineTextAlignment(.center)
        }
        .frame(width: 450, height: 250)
        .rotationEffect(.degrees(Double(offset.width / 5)))
        .offset(x: offset.width * 5, y: 0)
        .opacity(2 - Double(abs(offset.width / 50)))
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    self.offset = gesture.translation
                    self.feedback.prepare()
            }
                
            .onEnded { _ in
                if abs(self.offset.width) > 100 {
                    if self.offset.width > 0 {
                        self.feedback.notificationOccurred(.success)
                    } else {
                        self.feedback.notificationOccurred(.error)
                    }
                    
                    // day 91 - challenge 2. have to have a way to know if the answer way correct.
                    self.lastAnswerCorrect = (self.offset.width > 0)
                    
                    self.removal?()
                    
                    // day 91 - challenge 2
                    // i think this is key. we need to put back the card if we're going to retry.
                    if true == self.retryFailures {
                        print("putting the card back for retries")
                        self.offset = .zero
                    }
                } else {
                    self.offset = .zero
                }
                
                // hide answers again after card swipes.
                self.isShowingAnswer = false
            }
        )
        .onTapGesture {
            self.isShowingAnswer.toggle()
        }
        .animation(.spring())
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(card: Card.example, retryFailures: .constant(true), lastAnswerCorrect: .constant(false))
    }
}
