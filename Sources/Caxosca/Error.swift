//
//  Error.swift
//  testCaxosca
//
//  Created by Herve Crespel on 19/11/2026.
//
import SwiftUI

enum CaxoscaError: Error {
    case cleAbsente
    case reponseInvalide
    case dialogueDejaOuvert
    case dialogueFerme
    case actionNonAutorisee
    case serveur(String)

    case urlInvalide
    case erreurReseau(String)
    case reponseHTTP(Int, String)
    case jsonInvalide(String)

    var errorDescription: String? {
        switch self {
        case .urlInvalide:
            return "URL du serveur invalide"

        case .erreurReseau(let message):
            return "Erreur réseau : \(message)"

        case .reponseHTTP(let code, let message):
            return "Erreur HTTP \(code) : \(message)"

        case .jsonInvalide(let message):
            return "Réponse JSON invalide : \(message)"

        case .reponseInvalide:
            return "La réponse du serveur est incomplète"
        case .cleAbsente:
            return "clé absente"
        case .dialogueDejaOuvert:
            return "dialogue déjà ouvert"
        case .dialogueFerme:
            return "dialogue fermé"
        case .actionNonAutorisee:
            return "action non autorisée"
        case .serveur(let message):
            return "pb serveur : \(message)"
        }
    }
}
