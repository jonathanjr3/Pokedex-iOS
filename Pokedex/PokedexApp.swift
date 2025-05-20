//
//  PokedexApp.swift
//  Pokedex
//
//  Created by Jonathan Rajya on 10/05/2025.
//

import SwiftData
import SwiftUI

@main
struct PokedexApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State var networkMonitor = NetworkMonitor()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .fontDesign(.rounded)
                .environment(networkMonitor)
        }
        .modelContainer(for: FavouritePokemon.self)
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }
}

class SceneDelegate: NSObject, UIWindowSceneDelegate {
    var quickAction: UIApplicationShortcutItem?

    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        Utilities.quickActionManager.handle(shortcutItem)
        completionHandler(true)
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let shortcutItem = connectionOptions.shortcutItem {
            Utilities.quickActionManager.handle(shortcutItem)
        }
    }
}

@Observable
class QuickActionManager {
    var selectedAction: QuickActionType?

    func handle(_ shortcutItem: UIApplicationShortcutItem) {
        switch shortcutItem.type {
        case QuickActionType.viewFavourites.rawValue:
            selectedAction = .viewFavourites
        case QuickActionType.search.rawValue:
            selectedAction = .search
        default:
            break
        }
    }
}

enum QuickActionType: String {
    case viewFavourites = "com.jonathan.Pokedex.viewFavourites"
    case search = "com.jonathan.Pokedex.search"
    case none
}
