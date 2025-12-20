//
//  CoachViewWithQuestion.swift
//  idda
//
//  Created for CoachView with initial question
//

import SwiftUI

struct CoachViewWithQuestion: View {
    let initialQuestion: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            CoachView(initialQuestion: initialQuestion)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Close") {
                            dismiss()
                        }
                        .foregroundColor(.accentGreen)
                    }
                }
        }
    }
}


