//
//  ContentView.swift
//  NANOTWO
//
//  Created by Rayhan Rafferty on 15/05/24.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var isMuted = false
    @State private var dragOffset1 = CGSize.zero
    @State private var lastDragOffset1 = CGSize.zero
    @State private var dragOffset2 = CGSize.zero
    @State private var lastDragOffset2 = CGSize.zero
    @State private var dragOffset3 = CGSize.zero
    @State private var lastDragOffset3 = CGSize.zero
    @State private var dragOffset4 = CGSize.zero // New state variable for the fourth icon
    @State private var lastDragOffset4 = CGSize.zero // Variable to store last drag offset for icon 4
    
    var body: some View {
        let dragGesture1 = DragGesture()
            .onChanged { value in
                self.dragOffset1 = self.calculateNewOffset(lastDragOffset: self.lastDragOffset1, translation: value.translation)
            }
            .onEnded { value in
                self.lastDragOffset1 = self.dragOffset1
            }
        
        let dragGesture2 = DragGesture()
            .onChanged { value in
                self.dragOffset2 = self.calculateNewOffset(lastDragOffset: self.lastDragOffset2, translation: value.translation)
            }
            .onEnded { value in
                self.lastDragOffset2 = self.dragOffset2
            }
        
        let dragGesture3 = DragGesture()
            .onChanged { value in
                self.dragOffset3 = self.calculateNewOffset(lastDragOffset: self.lastDragOffset3, translation: value.translation)
            }
            .onEnded { value in
                self.lastDragOffset3 = self.dragOffset3
            }
        
        let dragGesture4 = DragGesture()
            .onChanged { value in
                self.dragOffset4 = self.calculateNewOffset(lastDragOffset: self.lastDragOffset4, translation: value.translation)
            }
            .onEnded { value in
                self.lastDragOffset4 = self.dragOffset4
            }
        
        return ZStack {
            Image("BackgroundImageTes")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                Button(action: {
                    isMuted.toggle()
                    if isMuted {
                        MusicPlayer.shared.muteBackgroundMusic()
                    } else {
                        MusicPlayer.shared.unmuteBackgroundMusic()
                    }
                }) {
                    Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                        .padding()
                }
            }
            .padding()
            
            // Draggable image 1
            Image(systemName: "star.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(.blue)
                .offset(dragOffset1)
                .gesture(dragGesture1)
            
            // Draggable image 2
            Image(systemName: "moon.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(.green)
                .offset(dragOffset2)
                .gesture(dragGesture2)
            
            // Draggable image 3
            Image(systemName: "sun.max.fill")
                .font(.system(size: 100))
                .foregroundColor(.yellow)
                .offset(dragOffset3)
                .gesture(dragGesture3)
            
            // Draggable image 4
            Image(systemName: "cloud.fill")
                .font(.system(size: 100))
                .foregroundColor(.gray)
                .offset(dragOffset4)
                .gesture(dragGesture4)
        }
        .onAppear {
            MusicPlayer.shared.playBackgroundMusic()
            // Randomly position the icons
            self.randomizeIconPositions()
        }
    }
    
    private func calculateNewOffset(lastDragOffset: CGSize, translation: CGSize) -> CGSize {
        let newOffset = CGSize(width: lastDragOffset.width + translation.width,
                               height: lastDragOffset.height + translation.height)
        // Adjust maximum allowable offset based on your requirements
        let maxWidth = UIScreen.main.bounds.width / 2 - 50 // Adjust according to your icon size
        let maxHeight = UIScreen.main.bounds.height / 2 - 50 // Adjust according to your icon size
        let minX = -maxWidth
        let minY = -maxHeight
        let maxX = maxWidth
        let maxY = maxHeight
        // Apply constraints to ensure the icon stays within the screen boundaries
        return CGSize(width: min(max(minX, newOffset.width), maxX),
                      height: min(max(minY, newOffset.height), maxY))
    }
    
    private func randomizeIconPositions() {
        let randomX1 = CGFloat.random(in: -UIScreen.main.bounds.width / 2 ... UIScreen.main.bounds.width / 2)
        let randomY1 = CGFloat.random(in: -UIScreen.main.bounds.height / 2 ... UIScreen.main.bounds.height / 2)
        dragOffset1 = CGSize(width: randomX1, height: randomY1)
        lastDragOffset1 = CGSize(width: randomX1, height: randomY1)
        
        let randomX2 = CGFloat.random(in: -UIScreen.main.bounds.width / 2 ... UIScreen.main.bounds.width / 2)
        let randomY2 = CGFloat.random(in: -UIScreen.main.bounds.height / 2 ... UIScreen.main.bounds.height / 2)
        dragOffset2 = CGSize(width: randomX2, height: randomY2)
        lastDragOffset2 = CGSize(width: randomX2, height: randomY2)
        
        let randomX3 = CGFloat.random(in: -UIScreen.main.bounds.width / 2 ... UIScreen.main.bounds.width / 2)
        let randomY3 = CGFloat.random(in: -UIScreen.main.bounds.height / 2 ... UIScreen.main.bounds.height / 2)
        dragOffset3 = CGSize(width: randomX3, height: randomY3)
        lastDragOffset3 = CGSize(width: randomX3, height: randomY3)
        
        let randomX4 = CGFloat.random(in: -UIScreen.main.bounds.width / 2 ... UIScreen.main.bounds.width / 2)
        let randomY4 = CGFloat.random(in: -UIScreen.main.bounds.height / 2 ... UIScreen.main.bounds.height / 2)
        dragOffset4 = CGSize(width: randomX4, height: randomY4)
        lastDragOffset4 = CGSize(width: randomX4, height: randomY4)
    }
    
    
}

class MusicPlayer {
    static let shared = MusicPlayer()
    var audioPlayer: AVAudioPlayer?
    private var volumeBeforeMute: Float = 1.0
    
    func playBackgroundMusic() {
        guard let path = Bundle.main.path(forResource: "backgroundMusic", ofType: "mp3") else {
            print("Background music file not found")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.play()
        } catch {
            print("Error loading and playing audio file: \(error.localizedDescription)")
        }
    }
    
    func stopBackgroundMusic() {
        audioPlayer?.stop()
    }
    
    func muteBackgroundMusic() {
        guard let player = audioPlayer else { return }
        volumeBeforeMute = player.volume
        player.volume = 0
    }
    
    func unmuteBackgroundMusic() {
        guard let player = audioPlayer else { return }
        player.volume = volumeBeforeMute
    }
}
//
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
