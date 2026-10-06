

import Foundation

public protocol BackendError: Error, Decodable {
   var message: String { get }
   var code: String { get }
}

 enum AppError<E: BackendError>: Error {
   case invalidURL
   case noInternetConnection
   case timeout
   case noData

   case badRequest              // 400
   case unauthorized            // 401
   case forbidden               // 403
   case notFound                // 404
   case serverError(statusCode: Int)  // 500...599

   case decodingFailed

   case backend(E)
   case problem(ProblemDetails)

   case unknown(Error)
}

extension AppError: LocalizedError {
   public var errorDescription: String? {
       switch self {
       case .invalidURL:
           return "Daxili xəta baş verdi. Zəhmət olmasa yenidən cəhd edin."
       case .noInternetConnection:
           return "İnternet bağlantınız yoxdur. Zəhmət olmasa bağlantını yoxlayıb yenidən cəhd edin."
       case .timeout:
           return "Sorğu vaxtı bitdi. Zəhmət olmasa yenidən cəhd edin."
       case .noData:
           return "Serverdən cavab alına bilmədi."
       case .badRequest:
           return "Göndərilən məlumatda problem var."
       case .unauthorized:
           return "Sessiyanızın vaxtı bitib. Zəhmət olmasa yenidən daxil olun."
       case .forbidden:
           return "Bu əməliyyat üçün icazəniz yoxdur."
       case .notFound:
           return "Axtardığınız məlumat tapılmadı."
       case .serverError:
           return "Serverdə problem yarandı. Bir az sonra yenidən cəhd edin."
       case .decodingFailed:
           return "Məlumat oxuna bilmədi. Zəhmət olmasa tətbiqi yeniləyin."
       case .backend(let envelope):
           return envelope.message
       case .problem(let problem):
           return problem.detail ?? problem.title ?? "Naməlum xəta baş verdi."
       case .unknown(let error):
           return error.localizedDescription
       }
   }

   public var backendCode: String? {
       if case .backend(let envelope) = self {
           return envelope.code
       }
       if case .problem(let problem) = self {
           return problem.errorCode
       }
       return nil
   }
}

extension AppError {

   public static func map(
       data: Data?,
       response: URLResponse?,
       error: Error?,
       errorDecoder: (Data) -> Error?
   ) -> AppError? {
       if let urlError = error as? URLError {
           switch urlError.code {
           case .notConnectedToInternet,
                .networkConnectionLost,
                .dataNotAllowed:
               return .noInternetConnection
           case .timedOut:
               return .timeout
           default:
               return .unknown(urlError)
           }
       }

       if let error {
           return .unknown(error)
       }
       if let httpResponse = response as? HTTPURLResponse {
           let statusCode = httpResponse.statusCode
           if !(200...299).contains(statusCode) {
               if let data, let problem = try? JSONDecoder().decode(ProblemDetails.self, from: data) {
                   return .problem(problem)
               }
               if let data,
                  let backendError = errorDecoder(data) as? E {
                   return .backend(backendError)
               }
               switch statusCode {
               case 400: return .badRequest
               case 401:  return .unauthorized
               case 403: return .forbidden
               case 404: return .notFound
               case 500...599: return .serverError(statusCode: statusCode)
               default:
                   return .unknown(
                       NSError(
                           domain: "AppError",
                           code: statusCode
                       )
                   )
               }
           }
       }

       return nil
   }
}



