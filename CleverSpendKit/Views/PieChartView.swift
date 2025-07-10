import SwiftUI

struct PieChartView: View {
    let data: [CategoryData]
    let showPercentages: Bool
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let total = data.reduce(0) { $0 + $1.amount }
            let angles = pieAngles()
            
            ZStack {
                // Glass background for better contrast
                RoundedRectangle(cornerRadius: size/2)
                    .fill(Color(.systemBackground).opacity(0.45))
                    .background(.ultraThinMaterial)
                    .frame(width: size, height: size)
                    .shadow(radius: 10)
                ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                    let startAngle = angles[index].0
                    let endAngle = angles[index].1
                    let midAngle = Angle(degrees: (startAngle.degrees + endAngle.degrees) / 2)
                    let segmentColor = Color(item.color)
                    
                    Path { path in
                        path.move(to: center)
                        path.addArc(
                            center: center,
                            radius: size / 2,
                            startAngle: startAngle,
                            endAngle: endAngle,
                            clockwise: false
                        )
                    }
                    .fill(
                        LinearGradient(
                            colors: [segmentColor.opacity(0.85), segmentColor.opacity(0.55)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: segmentColor.opacity(0.18), radius: 8, x: 0, y: 4)
                    .overlay(
                        Path { path in
                            path.move(to: center)
                            path.addArc(
                                center: center,
                                radius: size / 2,
                                startAngle: startAngle,
                                endAngle: endAngle,
                                clockwise: false
                            )
                        }
                        .stroke(Color.black.opacity(0.12), lineWidth: 2)
                    )
                    
                    if showPercentages && item.amount > 0 {
                        let percent = item.percentage
                        let labelRadius = size * 0.33
                        let labelX = center.x + labelRadius * CGFloat(cos(midAngle.radians))
                        let labelY = center.y + labelRadius * CGFloat(sin(midAngle.radians))
                        Text("\(Int(percent * 100))%")
                            .font(.caption2.bold())
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.7), radius: 2, x: 0, y: 1)
                            .overlay(
                                Text("\(Int(percent * 100))%")
                                    .font(.caption2.bold())
                                    .foregroundColor(.black.opacity(0.25))
                                    .offset(x: 1, y: 1)
                            )
                            .position(x: labelX, y: labelY)
                    }
                }
                Circle()
                    .fill(Color(.systemBackground).opacity(0.38))
                    .frame(width: size * 0.62, height: size * 0.62)
            }
            .frame(width: size, height: size)
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    private func pieAngles() -> [(Angle, Angle)] {
        var angles: [(Angle, Angle)] = []
        let total = data.reduce(0) { $0 + $1.amount }
        var start: Double = -90 // Start at top
        for item in data {
            let percent = total > 0 ? item.amount / total : 0
            let degrees = percent * 360
            let end = start + degrees
            angles.append((Angle(degrees: start), Angle(degrees: end)))
            start = end
        }
        return angles
    }
}

#Preview {
    PieChartView(
        data: [
            CategoryData(id: UUID(), name: "Food", amount: 120, percentage: 0.4, color: "blue"),
            CategoryData(id: UUID(), name: "Transport", amount: 90, percentage: 0.3, color: "red"),
            CategoryData(id: UUID(), name: "Shopping", amount: 90, percentage: 0.3, color: "green")
        ],
        showPercentages: true
    )
    .padding()
    .background(
        LinearGradient(colors: [Color(.systemPurple).opacity(0.13), Color(.systemBlue).opacity(0.10)], startPoint: .topLeading, endPoint: .bottomTrailing)
    )
} 