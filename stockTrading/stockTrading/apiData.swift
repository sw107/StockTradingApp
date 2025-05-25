//
//  appkey.swift
//  stockTrading
//
//  Created by 최승원 on 5/25/25.
//

import Foundation

let AppKey: String = "PSVb75TVOoTs7WClqZJuazZY72Z02Leh9Qcq"
let AppSecret: String = "i87lycD6sQaRQjhEdo9kMMnF9C0m+dY5iOP8DNTtF9PWwp9BIe1G7tc852MktHQ74igRDSa2r1MvVgfrTP2zE0slDd23npvOaMnvU+2vXCU1fVJGXpf9bb2u5MHHl2UiZXe/Tm34XibXCyX+vzYRckKjTt4FFnXaM97UHTwZnGpBCg6DIh4="
let AccessToken: String = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJ0b2tlbiIsImF1ZCI6IjIxOWVjMDM4LTZiOWUtNDNiNy05ZjNiLTdkYzAwN2Q2Y2FkNyIsInByZHRfY2QiOiIiLCJpc3MiOiJ1bm9ndyIsImV4cCI6MTc0ODI2NDAwMiwiaWF0IjoxNzQ4MTc3NjAyLCJqdGkiOiJQU1ZiNzVUVk9vVHM3V0NscVpKdWF6Wlk3MlowMkxlaDlRY3EifQ.nbf701R-S48nC8PZ2qqRJBtF3TH8ekDcU0vF-6WHbHshCJfql079MjusnbzTwHe836N0YSp4YdTpeCsCNWlOrg"

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
