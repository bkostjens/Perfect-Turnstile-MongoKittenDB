//
//  Mongo.swift
//  PerfectTurnstileMongoDB
//
//  Created by Barry Kostjens on 2016-11-22.
//
//

import Foundation
import MongoKitten

import Foundation
import MongoKitten

public var mongoConnect : MongoConnect?

public final class MongoConnect {
    
    let server      : Server
    let database    : Database
    
    public init(hostname : String = "", databaseName : String = "") {
        do {
            server = try Server(mongoURL: "mongodb://\(hostname)", automatically: true)
            database = server[databaseName]
            mongoConnect = self
        } catch {
            // Unable to connect
            fatalError("MongoDB is not available on the given host and port")
        }
    }
}
