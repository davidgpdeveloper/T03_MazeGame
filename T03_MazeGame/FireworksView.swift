//
//  FireworksView.swift
//  T03_MazeGame
//

import SwiftUI

struct FireworkParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var vx: CGFloat
    var vy: CGFloat
    var color: Color
    var opacity: Double = 1.0
    var scale: CGFloat = 1.0
}

struct FireworksView: View {
    @State private var particles: [FireworkParticle] = []
    @State private var timer: Timer?

    let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink, .white]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.opacity(0.4)
                ForEach(particles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: 8, height: 8)
                        .scaleEffect(particle.scale)
                        .opacity(particle.opacity)
                        .position(x: particle.x, y: particle.y)
                }
            }
            .onAppear {
                launchFireworks(in: geo.size)
            }
            .onDisappear {
                timer?.invalidate()
            }
        }
        .ignoresSafeArea()
    }

    private func launchFireworks(in size: CGSize) {
        var launchCount = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { t in
            launchCount += 1
            if launchCount > 7 { t.invalidate(); return }
            let cx = CGFloat.random(in: size.width * 0.2 ... size.width * 0.8)
            let cy = CGFloat.random(in: size.height * 0.15 ... size.height * 0.65)
            burst(cx: cx, cy: cy, in: size)
        }
        // Initial burst immediately
        let cx = CGFloat.random(in: size.width * 0.2 ... size.width * 0.8)
        let cy = CGFloat.random(in: size.height * 0.15 ... size.height * 0.65)
        burst(cx: cx, cy: cy, in: size)
    }

    private func burst(cx: CGFloat, cy: CGFloat, in size: CGSize) {
        let count = 30
        let color = colors.randomElement()!
        var newParticles: [FireworkParticle] = (0..<count).map { _ in
            let angle = CGFloat.random(in: 0 ..< 2 * .pi)
            let speed = CGFloat.random(in: 40 ... 120)
            return FireworkParticle(
                x: cx, y: cy,
                vx: cos(angle) * speed,
                vy: sin(angle) * speed,
                color: color
            )
        }
        particles.append(contentsOf: newParticles)

        let startIndex = particles.count - count
        let fps: CGFloat = 60
        let duration: CGFloat = 1.2
        let steps = Int(fps * duration)
        var step = 0

        Timer.scheduledTimer(withTimeInterval: 1 / fps, repeats: true) { t in
            step += 1
            if step >= steps {
                t.invalidate()
                particles.removeAll { p in newParticles.contains(where: { $0.id == p.id }) }
                return
            }
            let progress = CGFloat(step) / CGFloat(steps)
            for i in 0..<newParticles.count {
                newParticles[i].x += newParticles[i].vx / fps
                newParticles[i].y += newParticles[i].vy / fps
                newParticles[i].vy += 80 / fps  // gravity
                newParticles[i].opacity = Double(1 - progress)
                newParticles[i].scale = 1 - progress * 0.5

                if let idx = particles.firstIndex(where: { $0.id == newParticles[i].id }) {
                    particles[idx] = newParticles[i]
                }
            }
        }
    }
}

#Preview {
    FireworksView()
}
