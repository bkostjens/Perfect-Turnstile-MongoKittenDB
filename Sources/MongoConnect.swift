//
//  Mongo.swift
//  PerfectTurnstileMongoDB
//
//  Created by Barry Kostjens on 22-11-16.
//
//

import Foundation
import MongoKitten

var mongoConnect : MongoConnect?

final class MongoConnect {

    let server      : Server
    let database    : Database
    
    private init(hostname : String = "", databaseName : String = "") {
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

