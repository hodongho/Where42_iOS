//
//  GroupAPI.swift
//  Where42
//
//  Created by 현동호 on 12/5/23.
//

import SwiftUI

struct CreateGroupDTO: Codable {
    var intraId: Int
    var groupName: String
}

struct UpdateGroupDTO: Codable {
    var groupId: Int
    var groupName: String
}

struct DeleteGroupMemberDTO: Codable {
    var groupId: Int
    var members: [Int]
}

struct AddOneGroupMemberDTO: Codable {
    var intraId: Int
    var groupId: Int
    var groupName: String
}

struct AddGroupMembersDTO: Codable {
    var groupId: Int
    var members: [String]
}

class GroupAPI: API {
    func createGroup(intraId: Int, groupName: String) async throws -> Int? {
        guard let requestBody = try? JSONEncoder().encode(CreateGroupDTO(intraId: intraId, groupName: groupName)) else {
            print("Failed Create Request Body")
            return nil
        }

        guard let requestURL = URL(string: baseURL + "/group") else {
            print("Missing URL")
            return nil
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
                    print("Success")
                    return try JSONDecoder().decode(UpdateGroupDTO.self, from: data).groupId
                }
            case 400 ... 499:
                throw NetworkError.BadRequest
            case 500 ... 599:
                throw NetworkError.ServerError
            default:
                print("Failed Create Group")
            }
        } catch {
            errorPrint(error, message: "Failed Create Group")
        }
        return nil
    }

    func getGroup(intraId: Int) async throws -> [GroupInfo]? {
        guard let requestURL = URL(string: baseURL + "/group?intraId=\(intraId)") else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: requestURL)
        request.addValue(token, forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let response = response as? HTTPURLResponse else {
                throw NetworkError.invalidHTTPResponse
            }

//            print(String(data: data, encoding: .utf8)!)

            switch response.statusCode {
            case 200 ... 299:
                if response.mimeType == "text/html" {
                    isLogin = false
                    throw NetworkError.Token
                } else {
                    print("Succeed get group")
                    return try JSONDecoder().decode([GroupInfo].self, from: data)
                }
            case 400 ... 499:
                throw NetworkError.BadRequest
            case 500 ... 599:
                throw NetworkError.ServerError
            default:
                print("Failed Get Groups")
            }
        } catch {
            errorPrint(error, message: "Failed Get Groups")
        }
        return nil
    }

    func updateGroupName(groupId: Int, newGroupName: String) async throws -> String? {
        guard let requestBody = try? JSONEncoder().encode(UpdateGroupDTO(groupId: groupId, groupName: newGroupName)) else {
            print("Failed Create request Body")
            throw NetworkError.invalidURL
        }

        guard let requestURL = URL(string: baseURL + "/group/name") else {
            print("Missing Error")
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

//            print(String(data: data, encoding: .utf8)!)

            switch response.statusCode {
            case 200 ... 299:
                if response.mimeType == "text/html" {
                    isLogin = false
                    throw NetworkError.Token
                } else {
                    print("Succeed update group name")
                    return try JSONDecoder().decode(UpdateGroupDTO.self, from: data).groupName
                }
            case 400 ... 499:
                throw NetworkError.BadRequest
            case 500 ... 599:
                throw NetworkError.ServerError
            default:
                print("Failed update Group name")
            }

        } catch {
            errorPrint(error, message: "Failed update group name")
        }
        return nil
    }

    func deleteGroup(groupId: Int, groupName: String) async throws -> Bool {
        guard let requestBody = try? JSONEncoder().encode(UpdateGroupDTO(groupId: groupId, groupName: groupName)) else {
            print("Failed encode requestBody")
            throw NetworkError.invalidRequestBody
        }

        guard let requestURL = URL(string: baseURL + "/group?groupId=\(groupId)") else {
            print("Failed encode requestURL")
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        request.addValue("applicaion/json", forHTTPHeaderField: "Content-Type")
        request.addValue(token, forHTTPHeaderField: "Authorization")
        request.httpBody = requestBody

        do {
            let (_, response) = try await URLSession.shared.data(for: request)

            guard let response = response as? HTTPURLResponse else {
                throw NetworkError.invalidHTTPResponse
            }

//            print(String(data: data, encoding: .utf8)!)

            switch response.statusCode {
            case 200 ... 299:
                if response.mimeType == "text/html" {
                    isLogin = false
                    throw NetworkError.Token
                } else {
                    print("Succeed delete group")
                    return true
                }
            case 400 ... 499:
                throw NetworkError.BadRequest
            case 500 ... 599:
                throw NetworkError.ServerError
            default:
                print("Failed delete group")
            }
        } catch {
            errorPrint(error, message: "Failed delete group")
        }
        return false
    }

    func deleteGroupMember(groupId: Int, members: [MemberInfo]) async throws -> Bool {
        let membersIntraId: [Int] = members.map { $0.intraId! }

        guard let requestBody = try? JSONEncoder().encode(DeleteGroupMemberDTO(groupId: groupId, members: membersIntraId)) else {
            print("Failed create request Body")
            throw NetworkError.invalidRequestBody
        }

        guard let requestURL = URL(string: baseURL + "/group/groupmember") else {
            print("Failed create URL")
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(token, forHTTPHeaderField: "Authorization")
        request.httpBody = requestBody

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let response = response as? HTTPURLResponse else {
                throw NetworkError.invalidHTTPResponse
            }

//            print(String(data: data, encoding: .utf8)!)

            switch response.statusCode {
            case 200 ... 299:
                if response.mimeType == "text/html" {
                    isLogin = false
                    throw NetworkError.Token
                } else {
                    print("Succeed delete group")
                    return true
                }
            case 400 ... 499:
                throw NetworkError.BadRequest
            case 500 ... 599:
                throw NetworkError.ServerError
            default:
                print("Failed delete group")
            }
        } catch {
            errorPrint(error, message: "Failed delete group member")
        }
        return false
    }

    func addMembers(groupId: Int, members: [MemberInfo]) async throws -> Bool {
        let members: [String] = members.map { $0.intraName! }

        guard let requsetBody = try? JSONEncoder().encode(AddGroupMembersDTO(groupId: groupId, members: members)) else {
            print("failed create requset body")
            return false
        }

        guard let requestURL = URL(string: baseURL + "/group/groupmember/members") else {
            print("failed create requset URL")
            return false
        }

        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-type")
        request.addValue(token, forHTTPHeaderField: "Authorization")
        request.httpBody = requsetBody

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let response = response as? HTTPURLResponse else {
                throw NetworkError.invalidHTTPResponse
            }

//            print(String(data: data, encoding: .utf8)!)

            switch response.statusCode {
            case 200 ... 299:
                if response.mimeType == "text/html" {
                    isLogin = false
                    throw NetworkError.Token
                } else {
                    print("Succeed add members")
                    return true
                }
            case 400 ... 499:
                throw NetworkError.BadRequest
            case 500 ... 599:
                throw NetworkError.ServerError
            default:
                print("Failed add members")
            }
        } catch {
            errorPrint(error, message: "Failed add members")
        }
        return false
    }

    func addOneMember(groupId: Int, groupName: String, intraId: Int) async throws -> Bool {
        guard let requsetBody = try? JSONEncoder().encode(AddOneGroupMemberDTO(intraId: intraId, groupId: groupId, groupName: groupName)) else {
            print("failed create requset body")
            return false
        }

        guard let requestURL = URL(string: baseURL + "/group/groupmember/members") else {
            print("failed create requset URL")
            return false
        }

        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-type")
        request.addValue(token, forHTTPHeaderField: "Authorization")
        request.httpBody = requsetBody

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let response = response as? HTTPURLResponse else {
                throw NetworkError.invalidHTTPResponse
            }

//            print(String(data: data, encoding: .utf8)!)

            switch response.statusCode {
            case 200 ... 299:
                if response.mimeType == "text/html" {
                    isLogin = false
                    throw NetworkError.Token
                } else {
                    print("Succeed add one member")
                    return true
                }
            case 400 ... 499:
                throw NetworkError.BadRequest
            case 500 ... 599:
                throw NetworkError.ServerError
            default:
                print("Failed add one member")
            }
        } catch {
            errorPrint(error, message: "Failed add one member")
        }
        return false
    }
}
