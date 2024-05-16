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
    @State private var dragOffset4 = CGSize.zero
    @State private var lastDragOffset4 = CGSize.zero

    @State private var showIcon1 = true
    @State private var showIcon2 = true
    @State private var showIcon3 = true
    @State private var showIcon4 = true

    @State private var newIcons: [(offset: CGSize, lastOffset: CGSize, image: String, color: Color)] = []
    @State private var showResetButton = false

    var body: some View {
        let dragGesture1 = createDragGesture(dragOffset: $dragOffset1, lastDragOffset: $lastDragOffset1)
        let dragGesture2 = createDragGesture(dragOffset: $dragOffset2, lastDragOffset: $lastDragOffset2)
        let dragGesture3 = createDragGesture(dragOffset: $dragOffset3, lastDragOffset: $lastDragOffset3)
        let dragGesture4 = createDragGesture(dragOffset: $dragOffset4, lastDragOffset: $lastDragOffset4)

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

                if showResetButton {
                    Button(action: {
                        resetIcons()
                    }) {
                        Text("Reset")
                            .font(.system(size: 24))
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                    }
                }
            }
            .padding()

            if showIcon1 {
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.blue)
                    .offset(dragOffset1)
                    .gesture(dragGesture1)
            }

            if showIcon2 {
                Image(systemName: "moon.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.green)
                    .offset(dragOffset2)
                    .gesture(dragGesture2)
            }

            if showIcon3 {
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.yellow)
                    .offset(dragOffset3)
                    .gesture(dragGesture3)
            }

            if showIcon4 {
                Image(systemName: "cloud.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.gray)
                    .offset(dragOffset4)
                    .gesture(dragGesture4)
            }

            ForEach(newIcons.indices, id: \.self) { index in
                Image(systemName: newIcons[index].image)
                    .font(.system(size: 100))
                    .foregroundColor(newIcons[index].color)
                    .offset(newIcons[index].offset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                newIcons[index].offset = self.calculateNewOffset(lastDragOffset: newIcons[index].lastOffset, translation: value.translation)
                            }
                            .onEnded { value in
                                newIcons[index].lastOffset = newIcons[index].offset
                                checkCollision(for: index)
                            }
                    )
            }
        }
        .onAppear {
            MusicPlayer.shared.playBackgroundMusic()
            randomizeIconPositions()
        }
    }

    private func createDragGesture(dragOffset: Binding<CGSize>, lastDragOffset: Binding<CGSize>) -> some Gesture {
        return DragGesture()
            .onChanged { value in
                dragOffset.wrappedValue = self.calculateNewOffset(lastDragOffset: lastDragOffset.wrappedValue, translation: value.translation)
            }
            .onEnded { value in
                lastDragOffset.wrappedValue = dragOffset.wrappedValue
                checkCollision()
            }
    }

    private func calculateNewOffset(lastDragOffset: CGSize, translation: CGSize) -> CGSize {
        let newOffset = CGSize(width: lastDragOffset.width + translation.width,
                               height: lastDragOffset.height + translation.height)
        let maxWidth = UIScreen.main.bounds.width / 2 - 50
        let maxHeight = UIScreen.main.bounds.height / 2 - 50
        let minX = -maxWidth
        let minY = -maxHeight
        let maxX = maxWidth
        let maxY = maxHeight
        return CGSize(width: min(max(minX, newOffset.width), maxX),
                      height: min(max(minY, newOffset.height), maxY))
    }

    private func randomizeIconPositions() {
        let randomX1 = CGFloat.random(in: -UIScreen.main.bounds.width / 2 ... UIScreen.main.bounds.width / 2)
        let randomY1 = CGFloat.random(in: -UIScreen.main.bounds.height / 2 ... UIScreen.main.bounds.height / 2)
        dragOffset1 = CGSize(width: randomX1, height: randomY1)
        lastDragOffset1 = dragOffset1

        let randomX2 = CGFloat.random(in: -UIScreen.main.bounds.width / 2 ... UIScreen.main.bounds.width / 2)
        let randomY2 = CGFloat.random(in: -UIScreen.main.bounds.height / 2 ... UIScreen.main.bounds.height / 2)
        dragOffset2 = CGSize(width: randomX2, height: randomY2)
        lastDragOffset2 = dragOffset2

        let randomX3 = CGFloat.random(in: -UIScreen.main.bounds.width / 2 ... UIScreen.main.bounds.width / 2)
        let randomY3 = CGFloat.random(in: -UIScreen.main.bounds.height / 2 ... UIScreen.main.bounds.height / 2)
        dragOffset3 = CGSize(width: randomX3, height: randomY3)
        lastDragOffset3 = dragOffset3

        let randomX4 = CGFloat.random(in: -UIScreen.main.bounds.width / 2 ... UIScreen.main.bounds.width / 2)
        let randomY4 = CGFloat.random(in: -UIScreen.main.bounds.height / 2 ... UIScreen.main.bounds.height / 2)
        dragOffset4 = CGSize(width: randomX4, height: randomY4)
        lastDragOffset4 = dragOffset4
    }

    private func checkCollision() {
        if showIcon1, showIcon2, checkIntersect(offset1: dragOffset1, offset2: dragOffset2) {
            transformIcons(&showIcon1, &showIcon2, offset1: dragOffset1, offset2: dragOffset2, newIcon: ("heart.fill", .red))
        }
        if showIcon1, showIcon3, checkIntersect(offset1: dragOffset1, offset2: dragOffset3) {
            transformIcons(&showIcon1, &showIcon3, offset1: dragOffset1, offset2: dragOffset3, newIcon: ("bolt.fill", .yellow))
        }
        if showIcon1, showIcon4, checkIntersect(offset1: dragOffset1, offset2: dragOffset4) {
            transformIcons(&showIcon1, &showIcon4, offset1: dragOffset1, offset2: dragOffset4, newIcon: ("flame.fill", .orange))
        }
        if showIcon2, showIcon3, checkIntersect(offset1: dragOffset2, offset2: dragOffset3) {
            transformIcons(&showIcon2, &showIcon3, offset1: dragOffset2, offset2: dragOffset3, newIcon: ("drop.fill", .blue))
        }
        if showIcon2, showIcon4, checkIntersect(offset1: dragOffset2, offset2: dragOffset4) {
            transformIcons(&showIcon2, &showIcon4, offset1: dragOffset2, offset2: dragOffset4, newIcon: ("leaf.fill", .green))
        }
        if showIcon3, showIcon4, checkIntersect(offset1: dragOffset3, offset2: dragOffset4) {
            transformIcons(&showIcon3, &showIcon4, offset1: dragOffset3, offset2: dragOffset4, newIcon: ("star.fill", .purple))
        }

        for i in 0..<newIcons.count {
            for j in i+1..<newIcons.count {
                if checkIntersect(offset1: newIcons[i].offset, offset2: newIcons[j].offset) {
                    transformNewIcons(index1: i, index2: j)
                }
            }
        }

        for i in 0..<newIcons.count {
            if showIcon1, checkIntersect(offset1: newIcons[i].offset, offset2: dragOffset1) {
                showIcon1 = false
                transformNewIconWithOriginal(index1: i, offset2 : dragOffset1, newIcon: ("heart.fill", .red))
            }
            if showIcon2, checkIntersect(offset1: newIcons[i].offset, offset2: dragOffset2) {
                showIcon2 = false
                transformNewIconWithOriginal(index1: i, offset2: dragOffset2, newIcon: ("bolt.fill", .yellow))
            }
            if showIcon3, checkIntersect(offset1: newIcons[i].offset, offset2: dragOffset3) {
                showIcon3 = false
                transformNewIconWithOriginal(index1: i, offset2: dragOffset3, newIcon: ("flame.fill", .orange))
            }
            if showIcon4, checkIntersect(offset1: newIcons[i].offset, offset2: dragOffset4) {
                showIcon4 = false
                transformNewIconWithOriginal(index1: i, offset2: dragOffset4, newIcon: ("drop.fill", .blue))
            }
        }
    }

    private func checkCollision(for index: Int) {
        for i in 0..<newIcons.count where i != index {
            if checkIntersect(offset1: newIcons[index].offset, offset2: newIcons[i].offset) {
                transformNewIcons(index1: index, index2: i)
                return
            }
        }
        if showIcon1, checkIntersect(offset1: newIcons[index].offset, offset2: dragOffset1) {
            showIcon1 = false
            transformNewIconWithOriginal(index1: index, offset2: dragOffset1, newIcon: ("heart.fill", .red))
        } else if showIcon2, checkIntersect(offset1: newIcons[index].offset, offset2: dragOffset2) {
            showIcon2 = false
            transformNewIconWithOriginal(index1: index, offset2: dragOffset2, newIcon: ("bolt.fill", .yellow))
        } else if showIcon3, checkIntersect(offset1: newIcons[index].offset, offset2: dragOffset3) {
            showIcon3 = false
            transformNewIconWithOriginal(index1: index, offset2: dragOffset3, newIcon: ("flame.fill", .orange))
        } else if showIcon4, checkIntersect(offset1: newIcons[index].offset, offset2: dragOffset4) {
            showIcon4 = false
            transformNewIconWithOriginal(index1: index, offset2: dragOffset4, newIcon: ("drop.fill", .blue))
        }
    }

    private func checkIntersect(offset1: CGSize, offset2: CGSize) -> Bool {
        let frame1 = CGRect(x: offset1.width, y: offset1.height, width: 100, height: 100)
        let frame2 = CGRect(x: offset2.width, y: offset2.height, width: 100, height: 100)
        return frame1.intersects(frame2)
    }

    private func transformIcons(_ showIcon1: inout Bool, _ showIcon2: inout Bool, offset1: CGSize, offset2: CGSize, newIcon: (image: String, color: Color)) {
        showIcon1 = false
        showIcon2 = false
        let newOffset = CGSize(width: (offset1.width + offset2.width) / 2, height: (offset1.height + offset2.height) / 2)
        newIcons.append((offset: newOffset, lastOffset: newOffset, image: newIcon.image, color: newIcon.color))
        showResetButton = true
    }

    private func transformNewIcons(index1: Int, index2: Int) {
        guard newIcons.indices.contains(index1), newIcons.indices.contains(index2) else {
            return
        }
        let offset1 = newIcons[index1].offset
        let offset2 = newIcons[index2].offset
        newIcons.remove(at: max(index1, index2))
        newIcons.remove(at: min(index1, index2))
        let newOffset = CGSize(width: (offset1.width + offset2.width) / 2, height: (offset1.height + offset2.height) / 2)
        newIcons.append((offset: newOffset, lastOffset: newOffset, image: "star.fill", color: .purple))
        if newIcons.count <= 1 {
            showResetButton = true
        }
    }

    private func transformNewIconWithOriginal(index1: Int, offset2: CGSize, newIcon: (image: String, color: Color)) {
        guard newIcons.indices.contains(index1) else {
            return
        }
        let offset1 = newIcons[index1].offset
        newIcons.remove(at: index1)
        let newOffset = CGSize(width: (offset1.width + offset2.width) / 2, height: (offset1.height + offset2.height) / 2)
        newIcons.append((offset: newOffset, lastOffset: newOffset, image: newIcon.image, color: newIcon.color))
        if newIcons.count <= 1 {
            showResetButton = true
        }
    }

    private func resetIcons() {
        showIcon1 = true
        showIcon2 = true
        showIcon3 = true
        showIcon4 = true
        newIcons.removeAll()
        randomizeIconPositions()
        showResetButton = false
    }
    private func getCombinationResult(icon1: String, icon2: String) -> String {
            switch (icon1, icon2) {
            case ("cloud.fill", "sun.max.fill"):
                return "water"
            case ("cloud.fill", "moon.circle.fill"):
                return "watch"
            // Add more combinations here
            default:
                return "star.circle.fill"
            }
        }

        private func getColorForImage(_ image: String) -> Color {
            switch image {
            case "water":
                return .blue
            case "watch":
                return .purple
            default:
                return .red
            }
        }
}

class MusicPlayer {
    static let shared = MusicPlayer()
    var audioPlayer: AVAudioPlayer?
    private var volumeBeforeMute: Float = 1.0

    func playBackgroundMusic() {
        guard let path = Bundle.main.path(forResource: "backgroundMusic", ofType: "mp3") else {
            return
        }

        let url = URL(fileURLWithPath: path)

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.play()
        } catch {
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
