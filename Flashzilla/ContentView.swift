//
//  ContentView.swift
//  Flashzilla
//
//  Created by Chris Wu on 7/8/20.
//  Copyright © 2020 Chris Wu. All rights reserved.
//

import SwiftUI
import CoreHaptics

let startingTime = 15

struct ContentView: View {
    @Environment(\.accessibilityEnabled) var accessibilityEnabled
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var showingEditScreen = false
    @State private var scale: CGFloat = 1
    @State private var cards = [Card]()
    @State private var timeRemaining = startingTime
    @State private var isActive = true
    @State private var scaleAmount : CGFloat = 1
    @State private var engine: CHHapticEngine?
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geo in  // not in lesson
            ZStack {
                Image(decorative: "background")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text(self.timeRemaining > 0 ? "Time: \(self.timeRemaining)" : "Time's Up!")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(Color.black)
                                .opacity(0.75)
                    )
                        .scaleEffect(CGFloat(self.timeRemaining > 0 ? 1 : self.scaleAmount))
                        .animation(self.timeRemaining > 0 ? .none : .default)

                    ZStack {
                        ForEach(0..<self.cards.count, id: \.self) { index in
                            CardView(card: self.cards[index]) {
                                withAnimation {
                                    self.removeCard(at: index)
                                }
                            }
                            .stacked(at: index, in: self.cards.count)
                            .allowsHitTesting(index == self.cards.count - 1)
                            .accessibility(hidden: index < self.cards.count - 1)
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
                
                VStack {
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            self.showingEditScreen = true
                        }) {
                            Image(systemName: "plus.circle")
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                    }
                    
                    Spacer()
                }
                    .frame(width: geo.size.width) // not in lesson
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .padding()
                
                if self.differentiateWithoutColor || self.accessibilityEnabled {
                    VStack {
                        Spacer()
                        HStack {
                            Button(action: {
                                withAnimation {
                                    self.removeCard(at: self.cards.count - 1)
                                }
                            }) {
                                Image(systemName: "xmark.circle")
                                    .padding()
                                    .background(Color.black.opacity(0.7))
                                    .clipShape(Circle())
                            }
                            .accessibility(label: Text("Wrong"))
                            .accessibility(hint: Text("Mark your answer as being incorrect."))
                            Spacer()
                            
                            Button(action: {
                                withAnimation {
                                    self.removeCard(at: self.cards.count - 1)
                                }
                            }) {
                                Image(systemName: "checkmark.circle")
                                    .padding()
                                    .background(Color.black.opacity(0.7))
                                    .clipShape(Circle())
                            }
                            .accessibility(label: Text("Correct"))
                            .accessibility(hint: Text("Mark your answer as being correct."))
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
                    // day 91 - challenge 1. added custom haptic
                    if 0 == self.timeRemaining {
                        self.timesUpShake()
                    } else if 1 == self.timeRemaining {
                        prepareHaptics()
                    }
                } else {
                    // day 91 - challenge 1. animation for time's up
                    self.scaleAmount = 2
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
            .sheet(isPresented: self.$showingEditScreen, onDismiss: self.resetCards) {
                EditCards()
            }
            .onAppear(perform: self.resetCards)
        }
    }
    
    func removeCard(at index : Int) {
        guard index >= 0 else { return }
        
        cards.remove(at: index)
        
        if cards.isEmpty {
            isActive = false
        }
    }
    
    func resetCards() {
        scaleAmount = 1
        timeRemaining = startingTime
        isActive = true
        loadData()
    }
    
    func loadData() {
        if let data = UserDefaults.standard.data(forKey: "Cards") {
            if let decoded = try? JSONDecoder().decode([Card].self, from: data) {
                self.cards = decoded
            }
        }
    }
    
    // code modified from hacking with swift
    func timesUpShake() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        var events = [CHHapticEvent]()
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 2)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 2)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        events.append(event)

        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
    }
    
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            self.engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
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
