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
    @State private var newIcons2: [(offset: CGSize, lastOffset: CGSize, image: String, color: Color)] = []
    @State private var showResetButton = false
    
    var body: some View {
        let dragGesture1 = createDragGesture(dragOffset: $dragOffset1, lastDragOffset: $lastDragOffset1)
        let dragGesture2 = createDragGesture(dragOffset: $dragOffset2, lastDragOffset: $lastDragOffset2)
        let dragGesture3 = createDragGesture(dragOffset: $dragOffset3, lastDragOffset: $lastDragOffset3)
        let dragGesture4 = createDragGesture(dragOffset: $dragOffset4, lastDragOffset: $lastDragOffset4)
        
        return ZStack {
//            Image("BackgroundNano")
//                .resizable()
//                .edgesIgnoringSafeArea(.all)
            VideoPlayerView(videoName: "backgroundvideos", videoType: "mp4")
                            .edgesIgnoringSafeArea(.all)
            
            VStack {
                Rectangle()
                    .frame(width: 300, height: 100)
                    .position(x:250,y:505)
                    .foregroundColor(.clear)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        SoundEffectPlayer.shared.playSoundEffect(named: "suaracat")
                    }
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
            
            if showIcon1 {
                Image("KiriAtas")
                    .resizable()
                    .frame(width: 278/2, height: 425/2)
                    .offset(dragOffset1)
                    .gesture(dragGesture1)
            }
            
            if showIcon2 {
                Image("KananAtas")
                    .resizable()
                    .frame(width: 278/2, height: 425/2)
                    .offset(dragOffset2)
                    .gesture(dragGesture2)
            }
            
            if showIcon3 {
                Image("KiriBawah")
                    .resizable()
                    .frame(width: 278/2, height: 425/2)
                    .offset(dragOffset3)
                    .gesture(dragGesture3)
            }
            
            if showIcon4 {
                Image("KananBawah")
                    .resizable()
                    .frame(width: 278/2, height: 425/2)
                    .offset(dragOffset4)
                    .gesture(dragGesture4)
            }
            
            ForEach(newIcons.indices, id: \.self) { index in
                Image(newIcons[index].image)
                    .resizable()
                    .frame(
                        width: shouldUseLargeSize(newIcon: newIcons[index]) == 0
                        ? 278 : shouldUseLargeSize(newIcon: newIcons[index]) == 1
                        ? 139 : 278,
                        height: shouldUseLargeSize(newIcon: newIcons[index]) == 0
                        ? 212.5 : shouldUseLargeSize(newIcon: newIcons[index]) == 1
                        ? 425 : 425)
                    .offset(newIcons[index].offset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                newIcons[index].offset = self.calculateNewOffset(lastDragOffset: newIcons[index].lastOffset, translation: value.translation)
                            }
                            .onEnded { value in
                                newIcons[index].lastOffset = newIcons[index].offset
                                checkCollision()
                            }
                    )
                    .gesture(
                            TapGesture(count: 2)
                                .onEnded {
                                resetIcons()
                                SoundEffectPlayer.shared.playSoundEffect(named: "suarapecah")
                                            }
                                    )
            }
            ForEach(newIcons2.indices, id: \.self) { index in
                Image(newIcons2[index].image)
                    .resizable()
                    .frame(
                        width: shouldUseLargeSize(newIcon: newIcons2[index]) == 0
                        ? 278 : shouldUseLargeSize(newIcon: newIcons2[index]) == 1
                        ? 139 : 278,
                        height: shouldUseLargeSize(newIcon: newIcons2[index]) == 0
                        ? 212.5 : shouldUseLargeSize(newIcon: newIcons2[index]) == 1
                        ? 425 : 425)
                    .offset(newIcons2[index].offset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                newIcons2[index].offset = self.calculateNewOffset(lastDragOffset: newIcons2[index].lastOffset, translation: value.translation)
                            }
                            .onEnded { value in
                                newIcons2[index].lastOffset = newIcons2[index].offset
                                checkCollision()
                            }
                    )
                    .gesture(
                            TapGesture(count: 2)
                                .onEnded {
                                resetIcons()
                                SoundEffectPlayer.shared.playSoundEffect(named: "suarapecah")
                                            }
                                    )
            }
        }
        .onAppear {
            MusicPlayer.shared.playBackgroundMusic()
            randomizeIconPositions()
        }
    }
    
    private func shouldUseLargeSize(newIcon: (offset: CGSize, lastOffset: CGSize, image: String, color: Color)) -> Int {
        let image = newIcon.image
        if (image == "KiriKananAtas" || image == "KiriKananBawah") {
            return 0
        } else if (image == "KiriAtasBawah" || image == "KananAtasBawah"){
            return 1
        } else {
            return 2
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
    
//    FUNCTION COMBINATION PERTAMA
    
    private func checkCollision() {
        if showIcon1, showIcon2, checkIntersect(offset1: dragOffset1, offset2: dragOffset2) {
            showIcon1 = false
            showIcon2 = false
            transformIcons(&showIcon1, &showIcon2, offset1: dragOffset1, offset2: dragOffset2, newIcon: ("KiriKananAtas", .red))
            SoundEffectPlayer.shared.playSoundEffect(named: "suarakintsugi")
        }
        if showIcon3, showIcon4, checkIntersect(offset1: dragOffset3, offset2: dragOffset4) {
            showIcon3 = false
            showIcon4 = false
            transformIcons(&showIcon3, &showIcon4, offset1: dragOffset3, offset2: dragOffset4, newIcon: ("KiriKananBawah", .yellow))
            SoundEffectPlayer.shared.playSoundEffect(named: "suarakintsugi")
        }
        if showIcon1, showIcon3, checkIntersect(offset1: dragOffset1, offset2: dragOffset3) {
            showIcon1 = false
            showIcon3 = false
            transformIcons(&showIcon1, &showIcon3, offset1: dragOffset1, offset2: dragOffset3, newIcon: ("KiriAtasBawah", .orange))
            SoundEffectPlayer.shared.playSoundEffect(named: "suarakintsugi")
        }
        if showIcon2, showIcon4, checkIntersect(offset1: dragOffset2, offset2: dragOffset4) {
            showIcon2 = false
            showIcon4 = false
            transformIcons(&showIcon2, &showIcon4, offset1: dragOffset2, offset2: dragOffset4, newIcon: ("KananAtasBawah", .blue))
            SoundEffectPlayer.shared.playSoundEffect(named: "suarakintsugi")
        }
        
        for i in 0..<newIcons.count {
            if showIcon1, checkIntersect(offset1: newIcons[i].offset, offset2: dragOffset1) {
                showIcon1 = false
                if(newIcons[i].image == "KananAtasBawah"){
                    showIcon2 = false
                    showIcon4 = false
                    transformNewIconWithOriginal(index1: i, offset2: dragOffset1, newIcon: ("KiriKananAtasKananBawah", .green))
                } else if (newIcons[i].image == "KiriKananBawah") {
                    showIcon3 = false
                    showIcon4 = false
                    transformNewIconWithOriginal(index1: i, offset2: dragOffset1, newIcon: ("KiriAtasKiriKananBawah", .green))
                } else if (newIcons[i].image == "KananAtasKiriKananBawah") {
                    transformNewIconWithOriginal(index1: i, offset2: dragOffset1, newIcon: ("KiriKananAtasKiriKananBawah", .green))
                }
                SoundEffectPlayer.shared.playSoundEffect(named: "suarakintsugi")
            }
            if showIcon2, checkIntersect(offset1: newIcons[i].offset, offset2: dragOffset2) {
                showIcon2 = false
                if(newIcons[i].image == "KiriAtasBawah"){
                    showIcon1 = false
                    showIcon3 = false
                    transformNewIconWithOriginal(index1: i, offset2: dragOffset1, newIcon: ("KiriKananAtasKiriBawah", .green))
                } else if (newIcons[i].image == "KiriKananBawah") {
                    showIcon3 = false
                    showIcon4 = false
                    transformNewIconWithOriginal(index1: i, offset2: dragOffset1, newIcon: ("KananAtasKiriKananBawah", .green))
                } else if (newIcons[i].image == "KiriAtasKiriKananBawah") {
                    transformNewIconWithOriginal(index1: i, offset2: dragOffset1, newIcon: ("KiriKananAtasKiriKananBawah", .green))
                }
                SoundEffectPlayer.shared.playSoundEffect(named: "suarakintsugi")
            }
            if showIcon3, checkIntersect(offset1: newIcons[i].offset, offset2: dragOffset3) {
                showIcon3 = false
                if(newIcons[i].image == "KiriKananAtas"){
                    showIcon1 = false
                    showIcon2 = false
                    transformNewIconWithOriginal(index1: i, offset2: dragOffset1, newIcon: ("KiriKananAtasKiriBawah", .green))
                } else if (newIcons[i].image == "KananAtasBawah") {
                    showIcon2 = false
                    showIcon4 = false
                    transformNewIconWithOriginal(index1: i, offset2: dragOffset1, newIcon: ("KananAtasKiriKananBawah", .green))
                } else if (newIcons[i].image == "KiriKananAtasKananBawah") {
                    transformNewIconWithOriginal(index1: i, offset2: dragOffset1, newIcon: ("KiriKananAtasKiriKananBawah", .green))
                }
                SoundEffectPlayer.shared.playSoundEffect(named: "suarakintsugi")
            }
            if showIcon4, checkIntersect(offset1: newIcons[i].offset, offset2: dragOffset4) {
                showIcon4 = false
                if(newIcons[i].image == "KiriKananAtas"){
                    showIcon1 = false
                    showIcon2 = false
                    transformNewIconWithOriginal(index1: i, offset2: dragOffset1, newIcon: ("KiriKananAtasKananBawah", .green))
                } else if (newIcons[i].image == "KiriAtasBawah") {
                    showIcon1 = false
                    showIcon3 = false
                    transformNewIconWithOriginal(index1: i, offset2: dragOffset1, newIcon: ("KiriAtasKiriKananBawah", .green))
                } else if (newIcons[i].image == "KiriKananAtasKiriBawah") {
                    transformNewIconWithOriginal(index1: i, offset2: dragOffset1, newIcon: ("KiriKananAtasKiriKananBawah", .green))
                }
                SoundEffectPlayer.shared.playSoundEffect(named: "suarakintsugi")
            }
            if !newIcons2.isEmpty, checkIntersect(offset1: newIcons[i].offset, offset2: newIcons2[i].offset) {
                newIcons2 = []
                if(newIcons[i].image == "KiriKananAtas"){
                    transformNewIconWithOriginal(index1: i, offset2: dragOffset1, newIcon: ("KiriKananAtasKiriKananBawah", .green))
                } else if (newIcons[i].image == "KiriKananBawah") {
                    transformNewIconWithOriginal(index1: i, offset2: dragOffset1, newIcon: ("KiriKananAtasKiriKananBawah", .green))
                } else if (newIcons[i].image == "KananAtasBawah") {
                    transformNewIconWithOriginal(index1: i, offset2: dragOffset1, newIcon: ("KiriKananAtasKiriKananBawah", .green))
                } else if (newIcons[i].image == "KiriAtasBawah") {
                    transformNewIconWithOriginal(index1: i, offset2: dragOffset1, newIcon: ("KiriKananAtasKiriKananBawah", .green))
                }
                SoundEffectPlayer.shared.playSoundEffect(named: "suarakintsugi")
            }
        }
    }
    
//    FUNCTION COMBINATION KEDUA CUMAN HORIZONTAL AJA
    
    private func checkIntersect(offset1: CGSize, offset2: CGSize) -> Bool {
        let threshold: CGFloat = 180
        return abs(offset1.width - offset2.width) < threshold && abs(offset1.height - offset2.height) < threshold
    }
    
    private func transformIcons(_ showIconA: inout Bool, _ showIconB: inout Bool, offset1: CGSize, offset2: CGSize, newIcon: (image: String, color: Color)) {
        showIconA = false
        showIconB = false
        
        if newIcons.isEmpty {
            newIcons.append((offset: calculateMidpoint(offset1: offset1, offset2: offset2), lastOffset: calculateMidpoint(offset1: offset1, offset2: offset2), image: newIcon.image, color: newIcon.color))
        } else {
            newIcons2.append((offset: calculateMidpoint(offset1: offset1, offset2: offset2), lastOffset: calculateMidpoint(offset1: offset1, offset2: offset2), image: newIcon.image, color: newIcon.color))
        }
        showResetButton = true
    }
    
    private func calculateMidpoint(offset1: CGSize, offset2: CGSize) -> CGSize {
        return CGSize(width: (offset1.width + offset2.width) / 2, height: (offset1.height + offset2.height) / 2)
    }
    
    private func transformNewIconWithOriginal(index1: Int, offset2: CGSize, newIcon: (image: String, color: Color)) {
        newIcons[index1].offset = calculateMidpoint(offset1: newIcons[index1].offset, offset2: offset2)
        newIcons[index1].image = newIcon.image
        newIcons[index1].color = newIcon.color
    }
    
    private func resetIcons() {
        showIcon1 = true
        showIcon2 = true
        showIcon3 = true
        showIcon4 = true
        newIcons.removeAll()
        newIcons2.removeAll()
        showResetButton = false
        randomizeIconPositions()
    }
}

//class MusicPlayer {
//    static let shared = MusicPlayer()
//    var audioPlayer: AVAudioPlayer?
//    private var volumeBeforeMute: Float = 1.0
//    
//    func playBackgroundMusic() {
//        guard let path = Bundle.main.path(forResource: "backgroundMusics", ofType: "mp3") else {
//            return
//        }
//        
//        let url = URL(fileURLWithPath: path)
//        
//        do {
//            audioPlayer = try AVAudioPlayer(contentsOf: url)
//            audioPlayer?.numberOfLoops = -1
//            audioPlayer?.currentTime = 15
//            self.audioPlayer?.play()
//        } catch {
//        }
//    }
//    
//    func stopBackgroundMusic() {
//        audioPlayer?.stop()
//    }
//    
//    func muteBackgroundMusic() {
//        guard let player = audioPlayer else { return }
//        volumeBeforeMute = player.volume
//        player.volume = 0
//    }
//    
//    func unmuteBackgroundMusic() {
//        guard let player = audioPlayer else { return }
//        player.volume = volumeBeforeMute
//    }
//}

//class SoundEffectPlayer {
//    static let shared = SoundEffectPlayer()
//    private var audioPlayer: AVAudioPlayer?
//    private var audioPlayers: [String: AVAudioPlayer] = [:]
//
//    private init() {
//        loadSound(named: "suarakintsugi")
//        loadSound(named: "suarapecah")
//    }
//
//    private func loadSound(named soundName: String) {
//        guard let soundURL = Bundle.main.url(forResource: soundName, withExtension: "mp3") else {
//            print("Unable to find sound file named \(soundName)")
//            return
//        }
//
//        do {
//            let player = try AVAudioPlayer(contentsOf: soundURL)
//            audioPlayers[soundName] = player
//        } catch {
//            print("Failed to load sound: \(error.localizedDescription)")
//        }
//    }
//
//    func playSoundEffect(named soundName: String) {
//        guard let player = audioPlayers[soundName] else {
//            print("Sound not loaded: \(soundName)")
//            return
//        }
//
//        player.play()
//    }
//}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
