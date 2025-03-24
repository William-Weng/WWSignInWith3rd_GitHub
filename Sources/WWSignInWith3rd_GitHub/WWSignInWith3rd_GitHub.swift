
import UIKit
import WebKit
import WWNetworking
import WWSignInWith3rd_Apple

// MARK: - 第三方登入
extension WWSignInWith3rd {
    
    /// [Authorizing OAuth Apps](https://docs.github.com/en/developers/apps/building-oauth-apps/authorizing-oauth-apps)
    open class GitHub: NSObject {
        
        public static let shared = GitHub()

        public typealias ResponseInformation = (data: Data?, response: HTTPURLResponse?)   // 網路回傳的資料
        
        private let GitHubURL: (william: String, authorize: String, accessToken: String, user: String, login: String) = (
            william: "https://william-weng.github.io/",
            authorize: "https://github.com/login/oauth/authorize",
            accessToken: "https://github.com/login/oauth/access_token",
            user: "https://api.github.com/user",
            login: "https://github.com/login"
        )
        
        private(set) var clientId: String?
        private(set) var secret: String?
        private(set) var callbackURL: String?
        private(set) var scope: String?
        
        private var completionBlock: ((Result<Data?, Error>) -> Void)?
        private var navigationController = UINavigationController()
        
        private override init() {}
    }
}

// MARK: - @objc
extension WWSignInWith3rd.GitHub {
    
    /// [按下取消按鍵的動作](https://www.jianshu.com/p/0adaa6ddd260)
    /// - Parameters:
    ///   - sender: UIBarButtonItem
    ///   - event: UIEvent
    @objc func dismissNavigationController(_ sender: UIBarButtonItem, event: UIEvent) {
        navigationController.dismiss(animated: true) {
            self.completionBlock?(.failure(Constant.MyError.isCancel))
        }
    }
}

// MARK: - WKNavigationDelegate & WKUIDelegate
extension WWSignInWith3rd.GitHub: WKNavigationDelegate & WKUIDelegate {
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping ((WKNavigationResponsePolicy) -> Void)) {
        signInAction(webView, decidePolicyFor: navigationResponse)
        decisionHandler(.allow)
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension WWSignInWith3rd.GitHub: UIAdaptivePresentationControllerDelegate {
    
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        self.completionBlock?(.failure(Constant.MyError.isCancel))
    }
}

// MARK: - WWSignInWith3rd.GitHub (public function)
public extension WWSignInWith3rd.GitHub {
    
    /// [參數設定](https://www.jianshu.com/p/78d186aeb526)
    /// - Parameters:
    ///   - clientId: [String](https://zhuanlan.zhihu.com/p/26754921)
    ///   - secret: [String](https://www.open-open.com/lib/view/open1440845454263.html)
    ///   - callbackURL: [String](https://www.ruanyifeng.com/blog/2019/04/github-oauth.html)
    ///   - scope: String
    func configure(clientId: String, secret: String, callbackURL: String, scope: String = "user:email") {
        
        self.clientId = clientId
        self.secret = secret
        self.callbackURL = callbackURL
        self.scope = scope
    }
    
    /// [登入 - 網頁](https://github.com/settings/applications)
    /// - Parameters:
    ///   - viewController: [UIViewController](https://www.ruanyifeng.com/blog/2019/04/github-oauth.html)
    ///   - completion: Result<Data?, Error>
    func loginWithWeb(presenting viewController: UIViewController, completion: ((Result<Data?, Error>) -> Void)?) {
        
        guard let clientId = clientId,
              let scope = scope,
              let urlString = Optional.some("\(GitHubURL.authorize)?client_id=\(clientId)&scope=\(scope)")
        else {
            completionBlock?(.failure(Constant.MyError.unregistered)); return
        }
        
        completionBlock = completion
        
        let navigationController = signInNavigationController(with: urlString)
        viewController.present(navigationController, animated: true) {
            navigationController.presentationController?.delegate = self
        }
    }
    
