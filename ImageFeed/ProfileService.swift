import Foundation

// MARK: - DTO для Unsplash API
struct ProfileResult: Decodable {
    let id: String
    let updatedAt: String
    let username: String
    let firstName: String?
    let lastName: String?
    let twitterUsername: String?
    let portfolioUrl: String?
    let bio: String?
    let location: String?
    let totalLikes: Int
    let totalPhotos: Int
    let totalCollections: Int
    let downloads: Int?
    let uploadsRemaining: Int?
    let instagramUsername: String?
    let email: String?
    let links: Links
    
    struct Links: Decodable {
        let selfLink: String
        let html: String
        let photos: String
        let likes: String
        let portfolio: String
        
        private enum CodingKeys: String, CodingKey {
            case selfLink = "self"
            case html, photos, likes, portfolio
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case updatedAt = "updated_at"
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case twitterUsername = "twitter_username"
        case portfolioUrl = "portfolio_url"
        case bio
        case location
        case totalLikes = "total_likes"
        case totalPhotos = "total_photos"
        case totalCollections = "total_collections"
        case downloads
        case uploadsRemaining = "uploads_remaining"
        case instagramUsername = "instagram_username"
        case email
        case links
    }
}

// MARK: - UI модель
struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
    
    init(from result: ProfileResult) {
        self.username = result.username
        let first = result.firstName ?? ""
        let last = result.lastName ?? ""
        self.name = "\(first) \(last)".trimmingCharacters(in: .whitespaces)
        self.loginName = "@\(result.username)"
        self.bio = result.bio
    }
}

// MARK: - Сервис профиля
final class ProfileService {
    static let shared = ProfileService()
    
    private let tokenStorage = OAuth2TokenStorage()
    private var isFetching = false
    init() {}
    private(set) var profile: Profile?
    
    func fetchProfile(token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        guard !isFetching else {
            print("Запрос уже выполняется")
            return
        }

        guard let url = URL(string: "https://api.unsplash.com/me") else { return }
        guard let token = tokenStorage.token else {
            print("Токен не найден")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        isFetching = true

        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            defer { self?.isFetching = false }

            switch result {
            case .success(let profileResult):
                let profile = Profile(from: profileResult)
                self?.profile = profile
                completion(.success(profile))
            case .failure(let error):
                print("Ошибка ProfileService: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }

        task.resume()
    }
}

