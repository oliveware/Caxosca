//
//  ContentView.swift
//  testCaxosca
//
//  Created by Herve Crespel on 19/11/2026.
//

import SwiftUI
import UniformTypeIdentifiers

struct SecretNetwork: View {

    @StateObject private var client = Caxosca(
        url: URL(string: "http://192.168.1.41:3500/private")!,
        cleAcces: "cle123"
    )

    @State private var resultat = ""
    @State private var erreur = ""
    @State private var upload = false
    @State private var uploadata: [String: AnyCodable] = [:]
    
    var body:some View {
        if client.serveurIndisponible {
            VStack{
                Label {
                    Text("Coffre-fort arrêté ou inaccessible")
                } icon: {
                    Image(systemName: "exclamationmark.triangle.fill")
                }
                .foregroundColor(.red)
                Button("restart"){
                    client.serveurIndisponible = false
                    client.fermer()
                }
            }
        } else {
            dialogue
        }
    }

    var dialogue: some View {
        VStack(spacing: 20) {

            if !client.dialogueOuvert {
                Button("Ouvrir le dialogue") {
                    Task {
                        await ouvrir()
                    }
                }
            } else {
                
                Text("Actions disponibles :")
                    .font(.headline)
                HStack{
                    ForEach(client.actions, id: \.self) { action in
                        if action == "UPLOAD" {
                            Button(action) { upload = true }
                                .fileImporter(
                                    isPresented: $upload,
                                    allowedContentTypes: [.item]
                                ) { resultat in
                                    switch resultat {
                                    case .success(let url):
                                        Task {
                                            await uploader(url)
                                        }
                                    case .failure(let erreur):
                                        print(erreur)
                                    }
                                }
                        } else {
                            Button(action) {
                                Task {
                                    await executer(action)
                                }
                            }
                        }
                    }
                }
                
                Divider()
                
                ScrollView {
                    Text(resultat)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
                
                if !erreur.isEmpty {
                    Text(erreur)
                        .foregroundColor(.red)
                }
                
                Button("Fermer le dialogue") {
                    client.fermer()
                    resultat = ""
                    erreur = ""
                }
            }
        }
    }

    private func ouvrir() async {
        do {
            let osca = try await client.ouvrir()

            resultat = String(
                describing: osca.data
            )

            erreur = ""

        } catch {
            erreur = error.localizedDescription
        }
    }

    private func executer(_ action: String) async {
        do {
            var data: [String: AnyCodable] = [:]

            if action == "LIRE" {
                data["identifiant"] = AnyCodable(125)
            }
            if action == "LIREFICHIER" {
                data["fichier"] = AnyCodable("document.txt")
            }
            if action == "ECRIREFICHIER" {
                data["fichier"] = AnyCodable("écrit.txt")
                data["contenu"] = AnyCodable("un contenu vraiment très étrange !!!")
            }
            if action == "UPLOAD" {
                data = uploadata
            }

            let osca = try await client.executer(
                action,
                data: data
            )

            resultat = String(
                describing: osca.data
            )

            erreur = ""

        } catch {
            erreur = error.localizedDescription
        }
    }
    
    func uploader(_ url: URL) async  {
        let acces = url.startAccessingSecurityScopedResource()
        defer {
            if acces {
                url.stopAccessingSecurityScopedResource()
            }
        }

        do {
            let contenu = try Data(contentsOf: url)
            let typeMIME = UTType(filenameExtension: url.pathExtension)?
                .preferredMIMEType ?? "application/octet-stream"

            let donnees: [String: AnyCodable] = [
                "fichier": AnyCodable(url.lastPathComponent),
                "typeMIME": AnyCodable(typeMIME),
                "encodage": AnyCodable("base64"),
                "contenu": AnyCodable(contenu.base64EncodedString())
            ]
            uploadata = donnees
            //print(donnees["fichier"] ?? "none")
            await executer("UPLOAD")
        } catch {
            print("Erreur upload :", error)
        }
    }
}

#Preview {
    SecretNetwork()
}
