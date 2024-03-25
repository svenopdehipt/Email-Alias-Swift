//
//  AddView.swift
//  Email Alias
//
//  Created by Sven Op de Hipt on 25.10.23.
//

import SwiftUI

struct AddView: View {
    let emails: [Email]
    let addEmail: (String, String, String) async -> Bool

    @Environment(\.dismiss) private var dismiss
    @AppStorage(.email) private var email = ""
    
    @FocusState private var aliasFocused: Bool
    @FocusState private var descriptionFocused: Bool
    @FocusState private var additionalGotoFocused: Bool
    
    @State private var alias = ""
    @State private var comment = ""
    @State private var additionalGoto = ""
    @State private var showExistsAlert = false
    @State private var showFormAlert = false
    
    var body: some View {
        VStack {
            let domain = email.split(separator: "@").last
            HStack(spacing: 0, content: {
                ZStack(alignment: .trailing) {
                    TextField("Alias", text: $alias)
                        .autocorrectionDisabled()
                        .focused($aliasFocused)
                        .onSubmit {
                            descriptionFocused = true
                        }
                    Button {
                        repeat {
                            alias = String.random(length: 20)
                        }
                        while domain != nil && emails.contains { $0.address == "\(alias)@\(domain!)" }
                        descriptionFocused = true
                    } label: {
                        Image(systemName: "dice")
                            .accessibilityLabel(Text("Random alias"))
                    }
                }
                if let domain, !domain.isEmpty {
                    Text("@\(String(domain))")
                }
            })
            Spacer()
                .frame(height: 20)
            TextField("Description", text: $comment)
                .autocorrectionDisabled()
                .focused($descriptionFocused)
                .onSubmit {
                    additionalGotoFocused = true
                }
            Spacer()
                .frame(height: 20)
            TextField("Additional destinations", text: $additionalGoto)
                .autocorrectionDisabled()
                .focused($additionalGotoFocused)
                .onSubmit {
                    Task {
                        await addEmail()
                    }
                }
            Spacer()
                .frame(height: 50)
            Button {
                Task {
                    await addEmail()
                }
            } label: {
                Text("Add email")
            }
        }
        .alert("Email already exists", isPresented: $showExistsAlert) {
            EmptyView()
        }
        .alert("Alias or description shouldn't be empty", isPresented: $showFormAlert) {
            EmptyView()
        }
        .padding()
        .navigationTitle("Add email")
        .frame(maxWidth: 600)
        .onAppear {
            aliasFocused = true
        }
    }
    
    private func addEmail() async {
        if alias.isEmpty || comment.isEmpty {
            showFormAlert = true
            return
        }
        
        if let domain = email.split(separator: "@").last, await addEmail("\(alias)@\(domain)", comment, additionalGoto) {
            dismiss()
            comment = ""
            alias = ""
            additionalGoto = ""
        }
        else {
            showExistsAlert = true
        }
    }
}

#Preview {
    NavigationStack {
        AddView(emails: testEmails) { _, _, _ in
            true
        }
    }
}
