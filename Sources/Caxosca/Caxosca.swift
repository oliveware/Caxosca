//
//  Caxosca.swift
//  testCaxosca
//
//  Created by Herve Crespel on 19/11/2026.
//
import Foundation
import Combine

@MainActor
final class Caxosca: ObservableObject {

    @Published private(set) var secret: String?
    @Published private(set) var actions: [String] = []
    @Published private(set) var dialogueOuvert = false
    @Published var serveurIndisponible = false
    @Published var messageErreur: String?

    private let url: URL
    private let cleAcces: String

    init(url: URL, cleAcces: String) {
        self.url = url
        self.cleAcces = cleAcces
    }

    // Structure d'une requête CAXO.
    private struct Caxo: Encodable {
        let action: String
        let data: [String: AnyCodable]
        let secret: String
    }

    // Structure d'une erreur serveur.
    private struct Erreur: Decodable {
        let erreur: Bool
        let code: String
    }

    // Envoi d'une requête et réception d'OSCA.
    private func envoyer(
        action: String,
        data: [String: AnyCodable]
    ) async throws -> Osca {

        let cle = action == "L"
            ? cleAcces
            : secret

        guard let cle else {
            throw CaxoscaError.cleAbsente
        }

        var request = URLRequest(url: url)

        request.httpMethod = "POST"

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        let caxo = Caxo(
            action: action,
            data: data,
            secret: cle
        )

        request.httpBody = try JSONEncoder().encode(caxo)
        do {
            let (responseData, response) =
                try await URLSession.shared.data(for: request)
            
            serveurIndisponible = false
            
                /*print ("HTTP response", response)
                if let contenu = String(data: responseData, encoding:.utf8) {
                    print ("Réponse serveur", contenu)
                }*/

            guard let http = response as? HTTPURLResponse else {
                throw CaxoscaError.reponseInvalide
            }

            guard (200...299).contains(http.statusCode) else {

                if let erreur = try? JSONDecoder().decode(
                    Erreur.self,
                    from: responseData
                ) {
                    throw CaxoscaError.serveur(erreur.code)
                }

                let message = String(data: responseData, encoding: .utf8) ?? ""
                       throw CaxoscaError.reponseHTTP(http.statusCode, message)
            }

            let osca = try JSONDecoder().decode(
                Osca.self,
                from: responseData
            )

            // Mise à jour de la clé uniquement après décodage valide.
            secret = osca.secret
            actions = osca.actions

            return osca
        } catch let erreur as URLError {
            serveurIndisponible = true
            messageErreur = "Serveur CaxOsca indisponible. Vérifiez que le serveur est démarré et accessible."

            throw erreur

        } catch {
            messageErreur = error.localizedDescription
            throw error
        }
    }

    // Ouverture du dialogue.
    func ouvrir(
        data: [String: AnyCodable] = [:]
    ) async throws -> Osca {

        guard !dialogueOuvert else {
            throw CaxoscaError.dialogueDejaOuvert
        }

        let osca = try await envoyer(
            action: "L",
            data: data
        )

        dialogueOuvert = true

        return osca
    }

    // Exécution d'une action.
    func executer(
        _ action: String,
        data: [String: AnyCodable] = [:]
    ) async throws -> Osca {

        guard dialogueOuvert else {
            throw CaxoscaError.dialogueFerme
        }

        guard actions.contains(action) else {
            throw CaxoscaError.actionNonAutorisee
        }

        return try await envoyer(
            action: action,
            data: data
        )
    }

    // Fermeture locale du dialogue.
    func fermer() {
        secret = nil
        actions = []
        dialogueOuvert = false
    }
}


