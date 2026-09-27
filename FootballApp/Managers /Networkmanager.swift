//
//  Networkmanager.swift
//  FootballApp
//
//  Created by Kerimov Qehreman on 27.09.26.
//


import Foundation

final class NetworkManager {
    private  let session: URLSession
    private let mainPath : String
    private let header : [String:String]
    
    
    
    static let shared = NetworkManager(
        session: URLSession.shared ,
        mainPath :  "",
        header: [
            "accept":"application/json",
            "content-type":"application/json",
            
        ])
    init(session : URLSession , mainPath : String , header: [ String:String]){
        self.session = session
        self.mainPath = mainPath
        self.header = header
    }
    
    func request <T : Decodable>(
        endPoint : EndPoint ,
        completion: @escaping (Result<T,Error>) -> Void){
            let urlRequest = urlRequest(endPoint: endPoint)
            let callback : (Result<T,Error>) -> Void = {result in
                DispatchQueue.main.async {
                    completion(result)
                }
            }
            switch urlRequest {
            case .success(let urlRequest):
                session.dataTask(with: urlRequest) { (data, response, error) in
                    if let error = error {
                        callback(.failure(error))
                        return
                    }
                    guard let data else {
                        callback(.failure(LocalError.noData))
                        return
                    }
                    
                    if let result = try? JSONDecoder().decode(T.self, from: data){
                        callback(.success(result))
                    }else {
                        do {
                            let model = try
                            JSONDecoder().decode(ErrorModel.self, from: data)
                            callback(.failure(LocalError.backEndError (model.self)))
                        } catch{
                            callback(.failure(error))
                        }
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
    
    enum LocalError : Error {
        case invalidURL
        case invalidResponse
        case invalidData
        case invalidDecode
        case backEndError(ErrorModel)
        case noData
        
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return " Invalid URL"
        case .invalidResponse :
           return "Invalid Response"
        case .invalidData :
            return "Invalid Data"
        case .invalidDecode :
            return "Invalid Decode "
        
        case . noData :
            return "No Data"
        case  .backEndError(let error) :
            return error.localizedDescription
        }
    }
}
