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
    
    func testOmniClientToEchoServe() async
    {
        do
        {
            let omniClientConfigPath = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("OmniClientConfig.json")
            
            let clientMessage = "pass"
            let logger = Logger(label: "Omni")
            
            let omniClient = Omni(logger: logger)
            
            guard let omniClientConfig = OmniConfig.ClientConfig(path: omniClientConfigPath.path) else
            {
                XCTFail()
                return
            }
                    
            let omniClientConnection = try await omniClient.connect(config: omniClientConfig)
            
            print("OmniClient connected to server.")
            
            try await omniClientConnection.writeString(string: clientMessage)
            
            print("OmniClient wrote to server.")
            
            let response = try await omniClientConnection.read()
            print("Server response: \(response.string)")
            
            XCTAssertEqual(clientMessage, response.string)
        }
        catch
        {
            XCTFail()
        }
    }
}
