//
//  appkey.swift
//  stockTrading
//
//  Created by 최승원 on 5/25/25.
//

import Foundation

struct SecretManager {
    static let shared = SecretManager()
    
    private var secrets: [String: Any] = [:]

        private init() {
            if let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
               let data = try? Data(contentsOf: url),
               let result = try? PropertyListSerialization.propertyList(from: data, format: nil),
               let dict = result as? [String: Any] {
                self.secrets = dict
            } else {
                print("❌ Secrets.plist 파싱 실패")
            }
        }

    var appKey: String {
        return secrets["appKey"] as? String ?? ""
    }
    
    var appSecret: String {
        return secrets["appSecret"] as? String ?? ""
    }
}

let AppKey = SecretManager.shared.appKey
let AppSecret = SecretManager.shared.appSecret
var AccessToken: String = ""


struct TokenStorage {
    static let tokenKey = "access_token_key"
    static let dateKey = "access_token_date"

    // 토큰 저장 (현재 시간도 함께 저장)
    static func save(token: String) {
        UserDefaults.standard.set(token, forKey: tokenKey)
        UserDefaults.standard.set(Date(), forKey: dateKey)
    }

    // 저장된 토큰과 날짜 불러오기
    static func load() -> (token: String, isValid: Bool)? {
        guard let token = UserDefaults.standard.string(forKey: tokenKey),
              let date = UserDefaults.standard.object(forKey: dateKey) as? Date else {
            return nil
        }

        let elapsed = Date().timeIntervalSince(date)
        let isValid = elapsed < (60 * 60 * 24)  // 24시간 이내면 유효

        return (token, isValid)
    }
}



func requestAccessToken(completion: @escaping (String?) -> Void) {
    
    if let stored = TokenStorage.load(), stored.isValid {
        completion(stored.token)
        return
    }
    
    let url = URL(string: "https://openapi.koreainvestment.com:9443/oauth2/tokenP")!
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let body: [String: Any] = [
        "grant_type": "client_credentials",
        "appkey": AppKey,
        "appsecret": AppSecret
    ]
    
    request.httpBody = try? JSONSerialization.data(withJSONObject: body)
    
    URLSession.shared.dataTask(with: request) { data, _, _ in
        guard let data = data else {
            completion(nil)
            return
        }
        
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let accessToken = json["access_token"] as? String {
            AccessToken = accessToken
            TokenStorage.save(token: accessToken)
            completion(accessToken)
        } else {
            completion(nil)
        }
    }.resume()
}

