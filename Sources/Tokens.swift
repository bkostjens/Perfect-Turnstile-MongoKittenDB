//
//  Tokens.swift
//  PerfectTurnstileSQLite
//
//  Created by Jonathan Guthrie on 2016-10-17.
//  Ported to MongoDB by Barry Kostjens on 2016-11-24.
//

import Foundation
import SwiftRandom
import Turnstile
import MongoKitten


open class AccessTokenStore {

    var server: MongoConnect
    
	var token: String = ""
	var userid: String = ""
	var created: Double = 0
	var updated: Double = 0
	var idle: Double = 7776000 // 86400 seconds = 1 day, 7776000 = 90 days
    
    public init(server:MongoConnect) {
        self.server = server
    }
    
	// Need to do this because of the nature of Swift's introspection
	open func to(_ this: Document) {
        token		= this["token"] as String? ?? ""
        userid		= this["userid"] as String? ?? ""
        created		= this["created"] as Double? ?? now()
        updated		= this["updated"] as Double? ?? now()
        idle		= this["idle"] as Double? ?? 0
	}

	// Create the Token collection if needed
    // Commented out as this is not needed: MongoDB auto creates collections when needed
	/*public func setup() {
		do {
			try server.database.createCollection("Token")
		} catch {
			print(error)
		}
	}*/

	private func now() -> Double {
		return Double(Date().timeIntervalSince1970)
	}

	// checks to see if the token is active
	// upticks the updated int to keep it alive.
	public func check() -> Bool? {
		if (updated + idle) < now() { return false } else {
			do {
				updated = now()
				try save()
			} catch {
				print(error)
			}
			return true
		}
	}

	public func new(_ u: String) -> String {
		let rand = URandom()
		token = rand.secureToken
        
        // Dirty hack to prevent the '-' char to be in the token string
        while token.range(of: "-") != nil {
            let rand = URandom()
            token = rand.secureToken
        }
        
		userid = u
		created = now()
		updated = now()
		do {
			try create()
		} catch {
			print(error)
		}
		return token
	}
    
    private func create() throws {
        let token : Document = [
            "token": self.token,
            "userid": self.userid,
            "created": self.created,
            "updated": self.updated,
            "idle": self.idle
        ]
        
        do {
            try server.database["Token"].insert(token)
        } catch {
            throw MongoConnectError.error("Error inserting new Token document: \(error)")
        }
    }
    
    private func save() throws {
        do {
            let token : Document = [
                "token": self.token,
                "userid": self.userid,
                "created": self.created,
                "updated": self.updated,
                "idle": self.idle
            ]
            try server.database["Token"].update(matching: "token" == self.token, to: token)
        } catch {
            throw MongoConnectError.error("Could not update token document")
        }
    }
    
    // Try to get token by identifier
    public func get(identifier: String) throws {
        do {
            if let token = try server.database["Token"].findOne(matching: "token" == identifier) {
                to(token)
            }
        } catch {
            throw error
        }
    }
    
    // Try to delete the token
    public func delete() throws {
        print ("Delete token: ",token)
        do {
            try server.database["Token"].remove(matching: "token" == token)
        } catch {
            throw error
        }
    }
}
