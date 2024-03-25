//
//  EmailDetailView.swift
//  Email Alias
//
//  Created by Sven Op de Hipt on 18.02.24.
//

import SwiftUI

struct EmailDetailView: View {
    let email: Email
    
    @AppStorage(.email) private var address: String = ""
    @State private var additionalGotos = ""
    
    var body: some View {
        VStack {
            EmailQRView(email: email)
            Text(email.address)
            TextField("Additional destinations", text: $additionalGotos)
            Button("Save") {
                Task {
                    email.goto = [address] + additionalGotos.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    let _ = try? await API.update(email: email)
                }
            }
        }
        .onAppear {
            calculateGotos()
        }
        .onChange(of: email) {
            calculateGotos()
        }
        .padding()
        .navigationTitle(email.privateComment)
    }
    
    private func calculateGotos() {
        var gotos: [String] = []
        for goto in email.goto {
            if goto != address {
                gotos.append(goto)
            }
        }
        additionalGotos = gotos.joined(separator: ",")
    }
}

#Preview {
    NavigationStack {
        EmailDetailView(email: testEmails.first!)
    }
}
