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
    
    func testCreateNewConfigPair() throws
    {
        let serverAddress = "127.0.0.1:1234"
        let saveDirectory = FileManager.default.homeDirectoryForCurrentUser
        
        do
        {
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
        catch
        {
            print("Could not generate new config pair: \(error)")
            XCTFail()
        }
        
    }
}
