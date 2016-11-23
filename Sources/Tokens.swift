//
//  Tokens.swift
//  PerfectTurnstileSQLite
//
//  Created by Jonathan Guthrie on 2016-10-17.
//
//

import Foundation
import SwiftRandom
import Turnstile
import MongoKitten


open class AccessTokenStore {

	var token: String = ""
	var userid: String = ""
	var created: Int = 0
	var updated: Int = 0
	var idle: Int = 86400 // 86400 seconds = 1 day

	/*override open func table() -> String {
		return "tokens"
	}

     */
    
	// Need to do this because of the nature of Swift's introspection
	open func to(_ this: Document) {
		token		= this["token"].string
		userid		= this["userid"].string
		created		= this["created"].int
		updated		= this["updated"].int
		idle		= this["idle"].int
	}

    /*
	func rows() -> [AccessTokenStore] {
		var rows = [AccessTokenStore]()
		for i in 0..<self.results.rows.count {
			let row = AccessTokenStore()
			row.to(self.results.rows[i])
			rows.append(row)
		}
		return rows
	}*/
    
	// Create the table if needed
	/*public func setup() {
		do {
			try sqlExec("CREATE TABLE IF NOT EXISTS tokens (token TEXT PRIMARY KEY NOT NULL, userid TEXT, created INTEGER, updated INTEGER, idle INTEGER)")
		} catch {
			print(error)
		}
	}*/


	private func now() -> Int {
		return Int(Date.timeIntervalSinceReferenceDate)
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
            "token": ~self.token,
            "userid": ~self.userid,
            "created": ~self.created,
            "updated": ~self.updated,
            "idle": ~self.idle
        ]
        
        do {
            try mongoConnect!.database["Token"].insert(token)
        } catch {
            throw MongoError.error("Error inserting new Token document: \(error)")
        }
    }
    
    private func save() throws {
        do {
            let token : Document = [
                "token": ~self.token,
                "userid": ~self.userid,
                "created": ~self.created,
                "updated": ~self.updated,
                "idle": ~self.idle
            ]
            try mongoConnect!.database["Token"].update(matching: "token" == self.token, to: token)
        } catch {
            throw MongoError.error("Could not update token document")
        }
        
    }
}
