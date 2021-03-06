//
//  Account.swift
//  PerfectTurnstileMongoDB
//
//  Created by Jonathan Guthrie on 2016-10-17.
//  Ported to MongoDB by Barry Kostjens on 2016-11-24.
//

import Turnstile
import TurnstileCrypto
import MongoKitten

open class AuthAccount : Account {
    
    var server: MongoConnect
    
	public var uniqueID: String = ""

	public var username: String = ""
	public var password: String = ""

	public var facebookID: String = ""
	public var googleID: String = ""

	public var firstname: String = ""
	public var lastname: String = ""
	public var email: String = ""

	public var internal_token: AccessTokenStore
    
	public func id(_ newid: String) {
		uniqueID = newid
	}

    public init(server:MongoConnect) {
        self.server = server
        self.internal_token = AccessTokenStore(server: server)
    }
    
	// Need to do this because of the nature of Swift's introspection
	open func to(_ this: Document) {
		uniqueID	= this["_id"] as String? ?? ""
		username	= this["username"] as String? ?? ""
		password	= this["password"] as String? ?? ""
		facebookID	= this["facebookID"] as String? ?? ""
		googleID	= this["googleID"] as String? ?? ""
		firstname	= this["firstname"] as String? ?? ""
		lastname	= this["lastname"] as String? ?? ""
		email		= this["email"] as String? ?? ""
	}
    
    func make() throws {
        do {
            password = BCrypt.hash(password: password)
            try create() // can't use save as the id is populated
        } catch {
            print(error)
        }
    }
    
	func get(_ un: String, _ pw: String) throws -> AuthAccount {
      
        do {
            let userCollection = server.database["User"]
            let q: Query = "username" == un
            if let user = try userCollection.findOne(matching: q) {
                print ("User found! - \(user["firstname"] as String? ?? "")")
                to(user)
            } else {
                throw MongoConnectError.noRecordFound
            }
        } catch {
            print (error)
            throw MongoConnectError.noRecordFound
        }

		if try BCrypt.verify(password: pw, matchesHash: password) {
			return self
		} else {
            throw MongoConnectError.noRecordFound
		}
	}
    
    // Try to get user by identifier
    public func get(identifier: String) throws {
        do {
            let id = try ObjectId(identifier)
            if let user = try server.database["User"].findOne(matching: "_id" == id) {
                to(user)
            }
        } catch {
            throw error
        }
    }

    // Check if a user exists
	func exists(_ un: String) -> Bool {
		do {
            let userCollection = server.database["User"]
            let q: Query = "username" == un

            if let _ = try userCollection.findOne(matching: q) {
				return true
			} else {
				return false
			}
		} catch {
			print("Exists error: \(error)")
			return false
		}
	}
    
    // Create a user document
    private func create() throws {
        let user : Document = [
            "username": self.username,
            "password": self.password
        ]
        
        do {
            try server.database["User"].insert(user)
        } catch {
            throw MongoConnectError.error("Error inserting new User document: \(error)")
        }
    }

}


