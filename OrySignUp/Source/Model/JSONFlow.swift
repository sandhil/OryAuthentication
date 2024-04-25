import Foundation

struct JSONFlow : Codable {
    let id: String?
    let ui: UIElements?
    let session_token: String?
    let session: OrySession?
}

struct UIElements : Codable {
    let method: String?
    let nodes: [Node?]?
    let messages: [Message?]?
}

struct Node : Codable {
    let type: String?
    let group: String?
    let attributes: Attributes?
    let meta: Meta?
    let messages: [Message?]?
}

struct Attributes: Codable {
    let type: AttributeType?
    let name: String?
    let required: Bool?
    
}

struct Meta: Codable {
    let type: String?
    let name: String?
    let required: Bool?
    let label: Label?
    
}

struct Message: Codable {
    let id: Int?
    let type: String?
    let text: String?
    
}

struct Label: Codable {
    let text: String?
    let id: Int?
    var tag: Int?
    
    private enum CodingKeys: String, CodingKey {
       case text, id
     }

     init(from decoder: Decoder) throws {
       let container = try decoder.container(keyedBy: CodingKeys.self)
       text = try container.decodeIfPresent(String.self, forKey: .text)
       id = try container.decodeIfPresent(Int.self, forKey: .id)
       // Add a random tag during decoding
       tag = Int.random(in: 10000...100000)
     }
}

struct OrySession : Codable {
    let id: String?
    let active: Bool?
}

enum AttributeType: String, Codable {
    case hidden = "hidden"
    case email = "email"
    case password = "password"
    case text = "text"
    case checkbox = "checkbox"
    case submit = "submit"
}


