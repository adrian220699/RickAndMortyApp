//
//  BiometricManager.swift
//  RickAndMortyApp
//
//  Created by Adrian Flores Herrera on 4/28/26.
//
import Foundation
import LocalAuthentication

final class BiometricManager {

    static let shared = BiometricManager()
    private init() {}

    func authenticate(completion: @escaping (Bool) -> Void) {

        let context = LAContext()
        context.localizedCancelTitle = "Cancelar"

        let reason = "Accede a tus favoritos"

        var error: NSError?

        let policy: LAPolicy = .deviceOwnerAuthentication

        guard context.canEvaluatePolicy(policy, error: &error) else {

            print("canEvaluatePolicy falló:", error?.localizedDescription ?? "sin error")

            DispatchQueue.main.async {
                completion(false)
            }
            return
        }

        context.evaluatePolicy(policy, localizedReason: reason) { success, error in

            if let error = error {
                print("evaluatePolicy error:", error.localizedDescription)
            }

            print("Biometría resultado:", success)

            DispatchQueue.main.async {
                completion(success)
            }
        }
    }
}
