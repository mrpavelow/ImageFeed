import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {

    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    private let hashtagLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let profilePageView = UIView()
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        updateAvatar()
            updateProfileDetails()
        }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupProfileView()
        setupUserPic()
        setupNameString()
        setupHashtagString()
        setupDescriptionString()
        setupLogoutButton()
        updateProfileDetails()
    }
    

    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let imageUrl = URL(string: profileImageURL)
        else { return }

        print("imageUrl: \(imageUrl)")

        let placeholderImage = UIImage(systemName: "person.circle.fill")?
            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 70, weight: .regular, scale: .large))

        let processor = RoundCornerImageProcessor(cornerRadius: 35) // Радиус для круга
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(
            with: imageUrl,
            placeholder: placeholderImage,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale), // Учитываем масштаб экрана
                .cacheOriginalImage, // Кэшируем оригинал
                .forceRefresh // Игнорируем кэш, чтобы обновить
            ]) { result in

                switch result {
                    // Успешная загрузка
                case .success(let value):
                    // Картинка
                    print(value.image)

                    // Откуда картинка загружена:
                    // - .none — из сети.
                    // - .memory — из кэша оперативной памяти.
                    // - .disk — из дискового кэша.
                    print(value.cacheType)

                    // Информация об источнике.
                    print(value.source)

                    // В случае ошибки
                case .failure(let error):
                    print(error)
                }
            }
    }
    
    private func setupProfileView() {
        profilePageView.backgroundColor = UIColor.ypBlack
        profilePageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profilePageView)
        profilePageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        profilePageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        profilePageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        profilePageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    private func setupUserPic() {
        imageView.image = UIImage(named: "UserPic")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
    }
    
    private func setupNameString() {
        nameLabel.text = "Екатерина Новикова"
        nameLabel.textColor = .white
        nameLabel.font = UIFont.boldSystemFont(ofSize: 23)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        nameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true
    }
    
    private func setupHashtagString() {
        hashtagLabel.text = "@ekaterina_nov"
        hashtagLabel.textColor = UIColor.ypGray
        hashtagLabel.font = UIFont.systemFont(ofSize: 13)
        hashtagLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hashtagLabel)
        hashtagLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        hashtagLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
    }
    
    private func setupDescriptionString() {
        descriptionLabel.text = "Hello, World!"
        descriptionLabel.textColor = .white
        descriptionLabel.font = UIFont.systemFont(ofSize: 13)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        descriptionLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: hashtagLabel.bottomAnchor, constant: 8).isActive = true
    }
    
    private func setupLogoutButton() {
        let logoutButton = UIButton(
            type: .custom
        )
        logoutButton.setImage(UIImage(named: "LogOutButton"), for: .normal)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
        logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        logoutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 45).isActive = true
        logoutButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        logoutButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        logoutButton.addTarget(self, action: #selector(didTapLogout), for: .touchUpInside)
    }
    
    @objc func didTapLogout() {
        let alert = UIAlertController(
                    title: "Пока, пока!",
                    message: "Уверены хотите выйти?",
                    preferredStyle: .alert
                )

                let cancelAction = UIAlertAction(title: "Нет", style: .cancel)

                let logoutAction = UIAlertAction(title: "Да", style: .destructive) { _ in
                    ProfileLogoutService.shared.logout()
                }
                
                alert.addAction(cancelAction)
                alert.addAction(logoutAction)

                present(alert, animated: true)
    }
    
    private func updateProfileDetails() {
        guard let profile = ProfileService.shared.profile else {
            print("Профиль ещё не загружен")
            return
        }
        
        nameLabel.text = profile.name
        hashtagLabel.text = "\(profile.loginName)"
        descriptionLabel.text = profile.bio ?? ""
    }
}
