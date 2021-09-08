//
//  LoginView.swift
//  DSSwiftUI
//
//  Created by Matt Gannon on 7/30/21.
//

import SwiftUI

struct LoginView: View {
    
    @StateObject var viewModel:LoginViewModel = LoginViewModel()
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                
                if let token = viewModel.token {
                    Text(token)
                } else {
                    Text("No token")
                }
                
                Button("Get Token") {
                    viewModel.requestToken()
                }

                Button("Get identity") {
                    viewModel.getIdentity()
                }
                
                Button("Empty Empties") {
                    CoreDataManager.shared.deleteCollections(emptyOnly: true)
                }
                
                Button("Delete all CoreData") {
                    CoreDataManager.shared.deleteCollections(emptyOnly: false)
                }

                Spacer()
            }
            .padding(24)
            
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
