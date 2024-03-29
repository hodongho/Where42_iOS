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
    var intraId: Int
    var comment: String?
}

struct UpdateCustomLocationDTO: Codable {
    var intraId: Int
    var customLocation: String?
}

struct ResponseCustomLocationDTO: Codable {
    var intraId: Int
    var imacLocation: String
    var customLocation: String
}

struct DeleteMemberDTO: Codable {
    var intraId: Int
}

class MemberAPI: API {
    func createMember(memberCreateDTO: CreateMemberDTO) async throws -> MemberInfo? {
        guard let requestBody = try? JSONEncoder().encode(memberCreateDTO) else {
            throw NetworkError.invalidRequestBody
        }

        guard let requestURL = URL(string: baseURL + "/member/") else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestBody

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let response = response as? HTTPURLResponse else {
                throw NetworkError.invalidHTTPResponse
            }

            switch response.statusCode {
            case 200 ... 299:
                return try JSONDecoder().decode(MemberInfo.self, from: data)

            case 400 ... 499:
                throw NetworkError.BadRequest

            case 500 ... 599:
                throw NetworkError.ServerError

            default: print("Unknown HTTP Response Status Code")
            }
        } catch {
            print("Failed create Member")
        }
        return nil
    }

    func getMemberInfo(intraId: Int) async throws -> (MemberInfo?, String?) {
        guard let requestURL = URL(string: baseURL + "/member?intraId=\(intraId)") else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: requestURL)
        print(token)
        request.addValue(token, forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            print(String(data: data, encoding: String.Encoding.utf8)!)

            guard let response = response as? HTTPURLResponse else {
                throw NetworkError.invalidHTTPResponse
            }

            switch response.statusCode {
            case 200 ... 299:
                if response.mimeType == "text/html" {
//                    print(requestURL.absoluteString)
                    return (nil, requestURL.absoluteString)
                } else {
                    return try (JSONDecoder().decode(MemberInfo.self, from: data), nil)
                }
            case 300 ... 399:
                print("Redirect")
                throw NetworkError.BadRequest

            case 401:
                return (nil, requestURL.absoluteString)

            case 400 ... 499:
                throw NetworkError.BadRequest

            case 500 ... 599:
                throw NetworkError.ServerError

            default: print("Unknown HTTP Response Status Code")
            }
        } catch {
            errorPrint(error, message: "Failed to get member infomation")
        }
        return (nil, nil)
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
        request.addValue(token, forHTTPHeaderField: "Authorization")
        request.httpBody = requestBody

        do {
            let (_, response) = try await URLSession.shared.data(for: request)

            guard let response = response as? HTTPURLResponse else {
                throw NetworkError.invalidHTTPResponse
            }

            switch response.statusCode {
            case 200 ... 299:
                if response.mimeType == "text/html" {
                    isLogin = false
                    throw NetworkError.Token
                } else {
                    return true
                }

            case 400 ... 499:
                throw NetworkError.BadRequest

            case 500 ... 599:
                throw NetworkError.ServerError

            default: print("Unknown HTTP Response Status Code")
            }
        } catch {
            errorPrint(error, message: "Failed to delete member")
        }
        return false
    }

    func updateStatusMessage(intraId: Int, statusMessage: String) async throws -> String? {
        guard let requestBody = try? JSONEncoder().encode(UpdateCommentDTO(intraId: intraId, comment: statusMessage)) else {
            throw NetworkError.invalidRequestBody
        }
//        print(String(data: requestBody, encoding: String.Encoding.utf8)!)

        guard let requestURL = URL(string: baseURL + "/member/comment") else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(token, forHTTPHeaderField: "Authorization")
        request.httpBody = requestBody

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            print(String(data: data, encoding: String.Encoding.utf8)!)

            guard let response = response as? HTTPURLResponse else {
                throw NetworkError.invalidHTTPResponse
            }

            switch response.statusCode {
            case 200 ... 299:
                if response.mimeType == "text/html" {
                    isLogin = false
                    throw NetworkError.Token
                } else {
                    return try JSONDecoder().decode(MemberInfo.self, from: data).comment
                }

            case 400 ... 499:
                throw NetworkError.BadRequest

            case 500 ... 599:
                throw NetworkError.ServerError

            default: print("Unknown HTTP Response Status Code")
            }
        } catch {
            errorPrint(error, message: "Failed to update status message")
        }
        return nil
    }

    func updateCustomLocation(intraId: Int, customLocation: String) async throws -> String? {
        guard let requestBody = try? JSONEncoder().encode(UpdateCustomLocationDTO(intraId: intraId, customLocation: customLocation)) else {
            throw NetworkError.invalidRequestBody
        }

        guard let requestURL = URL(string: baseURL + "/location/custom") else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(token, forHTTPHeaderField: "Authorization")
        request.httpBody = requestBody

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let response = response as? HTTPURLResponse else {
                throw NetworkError.invalidHTTPResponse
            }

            switch response.statusCode {
            case 200 ... 299:
                if response.mimeType == "text/html" {
                    isLogin = false
                    throw NetworkError.Token
                } else {
                    print("Succeed update Custom Location")
                    return try JSONDecoder().decode(ResponseCustomLocationDTO.self, from: data).customLocation
                }
            case 400 ... 499:
                throw NetworkError.BadRequest

            case 500 ... 599:
                throw NetworkError.ServerError

            default: print("Unknown HTTP Response Status Code")
            }
        } catch {
            errorPrint(error, message: "Failed to update custom location")
        }
        return nil
    }
}
