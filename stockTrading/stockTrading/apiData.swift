//
//  appkey.swift
//  stockTrading
//
//  Created by 최승원 on 5/25/25.
//

import Foundation

let AppKey: String = "PSVb79Qcq"
let AppSecret: String = "i87lycD6sQaRQjhEdo9kMMnF9C0m+dY5iOP8DNTtF9PWw4FFnXaM97UHTwZnGpBCg6DIh4="
let AccessToken: String = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIf56AV1k9Yu1nuCDGLvDLZ2AKJu0qfnqpAKDrLXdN9dNvrv-yxKhBBmG07ilDToUVR7ORK5-tWwiaQQ"

func requestAccessToken(completion: @escaping (String?) -> Void) {
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
            completion(accessToken)
        } else {
            completion(nil)
        }
    }.resume()
}
