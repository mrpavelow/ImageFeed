import WebKit
import UIKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    
    private init() {}
    
    func logout() {
        OAuth2TokenStorage.shared.token = nil
        cleanCookies()
        ProfileService.shared.resetProfile()
        ProfileImageService.shared.resetAvatarURL()
        ImagesListService.shared.resetPhotosArray()
        switchToLoginScreen()
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func switchToLoginScreen() {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.connectedScenes
                    .compactMap({ $0 as? UIWindowScene })
                    .first?.windows
                    .first else { return }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "AuthViewController")
            
            window.rootViewController = loginVC
            window.makeKeyAndVisible()
        }
    }
}
