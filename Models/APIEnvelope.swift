import Foundation

struct APIEnvelope<Payload: Codable & Sendable>: Codable, Sendable {
    let requestID: String
    let code: Int
    let message: String
    let retryable: Bool
    let payload: Payload

    enum CodingKeys: String, CodingKey {
        case requestID = "request_id"
        case code
        case message
        case retryable
        case payload
    }
}
