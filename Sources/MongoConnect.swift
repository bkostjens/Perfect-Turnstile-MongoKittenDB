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
    let server          : Server
    let database        : Database
    
    public init(hostname: String, databaseName: String) {
       
        do {
            server = try Server(mongoURL: "mongodb://\(hostname)", automatically: true)
            database = server[databaseName]
            
        } catch {
            // Unable to connect
            fatalError("MongoDB is not available on the given host and port")
        }
    }
}

