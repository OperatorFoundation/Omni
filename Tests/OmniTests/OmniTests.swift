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
    
    func testOmniClientToEchoServerLargeMessage() async
    {
        do
        {
            let clientConfigPath = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("OmniClientConfig.json")
            let clientMessage = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
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
    
    func testOmniClientToEchoServerLargeMessage100Times() async
    {
        do
        {
            let clientConfigPath = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("OmniClientConfig.json")
            let clientMessage = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
            let logger = Logger(label: "Omni")
            let client = Omni(logger: logger)
            
            let clientConfig = try OmniClientConfig(path: clientConfigPath.path)
            print("☞ Parsed Omni Client config")
            
            let connection = try await client.connect(config: clientConfig)
            print("☞ Omni Client connected to the server.")
            
            for messageCount in 1...100
            {
                try await connection.writeString(string: clientMessage)
                print("☞ Omni Client wrote to the server \(messageCount) time/s.")
                
                let response = try await connection.read()
                print("☞ Omni Client read from the server: \(response.string)")
                
                XCTAssertEqual(clientMessage, response.string)
            }
        }
        catch
        {
            print("Omni Echo test encountered an error: \(error)")
            XCTFail()
        }
    }
    
    func testOmniClientToEchoServerMultipleTimesThenRead() async
    {
        do
        {
            let clientConfigPath = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("OmniClientConfig.json")
            let clientMessage = "pass"
            let logger = Logger(label: "Omni")
            let client = Omni(logger: logger)
            
            var messageCount = 1
            
            let clientConfig = try OmniClientConfig(path: clientConfigPath.path)
            print("☞ Parsed Omni Client config")
            
            let connection = try await client.connect(config: clientConfig)
            print("☞ Omni Client connected to the server.")
            
            while (messageCount <= 10)
            {
                try await connection.writeString(string: clientMessage)
                print("☞ Omni Client wrote to the server \(messageCount) time/s.")
                messageCount += 1
            }
            
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
    
    func testOmniClientToEchoServerWriteAndRead100Times() async
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
            
            for messageCount in 1...100
            {
                try await connection.writeString(string: clientMessage)
                print("☞ Omni Client wrote to the server \(messageCount) time/s.")
                
                let response = try await connection.read()
                print("☞ Omni Client read from the server: \(response.string)")
                
                XCTAssertEqual(clientMessage, response.string)
            }
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
            let configPair  = try OmniConfig.generateNewConfigPair(serverAddress: "127.0.0.1:1234")
            print("Generated config pair")
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
        
        try OmniConfig.createNewConfigFiles(inDirectory: saveDirectory, serverAddress: serverAddress)
        print()
        
        let newClientConfig = try OmniClientConfig(path: clientConfigFilePath)
        print("Found a new OmniClientConfig")
        print("Server public key: \(newClientConfig.serverPublicKey)")
        
        let newServerConfig = try OmniServerConfig(path: serverConfigFilePath)
        print("Found a new OmniServerConfig")
        print("Server private key: \(newServerConfig.serverPrivateKey)")
        
    }
}
