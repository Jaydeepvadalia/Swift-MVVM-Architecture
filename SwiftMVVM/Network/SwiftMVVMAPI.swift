//
//  SwiftMVVMAPI.swift
//  SwiftMVVM
//
//  Created by jaydeep vadalia on 01/06/22.
//

import Foundation
import Moya

private func JSONResponseDataFormatter(_ data: Data) -> String {
    do {
        let dataAsJSON = try JSONSerialization.jsonObject(with: data)
        let prettyData = try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        return String(data: prettyData, encoding: .utf8) ?? String(data: data, encoding: .utf8) ?? ""
    } catch {
        return String(data: data, encoding: .utf8) ?? ""
    }
}


public enum SwiftMVVMAPI {
    case searchUser(String, Int, Int)
}

extension SwiftMVVMAPI: TargetType {
    public var baseURL: URL {
        switch self {
        default:
            return URL(string: "https://api.github.com/")!
        }
    }
    
    public var path: String {
        switch self {
            case .searchUser:
                return "search/users"
        }
    }
    
    public var method: Moya.Method {
        switch self {
            case .searchUser:
                return .get
        }
    }
    
    public var task: Task {
        switch self {
            case .searchUser(let searchText, let page, let perPage):
            return .requestParameters(parameters: ["q": searchText, "page":page, "per_page":perPage], encoding: URLEncoding.default)
        }
    }
    
    public var headers: [String : String]? {
        return nil
    }
    
    
    
}
