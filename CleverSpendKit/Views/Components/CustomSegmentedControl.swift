import SwiftUI

struct CustomSegmentedControl: View {
    @Binding var selection: DatePeriod
    let options: [DatePeriod] = [.day, .month, .year, .all]
    let titles: [DatePeriod: String] = [.day: "Day", .month: "Month", .year: "Year", .all: "All"]
    @Namespace private var segmentNamespace

    var body: some View {
        HStack(spacing: 6) {
            ForEach(options, id: \ .self) { option in
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) { selection = option }
                }) {
                    Text(titles[option]!)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(selection == option ? .white : .primary)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 22)
                        .background(
                            ZStack {
                                if selection == option {
                                    LinearGradient(
                                        colors: [Color.blue, Color.purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                    .clipShape(Capsule())
                                    .matchedGeometryEffect(id: "segment", in: segmentNamespace)
                                }
                            }
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemGray6).opacity(0.85))
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .frame(minHeight: 40)
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: selection)
    }
} 