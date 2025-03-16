//
//  EmptyStateView.swift
//  Recipe App
//
//  Created by Yon Montoto on 3/15/25.
//

import SwiftUI

struct EmptyStateView: View {
    let message: String
    let refreshAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text(message)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: refreshAction) {
                Text("Refresh")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
            }
            .padding(.top, 8)
        }
        .padding()
    }
}

struct EmptyStateView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyStateView(message: "No recipes available") {}
    }
}
