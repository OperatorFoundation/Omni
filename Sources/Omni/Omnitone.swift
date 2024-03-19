//
//  Omnitone.swift
//
//

import Foundation

import Chord
import Datable
import Ghostwriter
import ReplicantSwift
import TransmissionAsync

public enum OmnitoneMode: String, Codable
{
    case POP3Client
    case POP3Server
    
}

public class Omnitone: ToneBurst
{
    let mode: OmnitoneMode
    
    enum CodingKeys: String, CodingKey
    {
        case mode
    }
    
    public init(_ mode: OmnitoneMode)
    {
        self.mode = mode
        super.init()
    }
    
    required init(from decoder: any Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let superDecoder = try container.superDecoder()
        
        self.mode = try container.decode(OmnitoneMode.self, forKey: .mode)
        try super.init(from: superDecoder)
    }

    public override func perform(connection: TransmissionAsync.AsyncConnection) async throws
    {
        let instance = OmnitoneInstance(self.mode, connection)
        try await instance.perform()
    }
    
    public override func encode(to encoder: any Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.mode, forKey: .mode)
        let superEncoder = container.superEncoder()
        try super.encode(to: superEncoder)
    }
}

public struct OmnitoneInstance
{
    let connection: TransmissionAsync.AsyncConnection
    let mode: OmnitoneMode

    public init(_ mode: OmnitoneMode, _ connection: TransmissionAsync.AsyncConnection)
    {
        self.mode = mode
        self.connection = connection
    }

    public func perform() async throws
    {
        switch mode
        {
            case .POP3Client:
                try await handlePOP3Client()
            
            case .POP3Server:
                try await handlePOP3Server()
        }
    }
    
    func listen(structuredText: StructuredText, maxSize: Int = 255) async throws -> MatchResult
    {
        var buffer = Data()
        while buffer.count < maxSize
        {
            let byte = try await connection.readSize(1)

            buffer.append(byte)

            guard let string = String(data: buffer, encoding: .utf8) else
            {
                // This could fail because we're in the middle of a UTF8 rune.
                continue
            }

            let result = structuredText.match(string: string)
            switch result
            {
                case .FAILURE:
                    return result

                case .SHORT:
                    continue

                case .SUCCESS(_):
                    return result
            }
        }
        
        throw OmnitoneError.maxSizeReached
    }
    
    func speak(structuredText: StructuredText) async throws
    {
        do
        {
            let string = structuredText.string
            try await connection.writeString(string: string)
        }
        catch
        {
            print(error)
            throw OmnitoneError.writeFailed
        }
    }

    private func handlePOP3Server() async throws
    {
        try await Timeout(Duration.seconds(5)).wait
        {
            let _ = try await self.listen(structuredText: StructuredText(TypedText.text("+OK POP3 server ready."), TypedText.newline(Newline.crlf)))
        }

        try await self.speak(structuredText: StructuredText(TypedText.text("STLS"), TypedText.newline(Newline.crlf)))
        try await Timeout(Duration.seconds(5)).wait
        {
            let _ = try await self.listen(structuredText: StructuredText(TypedText.text("+OK Begin TLS Negotiation"), TypedText.newline(Newline.crlf)))
        }

        return
    }

    private func handlePOP3Client() async throws
    {
        try await self.speak(structuredText: StructuredText(TypedText.text("+OK POP3 server ready."), TypedText.newline(Newline.crlf)))
        try await Timeout(Duration.seconds(5)).wait
        {
            let _ = try await self.listen(structuredText: StructuredText(TypedText.text("STLS"), TypedText.newline(Newline.crlf)))
        }

        try await self.speak(structuredText: StructuredText(TypedText.text("+OK Begin TLS Negotiation"), TypedText.newline(Newline.crlf)))
    }

}

public enum OmnitoneError: Error
{
    case timeout
    case connectionClosed
    case writeFailed
    case readFailed
    case listenFailed
    case speakFailed
    case maxSizeReached
}
