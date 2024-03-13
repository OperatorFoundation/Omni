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
            let clientConfigPath = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("OmniClientConfig.json")
            let clientMessage = "pass"
            let logger = Logger(label: "Omni")
            let client = Omni(logger: logger)
            
            guard let clientConfig = OmniConfig.ClientConfig(path: clientConfigPath.path) else
            {
                XCTFail()
                return
            }
                    
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
            XCTFail()
        }
    }
}