    /// [登出 - 清除GitHub偷偷存在WebView裡面的Cookie值 => 記錄登入的值](https://stackoverflow.com/questions/31289838/how-to-delete-wkwebview-cookies)
    /// - Parameters:
    ///   - key: [Cookie的Key值 => WKWebsiteDataRecord.displayName = github.com]
    ///   - completion: (Bool)
    func logoutWithWeb(contains key: String = "github.com", completion: ((Bool) -> Void)?) {
        
        WKWebsiteDataStore.default()._cleanWebsiteData(contains: key) { isSuccess in
            completion?(isSuccess)
        }
    }
}

// MARK: - WWSignInWith3rd.GitHub (private function)
private extension WWSignInWith3rd.GitHub {
    
    /// 產生要登入的ViewController
    /// - Parameters:
    ///   - urlString: String
    ///   - title: String
    /// - Returns: UINavigationController
    func signInNavigationController(with urlString: String, title: String = "GitHub第三方登入") -> UINavigationController {
        
        let rootViewController = UIViewController()
        let webView = WKWebView._build(delegate: self, frame: .zero, configuration: WKWebViewConfiguration(), contentInsetAdjustmentBehavior: .automatic)
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissNavigationController(_:event:)))
        
        _ = webView._load(urlString: urlString, timeoutInterval: .infinity)
        rootViewController.view = webView
        rootViewController.navigationItem.title = title
        rootViewController.navigationItem.setLeftBarButton(cancelItem, animated: true)
        navigationController = UINavigationController(rootViewController: rootViewController)

        return navigationController
    }
    
    /// [第三方登入的過程 - OAuth 2.0](https://www.ruanyifeng.com/blog/2014/05/oauth_2_0.html)
    /// - Parameters:
    ///   - webView: WKWebView
    ///   - navigationResponse: WKNavigationResponse
    func signInAction(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse) {
        
        guard let url = navigationResponse.response.url,
              let callbackURL = callbackURL,
              url.absoluteString.contains(callbackURL),
              let client_id = self.clientId,
              let client_secret = self.secret,
              let queryItems = URLComponents(string: url.absoluteString)?.queryItems,
              let code = queryItems.first(where: { item in return item.name == "code" })?.value
        else {
            return
        }
        
        let paramaters = ["client_id": "\(client_id)", "client_secret": "\(client_secret)", "code": "\(code)"]
        
        WWNetworking.shared.request(httpMethod: .POST, urlString: GitHubURL.accessToken, contentType: .formUrlEncoded, paramaters: paramaters, headers: nil) { result in
            
            switch result {
            case .failure(let error): self.completionBlock?(.failure(error))
            case .success(let info):
                
                guard let accessToken = self.gitHubAccessToken(with: info) else { return }
                
                let headers = ["\(WWNetworking.HTTPHeaderField.authorization)": "\(WWNetworking.ContentType.bearer(forKey: accessToken))"]
                
                WWNetworking.shared.request(httpMethod: .GET, urlString: self.GitHubURL.user, contentType: .formUrlEncoded, paramaters: nil, headers: headers) { _result in
                    
                    switch _result {
                    case .failure(let error): self.completionBlock?(.failure(error))
                    case .success(let info):
                        self.completionBlock?(.success(info.data))
                        DispatchQueue.main.async { self.navigationController.dismiss(animated: true) {}}
                    }
                }
            }
        }
    }
    
    /// 解析回傳回來的資訊 => 取得access_token
    /// - Parameter info: Constant.ResponseInformation
    /// - Returns: String
    func gitHubAccessToken(with info: ResponseInformation) -> String? {
        
        guard let queryString = info.data?._string(),
              let _urlString = Optional.some("\(self.GitHubURL.william)?\(queryString)"),
              let queryItems = URLComponents(string: _urlString)?.queryItems,
              let accessToken = queryItems.first(where: { item in return item.name == "access_token" })?.value
        else {
            return nil
        }
        
        return accessToken
    }
}

