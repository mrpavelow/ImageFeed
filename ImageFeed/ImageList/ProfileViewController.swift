import UIKit

final class ProfileViewController: UIViewController {
    private var label: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let profilePageView = UIView()
        profilePageView.backgroundColor = UIColor(named: "YPBlack")
        profilePageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profilePageView)
        profilePageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        profilePageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        profilePageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        profilePageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        let profileImage = UIImage(named: "UserPic")
        let imageView = UIImageView(image: profileImage)
        imageView.tintColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        let nameLabel = UILabel()
        nameLabel.text = "Екатерина Новикова"
        nameLabel.textColor = .white
        nameLabel.font = UIFont.boldSystemFont(ofSize: 23)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        nameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true
        self.label = nameLabel
        
        let hashtagLabel = UILabel()
        hashtagLabel.text = "@ekaterina_nov"
        hashtagLabel.textColor = UIColor(named: "YPGray")
        hashtagLabel.font = UIFont.systemFont(ofSize: 13)
        hashtagLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hashtagLabel)
        hashtagLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        hashtagLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        self.label = hashtagLabel
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Hello, World!"
        descriptionLabel.textColor = .white
        descriptionLabel.font = UIFont.systemFont(ofSize: 13)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        descriptionLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: hashtagLabel.bottomAnchor, constant: 8).isActive = true
        self.label = descriptionLabel
        
        let logoutButton = UIButton(
            type: .custom
        )
        logoutButton.setImage(UIImage(named: "LogOutButton"), for: .normal,)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
        logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        logoutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 45).isActive = true
        logoutButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        logoutButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        logoutButton.addTarget(self, action: #selector(didTapLogout), for: .touchUpInside)
    }
    
    @objc func didTapLogout() {
        print("Выход")
    }
}
