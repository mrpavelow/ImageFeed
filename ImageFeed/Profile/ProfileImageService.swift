import Foundation

final class ProfileImageService {
    static let shared = ProfileImageService()
    private init() {}
    
    private let tokenStorage = OAuth2TokenStorage.shared
    private(set) var avatarURL: String?
    
    static let didChangeNotification = Notification.Name("ProfileImageProviderDidChange")
    
    func resetAvatarURL() {
        avatarURL = nil
    }
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else { return }
        guard let token = tokenStorage.token else { return }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            switch result {
            case .success(let userResult):
                let profileImageURL = userResult.profileImage.small
                self?.avatarURL = profileImageURL
                completion(.success(profileImageURL))
                
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": profileImageURL]
                )
            case .failure(let error):
                print("Ошибка ProfileImageService: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}

struct UserResult: Codable {
    let profileImage: ProfileImage

    private enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

struct ProfileImage: Codable {
    let small: String
}
