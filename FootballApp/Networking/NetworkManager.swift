//
//  Networkmanager.swift
//  FootballApp
//
//  Created by Kerimov Qehreman on 27.09.26.
//


import Foundation

final class NetworkManager {
     let session: URLSession
     let mainPath : String
     let header : [String:String]
    
    
    init(
        session : URLSession ,
        mainPath : String ,
        header: [ String:String]
    ){
        self.session = session
        self.mainPath = mainPath
        self.header = header
    }
    
    func request <T : Decodable>(
        endPoint : EndPoint ,
        completion: @escaping (Result<T,Error>) -> Void){
            let builtRequest = urlRequest(endPoint: endPoint)
            let callback : (Result<T,Error>) -> Void = {result in
                DispatchQueue.main.async {
                    completion(result)
                }
            }
            switch builtRequest {
            case .success(let urlRequest):
                session.dataTask(with: urlRequest) { data, response, error in
                    if let error { callback(.failure(error)); return }
                    guard let http = response as? HTTPURLResponse else {
                        callback(.failure(LocalError.invalidResponse)); return
                    }
                    guard let data else { callback(.failure(LocalError.noData)); return }
                    guard (200..<300).contains(http.statusCode) else {
                        if var model = try? JSONDecoder().decode(ErrorModel.self, from: data) {
                            model.setStatusCode(statusCode: http.statusCode)
                            callback(.failure(LocalError.backEndError(model)))
                        } else {
                            callback(.failure(LocalError.invalidResponse))
                        }
                        return
                    }
                    do {
                        callback(.success(try JSONDecoder().decode(T.self, from: data)))
                    } catch {
                        callback(.failure(LocalError.invalidDecode))
                    }
                }.resume()
            case .failure(let error):
                callback(.failure(error))
            }
            
        }
    func urlRequest(endPoint : EndPoint ) -> Result<URLRequest, Error>{
        let path = "\(mainPath)\(endPoint.path)"
        guard var url = URL(string: path) else {
            return  .failure(LocalError.invalidURL)
            
        }
        url.append(queryItems: endPoint.queryItems )
        var urlReuqest = URLRequest(url: url)
        header.forEach({
            urlReuqest.setValue($1 , forHTTPHeaderField: $0)
        })
        urlReuqest.httpMethod = endPoint.method.rawValue
        if let body = endPoint.requestBody {
            switch body {
            case .rawdata(let  data) :
                urlReuqest.httpBody = data
            case .encodable(let encodable) :
                do {
                    urlReuqest.httpBody = try JSONEncoder().encode(encodable)
                } catch {
                    return .failure(error)
                }
            case .dictionary(let dictionary) :
                do {
                    let data = try JSONSerialization.data( withJSONObject: dictionary )
                    urlReuqest.httpBody = data
                } catch {
                    return .failure(error)
                }
            }
        }
        return.success(urlReuqest)
    }
    
    func loadData(urlString : String , completion : @escaping (Result<Data, Error>)->Void){
        let callback : (Result<Data,Error>) -> Void = {result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        guard let url = URL(string: urlString) else {
            callback(.failure(LocalError.invalidURL))
            return
        }
        session.dataTask(with: url, completionHandler: { data , response, error in
            if let error = error {
                callback(.failure(error))
                return
            }
            
            guard let data = data else {
                callback(.failure(LocalError.noData))
                return
            }
            callback(.success(data))
            
        }).resume()
    }
}
    
enum LocalError: LocalizedError {
    case invalidURL
    case invalidResponse
    case invalidData
    case invalidDecode
    case backEndError(ErrorModel)
    case noData

    /// `error.localizedDescription` (Error tipi üzərindən) məhz bunu qaytarır.
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .invalidData:
            return "Invalid data"
        case .invalidDecode:
            return "Could not read the server response"
        case .noData:
            return "No data"
        case .backEndError(let error):
            return error.errorDescription
        }
    }
}
