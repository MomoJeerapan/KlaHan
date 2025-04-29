import SwiftUI
import WebKit

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Welcome")
                    .font(.largeTitle)
                    .foregroundColor(Color("PrimaryText"))
                    .bold()

                // ส่วน GIF
                GIFView()
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding()

                // Card แบบ dummy เหมือนรูป
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(.systemGray6))
                    .frame(height: 100)
                    .overlay(
                        HStack {
                            Image(systemName: "photo")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .padding()
                            VStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.green)
                                    .frame(height: 10)
                                HStack {
                                    ForEach(0..<5) { _ in
                                        Image(systemName: "star")
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                    )
                
                Spacer()

                // Tab Bar
                HStack {
                    Spacer()
                    NavigationLink(destination: CommunityView()) {
                        Image(systemName: "person.3")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.black)
                    }
                    Spacer()
                        NavigationLink(destination: TrendView()) {
                            Image(systemName: "chart.bar.xaxis")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .foregroundColor(.black)
                        }
                    Spacer()
                    NavigationLink(destination: ScanView()) {
                        ZStack {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 60, height: 60)
                            Image(systemName: "qrcode.viewfinder")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.white)
                        }
                    }
                    Spacer()
                    NavigationLink(destination: CustomizeView()) {
                        Image(systemName: "gift")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.black)
                    }
                    Spacer()
                    NavigationLink(destination: ProfileView()) {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.black)
                    }
                    Spacer()
                }
                .padding(.vertical, 15)
                .background(Color.white.shadow(radius: 5))
            }
            .padding()
            .background(Color(.systemGroupedBackground))
        }
    }
}

// View สำหรับเล่น GIF (สามารถเปลี่ยน URL เป็นของคุณ)
struct GIFView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        if let path = Bundle.main.path(forResource: "welcome", ofType: "gif") {
            let gifData = try! Data(contentsOf: URL(fileURLWithPath: path))
            webView.load(gifData, mimeType: "image/gif", characterEncodingName: "", baseURL: URL(fileURLWithPath: path))
        }
        webView.isUserInteractionEnabled = false
        webView.scrollView.isScrollEnabled = false
        webView.backgroundColor = .clear
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
