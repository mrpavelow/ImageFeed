import UIKit

final class SplashViewController: UIViewController {

    private let storage = OAuth2TokenStorage.shared
    private let profileService = ProfileService()
    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "splash_screen_logo"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let token = storage.token {
            fetchProfile(token: token)
        } else {
            goToAuthScreen()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.ypBlack
        setupUI()
    }

        private func setupUI() {
            view.addSubview(logoImageView)

            NSLayoutConstraint.activate([
                logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                logoImageView.widthAnchor.constraint(equalToConstant: 75),
                logoImageView.heightAnchor.constraint(equalToConstant: 77.68)
            ])
        }

        private func goToAuthScreen() {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }

                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                guard let authVC = storyboard.instantiateViewController(
                    withIdentifier: "AuthViewController"
                ) as? AuthViewController else {
                    fatalError("AuthViewController not found in storyboard")
                }

                authVC.delegate = self
                authVC.modalPresentationStyle = .fullScreen
                self.present(authVC, animated: true)
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
