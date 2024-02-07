//
//  UserAPI.swift
//  Where42
//
//  Created by 현동호 on 11/28/23.
//

import SwiftUI

struct CreateMemberDTO: Codable {
    var intraId: Int
    var intraName: String?
    var grade: Int?
    var image: String?
}

struct UpdateCommentDTO: Codable {
    var comment: String?
}

struct UpdateCustomLocationDTO: Codable {
    var customLocation: String?
}

struct DeleteMemberDTO: Codable {
    var intraId: Int
}

class MemberAPI: API {
    static let shared = MemberAPI()

    override private init() {}

    func getMemberInfo(intraId: Int) async throws -> MemberInfo? {
        guard let requestURL = URL(string: baseURL + "/member?intraId=\(intraId)") else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: requestURL)
        print("getMemberInfo token: ", MemberAPI.sharedAPI.accessToken)
        request.addValue(MemberAPI.sharedAPI.accessToken, forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

//            print(String(data: data, encoding: String.Encoding.utf8)!)

            guard let response = response as? HTTPURLResponse else {
                throw NetworkError.invalidHTTPResponse
            }

            switch response.statusCode {
            case 200 ... 299:
                if response.mimeType == "text/html" {
                    return nil
                } else {
                    return try JSONDecoder().decode(MemberInfo.self, from: data)
                }

            case 300 ... 399:
                throw NetworkError.BadRequest

            case 400 ... 499:
                let response = String(data: data, encoding: String.Encoding.utf8)!
                if response.contains("errorCode") && response.contains("errorMessage") {
                    let customException = parseCustomException(response: response)
                    if customException.handleError() == false {
                        try await MemberAPI.sharedAPI.reissue()
                        throw NetworkError.Reissue
//                        return (nil, requestURL.absoluteString)
                    }
                } else {
                    throw NetworkError.BadRequest
                }

            case 500 ... 599:
                throw NetworkError.ServerError

            default: print("Unknown HTTP Response Status Code")
            }
        } catch NetworkError.Reissue {
            throw NetworkError.Reissue
        } catch {
            errorPrint(error, message: "Failed to get member infomation")
        }
        return nil
    }

    func deleteMember(intraId: Int) async throws -> Bool {
        guard let requestBody = try? JSONEncoder().encode(DeleteMemberDTO(intraId: intraId)) else {
            throw NetworkError.invalidRequestBody
        }

        guard let requestURL = URL(string: baseURL + "/member") else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(MemberAPI.sharedAPI.accessToken, forHTTPHeaderField: "Authorization")
        request.httpBody = requestBody

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let response = response as? HTTPURLResponse else {
                throw NetworkError.invalidHTTPResponse
            }

            switch response.statusCode {
            case 200 ... 299:
                return true

            case 400 ... 499:
                let response = String(data: data, encoding: String.Encoding.utf8)!
                if response.contains("errorCode") && response.contains("errorMessage") {
                    let customException = parseCustomException(response: response)
                    if customException.handleError() == false {
                        try await MemberAPI.sharedAPI.reissue()
                    }
                } else {
                    throw NetworkError.BadRequest
                }

            case 500 ... 599:
                throw NetworkError.ServerError

            default: print("Unknown HTTP Response Status Code")
            }
        } catch {
            errorPrint(error, message: "Failed to delete member")
        }
        return false
    }

    func updateStatusMessage(statusMessage: String) async throws -> String? {
        guard let requestBody = try? JSONEncoder().encode(UpdateCommentDTO(comment: statusMessage)) else {
            throw NetworkError.invalidRequestBody
        }
//        print(String(data: requestBody, encoding: String.Encoding.utf8)!)

        guard let requestURL = URL(string: baseURL + "/member/comment") else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(MemberAPI.sharedAPI.accessToken, forHTTPHeaderField: "Authorization")
        request.httpBody = requestBody

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

//            print(String(data: data, encoding: String.Encoding.utf8)!)

            guard let response = response as? HTTPURLResponse else {
                throw NetworkError.invalidHTTPResponse
            }

            switch response.statusCode {
            case 200 ... 299:
                if response.mimeType == "text/html" {
                    return requestURL.absoluteString
                } else {
                    return try JSONDecoder().decode(MemberInfo.self, from: data).comment
                }

            case 400 ... 499:
                let response = String(data: data, encoding: String.Encoding.utf8)!
                if response.contains("errorCode") && response.contains("errorMessage") {
                    let customException = parseCustomException(response: response)
                    if customException.handleError() == false {
                        try await MemberAPI.sharedAPI.reissue()
                        throw NetworkError.Reissue
//                        return requestURL.absoluteString
                    }
                } else {
                    throw NetworkError.BadRequest
                }

            case 500 ... 599:
                throw NetworkError.ServerError

            default: print("Unknown HTTP Response Status Code")
            }
        } catch NetworkError.Reissue {
            throw NetworkError.Reissue
        } catch {
            errorPrint(error, message: "Failed to update status message")
        }
        return nil
    }

    func updateCustomLocation(customLocation: String) async throws -> String? {
        guard let requestBody = try? JSONEncoder().encode(UpdateCustomLocationDTO(customLocation: customLocation)) else {
            throw NetworkError.invalidRequestBody
        }

        guard let requestURL = URL(string: baseURL + "/location/custom") else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(MemberAPI.sharedAPI.accessToken, forHTTPHeaderField: "Authorization")
        request.httpBody = requestBody

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let response = response as? HTTPURLResponse else {
                throw NetworkError.invalidHTTPResponse
            }

//            print(String(data: data, encoding: String.Encoding.utf8)!)

            print(response.statusCode)
            switch response.statusCode {
            case 200 ... 299:
                if response.mimeType == "text/html" {
                    return requestURL.absoluteString
                } else {
                    print("Succeed update Custom Location")
                    return try JSONDecoder().decode(UpdateCustomLocationDTO.self, from: data).customLocation
                }

            case 400 ... 499:
                let response = String(data: data, encoding: String.Encoding.utf8)!
                if response.contains("errorCode") && response.contains("errorMessage") {
                    let customException = parseCustomException(response: response)
                    if customException.handleError() == false {
                        try await MemberAPI.sharedAPI.reissue()
                        throw NetworkError.Reissue
//                        return requestURL.absoluteString
                    }
                } else {
                    throw NetworkError.BadRequest
                }

            case 500 ... 599:
                throw NetworkError.ServerError

            default: print("Unknown HTTP Response Status Code")
            }
        } catch NetworkError.Reissue {
            throw NetworkError.Reissue
        } catch {
            errorPrint(error, message: "Failed to update custom location")
        }
        return nil
    }
}
