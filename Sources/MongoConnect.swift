//
//  Mongo.swift
//  PerfectTurnstileMongoDB
//
//  Created by Barry Kostjens on 2016-11-22.
//
//

import Foundation
import MongoKitten

public final class MongoConnect {
    
    let server      : Server
    let database    : Database
    
    public init(hostname : String = "localhost", databaseName : String = "User") {
        do {
            server = try Server("mongodb://\(hostname)")
            database = server[databaseName]
        } catch {
            // Unable to connect
            fatalError("MongoDB is not available on the given host and port")
        }
    }
}
