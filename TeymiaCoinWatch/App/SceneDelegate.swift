import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        
        let tabBarController = UITabBarController()
        
        // Markets
        let marketsVC = MarketsListViewController()
        marketsVC.title = "Markets"
        let marketsNav = UINavigationController(rootViewController: marketsVC)
        marketsNav.tabBarItem = UITabBarItem(title: "Markets", image: UIImage(named: "bar.chart.fill"), tag: 0)
        marketsNav.navigationBar.prefersLargeTitles = true
        
        // Watchlist
        let watchlistVC = UIViewController()
        watchlistVC.view.backgroundColor = .systemBackground
        watchlistVC.title = "Watchlist"
        let watchlistNav = UINavigationController(rootViewController: watchlistVC)
        watchlistNav.tabBarItem = UITabBarItem(title: "Watchlist", image: UIImage(named: "star.fill"), tag: 1)
        
        // News
        let newsVC = UIViewController()
        newsVC.view.backgroundColor = .systemBackground
        newsVC.title = "News"
        let newsNav = UINavigationController(rootViewController: newsVC)
        newsNav.tabBarItem = UITabBarItem(title: "News", image: UIImage(named: "newspaper.fill"), tag: 2)
        
        // Settings
        let settingsVC = UIViewController()
        settingsVC.view.backgroundColor = .systemBackground
        settingsVC.title = "Settings"
        
        let settingsNav = UINavigationController(rootViewController: settingsVC)
        settingsNav.navigationBar.prefersLargeTitles = true
        settingsNav.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape.fill"), tag: 3)
        
        tabBarController.viewControllers = [marketsNav, watchlistNav, newsNav, settingsNav]
        
        tabBarController.tabBar.tintColor = .systemIndigo
        
        window.rootViewController = tabBarController
        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

