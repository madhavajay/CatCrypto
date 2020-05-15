//
//  ArgonTests.swift
//  CatCrypto-iOSTests
//
//  Created by Kcat on 2017/12/30.
//  Copyright © 2017年 imkcat. All rights reserved.
//

import XCTest
@testable import CatCrypto

class ArgonTests: XCTestCase {

    var argon2Crypto: CatArgon2Crypto!

    override func setUp() {
        super.setUp()
        argon2Crypto = CatArgon2Crypto()
    }

    func testNormalHashingRaw() {
        argon2Crypto.context.hashResultType = .hashRaw
        let password = "Hi CatCrypto!"
        let result = argon2Crypto.hash(password: password)
        XCTAssertNotNil(result.raw)
        XCTAssertEqual(
            result.hexStringValue(),
            "7c10d417627fbfaf5728e77dc320d0a7597955bf7b71a22b188bc9ec74762a4f"
        )
        print(result.hexStringValue())
    }

    func testNormalHashingEncoded() {
        argon2Crypto.context.hashResultType = .hashEncoded
        let password = "Hi CatCrypto!"
        let result = argon2Crypto.hash(password: password)
        XCTAssertNotNil(result.raw)
        XCTAssertEqual(
            result.stringValue(),
            "$argon2i$v=19$m=4096,t=3,p=1$c29tZXNhbHQ$fBDUF2J/v69XKOd9wyDQp1l5Vb97caIrGIvJ7HR2Kk8"
        )
        print(result.stringValue())
    }

    func testHashingRawBytes() {
        let crypto = CatArgon2Crypto()
        crypto.context.hashResultType = .hashRaw
        crypto.context.mode = .argon2id
        crypto.context.iterations = 1
        crypto.context.parallelism = 1
        crypto.context.memory = 1024
        crypto.context.hashLength = 8
        let saltHex = "0e0e6fd368aac433f4b59ce218233385"
        let saltBytes = saltHex.decode(encodeMode: .hex)
        crypto.context.saltBytes = saltBytes

        let passwordHex = "15b59b443d8c662473e1534189e46f17"
        let passwordBytes = passwordHex.decode(encodeMode: .hex)
        let result = crypto.hash(passwordBytes: passwordBytes)

        XCTAssertNotNil(result.raw)
        XCTAssertEqual(result.hexStringValue(), "2b77a93c0470b400")
        print(result.hexStringValue())
    }

    func testEmptyHashing() {
        let password = ""
        XCTAssertNotNil(argon2Crypto.hash(password: password).raw)
    }

    func testNormalVerification() {
        let hash = "$argon2i$v=19$m=4096,t=3,p=1$c29tZXNhbHQ$fBDUF2J/v69XKOd9wyDQp1l5Vb97caIrGIvJ7HR2Kk8"
        let password = "Hi CatCrypto!"
        let wrongPassword = "CatCrypto"
        XCTAssertTrue(argon2Crypto.verify(hash: hash, password: password).boolValue())
        XCTAssertFalse(argon2Crypto.verify(hash: hash, password: wrongPassword).boolValue())
    }

    func testIterations() {
        let password = "Hi CatCrypto!"
        argon2Crypto.context.iterations = 0
        XCTAssertNotNil(argon2Crypto.hash(password: password).raw)
        argon2Crypto.context.iterations = 2 << 33
        XCTAssertNotNil(argon2Crypto.hash(password: password).raw)
    }

    func testMemery() {
        let password = "Hi CatCrypto!"
        argon2Crypto.context.memory = 0
        XCTAssertNotNil(argon2Crypto.hash(password: password).raw)
        argon2Crypto.context.memory = 2 << 33
        XCTAssertNotNil(argon2Crypto.hash(password: password).raw)
    }

    func testParallelism() {
        let password = "Hi CatCrypto!"
        argon2Crypto.context.parallelism = 0
        XCTAssertNotNil(argon2Crypto.hash(password: password).raw)
        argon2Crypto.context.parallelism = 2 << 32
        XCTAssertNotNil(argon2Crypto.hash(password: password).raw)
    }

    func testMode() {
        let argon2dHash = "$argon2d$v=19$m=4096,t=3,p=1$MzA0RkU2NkUtMDQ3Mi00NkU0LTkwQzMtQUU0NzYyOURDMjVB$olTMaUSUINprvqhNoOPCR9ScpnAb4tlGYRYs2r8Zk2E"
        let argon2iHash = "$argon2i$v=19$m=4096,t=3,p=1$MzA0RkU2NkUtMDQ3Mi00NkU0LTkwQzMtQUU0NzYyOURDMjVB$xTosSgQwcRnXH2F8JtH/55gS2bM9aOFlc3LGZyzp0lk"
        let argon2idHash = "$argon2id$v=19$m=4096,t=3,p=1$MzA0RkU2NkUtMDQ3Mi00NkU0LTkwQzMtQUU0NzYyOURDMjVB$ZcJqwaBXemTn3+Uxenc0fda9ISSArJANUJhpzKiO" +
        "xdY"
        let password = "Hi CatCrypto!"
        argon2Crypto.context.salt = UUID().uuidString
        argon2Crypto.context.mode = .argon2d
        XCTAssertNotNil(argon2Crypto.hash(password: password).raw)
        XCTAssertTrue(argon2Crypto.verify(hash: argon2dHash, password: password).boolValue())
        argon2Crypto.context.mode = .argon2i
        XCTAssertNotNil(argon2Crypto.hash(password: password).raw)
        XCTAssertTrue(argon2Crypto.verify(hash: argon2iHash, password: password).boolValue())
        argon2Crypto.context.mode = .argon2id
        XCTAssertNotNil(argon2Crypto.hash(password: password).raw)
        XCTAssertTrue(argon2Crypto.verify(hash: argon2idHash, password: password).boolValue())
    }

    func testSalt() {
        let password = "Hi CatCrypto!"
        argon2Crypto.context.salt = ""
        XCTAssertNil(argon2Crypto.hash(password: password).raw)
        argon2Crypto.context.salt = UUID().uuidString
        XCTAssertNotNil(argon2Crypto.hash(password: password).raw)
    }

    func testHashLength() {
        let password = "Hi CatCrypto!"
        argon2Crypto.context.hashLength = 0
        XCTAssertNotNil(argon2Crypto.hash(password: password).raw)
        argon2Crypto.context.hashLength = -1
        argon2Crypto.context.hashLength = Int(CUnsignedInt.max) + 1
        XCTAssertNotNil(argon2Crypto.hash(password: password).raw)
    }

}
