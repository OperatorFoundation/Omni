//
//  Omni.swift
//
//

import Foundation
import Logging

import KeychainTypes
import ReplicantSwift
import TransmissionAsync

public class Omni
{
    let replicant: Replicant
    let logger: Logger
    
    public init(logger: Logger)
    {
        self.replicant = Replicant(logger: logger)
        self.logger = logger
    }
    
    public func listen(config: OmniServerConfig) throws -> AsyncListener
    {
        let serverToneburst = Omnitone(.POP3Server)
        let polishConfig = PolishServerConfig(serverAddress: config.serverAddress, serverPrivateKey: config.serverPrivateKey)
        let replicantConfig = try ReplicantConfig.ServerConfig(serverAddress: config.serverAddress, polish: polishConfig, toneBurst: serverToneburst)
        return try ReplicantListener(config: replicantConfig, logger: logger)
    }
    
    public func connect(config: OmniClientConfig) async throws -> AsyncConnection
    {
        let clientToneburst = Omnitone(.POP3Client)
        let polishConfig = PolishClientConfig(serverAddress: config.serverAddress, serverPublicKey: config.serverPublicKey)
        let replicantConfig = try ReplicantConfig.ClientConfig(serverAddress: config.serverAddress, polish: polishConfig, toneBurst: clientToneburst)
        let network = try await AsyncTcpSocketConnection(config.serverIP, Int(config.serverPort), logger)
        
        return try await replicant.replicantClientTransformation(connection: network, config: replicantConfig, logger: logger)
    }

}
