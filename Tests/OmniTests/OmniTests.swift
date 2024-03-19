import XCTest

import Logging

@testable import Omni

final class OmniTests: XCTestCase {
    func testExample() throws {
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest

        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
    }
    
    func testOmniClientToEchoServer() async
    {
        do
        {
            let clientConfigPath = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("OmniClientConfig.json")
            let clientMessage = "pass"
            let logger = Logger(label: "Omni")
            let client = Omni(logger: logger)
            
            let clientConfig = try OmniClientConfig(path: clientConfigPath.path)
            print("☞ Parsed Omni Client config")
            
            let connection = try await client.connect(config: clientConfig)
            print("☞ Omni Client connected to the server.")
            
            try await connection.writeString(string: clientMessage)
            print("☞ Omni Client wrote to the server.")
            
            let response = try await connection.read()
            print("☞ Omni Client read from the server: \(response.string)")
            
            XCTAssertEqual(clientMessage, response.string)
        }
        catch
        {
            print("Omni Echo test encountered an error: \(error)")
            XCTFail()
        }
    }
    
    func testGenerateConfigs() throws
    {
        do
        {
            let configPair  = try generateNewConfigPair(serverAddress: "127.0.0.1:1234")
            print("Generated config pair")
            
            let clientConfig = configPair.clientConfig
            let serverConfig = configPair.serverConfig
            
            print("ClientConfig: ")
            print("ServerAddress: \(clientConfig.serverIP)")
            print("ServerPort: \(clientConfig.serverPort)")
            print("ServerPublicKey: \(clientConfig.serverPublicKey)")
            print("TransportName: \(clientConfig.transportName)")
            
            print("ServerConfig: ")
            print("ServerAddress: \(serverConfig.serverIP)")
            print("ServerPort: \(serverConfig.serverPort)")
            print("ServerPrivateKey: \(serverConfig.serverPrivateKey)")
            print("TransportName: \(serverConfig.transportName)")
        }
        catch
        {
            print("Could not generate new config pair \(error)")
            XCTFail()
        }
    }
    
    func testCreateNewConfigFiles() throws
    {
        let serverAddress = "127.0.0.1:1234"
        let saveDirectory = FileManager.default.homeDirectoryForCurrentUser
        let serverConfigFilePath = saveDirectory.appendingPathComponent(OmniServerConfig.serverConfigFilename).path
        let clientConfigFilePath = saveDirectory.appendingPathComponent(OmniClientConfig.clientConfigFilename).path
        
        try createNewConfigFiles(inDirectory: saveDirectory, serverAddress: serverAddress)
        print()
        
        let newClientConfig = try OmniClientConfig(path: clientConfigFilePath)
        print("Found a new OmniClientConfig")
        print("Server public key: \(newClientConfig.serverPublicKey)")
        
        let newServerConfig = try OmniServerConfig(path: serverConfigFilePath)
        print("Found a new OmniServerConfig")
        print("Server private key: \(newServerConfig.serverPrivateKey)")
        
    }
}
