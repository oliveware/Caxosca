//
//  ContentView.swift
//  testCaxosca
//
//  Created by Herve Crespel on 22/11/2026.
//

import SwiftUI

public struct Networks : View {
    @State var secret: Bool?
    
    public init() {}
    
    public var body: some View {
        VStack {
           nav
            
            if let secret = secret {
                Spacer()
                if secret {
                    SecretNetwork()
                } else {
                    AccessNetwork()
                }
                Spacer()
            }
        }
    }
    var nav: some View {
        HStack {
            Button("secret", action:{secret = true})
                .disabled(secret == true)
            if let secret = secret {
                Spacer()
                Text( secret ? "Réseau secret du coffre-fort" : "Réseau d'accès")
                    //.font(.title)
                Spacer()
            }
            Button("access", action:{secret = false})
                .disabled(secret == false)
        }.padding(20)
    }

}

#Preview {
    Networks().frame(width:600, height:400)
}
