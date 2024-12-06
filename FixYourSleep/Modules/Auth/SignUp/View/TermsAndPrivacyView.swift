//
//  TermsAndPrivacyView.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 6.12.2024.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let urlString: String
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }
}


func loadTextFromFile(_ filename: String) -> String {
    guard let filepath = Bundle.main.path(forResource: filename, ofType: "txt") else {
        return "Could not find \(filename).txt in the app bundle."
    }
    
    do {
        let contents = try String(contentsOfFile: filepath)
        return contents
    } catch {
        return "Could not load \(filename).txt from the app bundle: \(error.localizedDescription)"
    }
}

struct TermsAndPrivacySheet: View {
    @Binding var isPresented: Bool
    @State private var selectedTab = 0
    
    let termsAndConditionsURL = "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"
    let privacyPolicy: String
    
    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
        self.privacyPolicy = loadTextFromFile("Privacy Policy")
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("", selection: $selectedTab) {
                    Text("Terms").tag(0)
                    Text("Privacy").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                if selectedTab == 0 {
                    WebView(urlString: termsAndConditionsURL)
                } else {
                    ScrollView {
                        Text(privacyPolicy)
                            .padding()
                    }
                }
            }
            .navigationBarTitle(selectedTab == 0 ? "Terms and Conditions" : "Privacy Policy", displayMode: .inline)
            .navigationBarItems(trailing: Button("Close") {
                isPresented = false
            })
        }
    }
}
