//
//  OmniConfig.swift
//
//

import Foundation

import KeychainTypes

public class OmniConfig: Codable
{
    public let serverAddress: String
    public let serverIP: String
    public let serverPort: UInt16
    public var transportName = "Omni"
    
    private enum CodingKeys : String, CodingKey
    {
        case serverAddress
        case transportName = "transport"
    }
    
    public init(serverAddress: String) throws
    {
        self.serverAddress = serverAddress
        
        let addressStrings = serverAddress.replacingOccurrences(of: " ", with: "").split(separator: ":")
        self.serverIP = String(addressStrings[0])
        guard let port = UInt16(addressStrings[1]) else
        {
            print("Error decoding OmniServerConfig data: invalid server port \(addressStrings[1])")
            throw OmniError.missingPortInformation(address: serverAddress)
        }
        
        self.serverPort = port
    }
    
    required public init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let address = try container.decode(String.self, forKey: .serverAddress)
        let addressStrings = address.replacingOccurrences(of: " ", with: "").split(separator: ":")
        let ipAddress = String(addressStrings[0])
        guard let port = UInt16(addressStrings[1]) else
        {
            print("Error decoding OmniConfig data: invalid server port")
            throw OmniError.missingPortInformation(address: address)
        }
        
        self.serverAddress = address
        self.serverIP = ipAddress
        self.serverPort = port
        self.transportName = try container.decode(String.self, forKey: .transportName)
    }
}

public class OmniServerConfig: OmniConfig, Equatable
{
    public static func == (lhs: OmniServerConfig, rhs: OmniServerConfig) -> Bool 
    {
        return lhs.serverPrivateKey == rhs.serverPrivateKey && lhs.serverAddress == rhs.serverAddress
    }
    
    public static let serverConfigFilename = "OmniServerConfig.json"
    public let serverPrivateKey: PrivateKey
    
    private enum CodingKeys : String, CodingKey
    {
        case serverPrivateKey
    }
    
    public init(serverAddress: String, serverPrivateKey: PrivateKey) throws
    {
        self.serverPrivateKey = serverPrivateKey
        try super.init(serverAddress: serverAddress)
    }
    
    required public init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.serverPrivateKey = try container.decode(PrivateKey.self, forKey: .serverPrivateKey)
        try super.init(from: decoder)
    }

    
    public convenience init(from data: Data) throws
    {
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(OmniServerConfig.self, from: data)
        try self.init(serverAddress: decoded.serverAddress, serverPrivateKey: decoded.serverPrivateKey)
    }
    
    public convenience init(path: String) throws
    {
        let url = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: url)
        try self.init(from: data)
    }

}

public class OmniClientConfig: OmniConfig, Equatable
{
    public static func == (lhs: OmniClientConfig, rhs: OmniClientConfig) -> Bool
    {
        return lhs.serverPublicKey == rhs.serverPublicKey && lhs.serverAddress == rhs.serverAddress
    }
    
    public static let clientConfigFilename = "OmniClientConfig.json"
    public let serverPublicKey: PublicKey
    
    private enum CodingKeys : String, CodingKey
    {
        case serverPublicKey
    }
    
    public init(serverAddress: String, serverPublicKey: PublicKey) throws
    {
        self.serverPublicKey = serverPublicKey
        try super.init(serverAddress: serverAddress)
    }
    
    public convenience init(from data: Data) throws
    {
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(OmniClientConfig.self, from: data)
        try self.init(serverAddress: decoded.serverAddress, serverPublicKey: decoded.serverPublicKey)
    }
    
    public convenience init(path: String) throws
    {
        let url = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: url)
        try self.init(from: data)
    }
    
    public required init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.serverPublicKey = try container.decode(PublicKey.self, forKey: .serverPublicKey)
        try super.init(from: decoder)
    }
}

public func generateNewConfigPair(serverAddress: String) throws -> (serverConfig: OmniServerConfig, clientConfig: OmniClientConfig)
{
    let privateKey = try PrivateKey(type: .P256KeyAgreement)
    let publicKey = privateKey.publicKey

    let serverConfig = try OmniServerConfig(serverAddress: serverAddress, serverPrivateKey: privateKey)
    let clientConfig = try OmniClientConfig(serverAddress: serverAddress, serverPublicKey: publicKey)
    
    return (serverConfig, clientConfig)
}

public func createNewConfigFiles(inDirectory saveDirectory: URL, serverAddress: String) throws
{
    guard saveDirectory.hasDirectoryPath else
    {
        throw OmniError.urlIsNotDirectory(urlPath: saveDirectory.path)
    }

    let configPair = try generateNewConfigPair(serverAddress: serverAddress)
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
    
    let serverJson = try encoder.encode(configPair.serverConfig)
    let serverConfigFilePath = saveDirectory.appendingPathComponent(OmniServerConfig.serverConfigFilename).path
    
    guard FileManager.default.createFile(atPath: serverConfigFilePath, contents: serverJson) else
    {
        throw OmniError.failedToSaveFile(filePath: serverConfigFilePath)
    }

    let clientJson = try encoder.encode(configPair.clientConfig)
    let clientConfigFilePath = saveDirectory.appendingPathComponent(OmniClientConfig.clientConfigFilename).path

    guard FileManager.default.createFile(atPath: clientConfigFilePath, contents: clientJson) else
    {
        throw OmniError.failedToSaveFile(filePath: clientConfigFilePath)
    }
}
