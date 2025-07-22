import Foundation

struct StockAPI {
    static func fetchPrice(for stockNum: String, completion: @escaping (Result<StockQuote, Error>) -> Void) {
        guard !stockNum.isEmpty else { return }

        let urlStr = "https://openapi.koreainvestment.com:9443/uapi/domestic-stock/v1/quotations/inquire-price?fid_cond_mrkt_div_code=J&fid_input_iscd=\(stockNum)"
        
        guard let url = URL(string: urlStr) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(AccessToken)", forHTTPHeaderField: "authorization")
        request.setValue(AppKey, forHTTPHeaderField: "appKey")
        request.setValue(AppSecret, forHTTPHeaderField: "appSecret")
        request.setValue("FHKST01010100", forHTTPHeaderField: "tr_id")

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }

            do {
                let decoded = try JSONDecoder().decode(ApiResponse.self, from: data)
                completion(.success(decoded.output))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
