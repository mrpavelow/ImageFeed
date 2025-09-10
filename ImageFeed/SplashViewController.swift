import UIKit

final class SplashViewController: UIViewController {

    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let storage = OAuth2TokenStorage.shared
    private let profileService = ProfileService()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let token = storage.token {
            fetchProfile(token: token)
        } else {
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")

        window.rootViewController = tabBarController
    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers.first as? AuthViewController
            else {
                assertionFailure("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
                return
            }

            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController, token: String) {
        vc.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }

            self.storage.token = token

            self.fetchProfile(token: token)
        }
    }
}

extension SplashViewController {
    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        ProfileService.shared.fetchProfile(token: token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()

            guard let self = self else { return }

            switch result {
            case .success(let profile):
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { imageResult in
                    switch imageResult {
                    case .success(let url):
                        print("Аватарка успешно загружена: \(url)")
                    case .failure(let error):
                        print("Ошибка загрузки аватарки: \(error)")
                    }
                }

                self.switchToTabBarController()

            case .failure(let error):
                print("Ошибка загрузки профиля: \(error)")
            }
        }
    }
}
