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
    let logger: Logger
    
    public init(logger: Logger)
    {
        self.logger = logger
    }
    
    public func listen(config: OmniServerConfig) throws -> AsyncListener
    {
        let serverToneburst = Omnitone(.POP3Server)
        let polishConfig = PolishServerConfig(serverAddress: config.serverAddress, serverPrivateKey: config.serverPrivateKey)
        let replicant = Replicant(logger: self.logger, polish: polishConfig, toneburst: serverToneburst)
        return try ReplicantListener(replicant: replicant, serverIP: config.serverIP, serverPort: Int(config.serverPort), logger: self.logger)
    }
    
    public func connect(config: OmniClientConfig) async throws -> AsyncConnection
    {
        let clientToneburst = Omnitone(.POP3Client)
        let polishConfig = PolishClientConfig(serverAddress: config.serverAddress, serverPublicKey: config.serverPublicKey)
        let replicant = Replicant(logger: self.logger, polish: polishConfig, toneburst: clientToneburst)
        let network = try await AsyncTcpSocketConnection(config.serverIP, Int(config.serverPort), logger)
        
        return try await replicant.replicantClientTransformation(connection: network)
    }

}
