//
//  Mongo.swift
//  PerfectTurnstileMongoDB
//
//  Created by Barry Kostjens on 22-11-16.
//
//

import Foundation
import MongoKitten

final class Mongo {
    static let shared = Mongo()
    
    let server      : Server
    let database    : Database
    
    let hostname        = "localhost"
    let databaseName    = "ProProject"
    
    private init() {
        do {
            server = try Server(mongoURL: "mongodb://\(hostname)", automatically: true)
            database = server[databaseName]
            
        } catch {
            // Unable to connect
            fatalError("MongoDB is not available on the given host and port")
        }
    }

}

