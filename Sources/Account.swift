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
    
	public var uniqueID: String = ""

	public var username: String = ""
	public var password: String = ""

	public var facebookID: String = ""
	public var googleID: String = ""

	public var firstname: String = ""
	public var lastname: String = ""
	public var email: String = ""

	public var internal_token: AccessTokenStore = AccessTokenStore()
    
	/*override open func table() -> String {
		return "users"
	}*/

    /*public convenience init(_ database:MongoDatabase) {
        self.database = database
        self.init(database)
    }*/
    
	public func id(_ newid: String) {
		uniqueID = newid
	}

    
	// Need to do this because of the nature of Swift's introspection
	open func to(_ this: Document) {
		uniqueID	= this["_id"].string
		username	= this["username"].string
		password	= this["password"].string // lets not read the password!
		facebookID	= this["facebookID"].string
		googleID	= this["googleID"].string
		firstname	= this["firstname"].string
		lastname	= this["lastname"].string
		email		= this["email"].string
	}
    
	// Create the table if needed
	/*public func setup() {
		do {
			try sqlExec("CREATE TABLE IF NOT EXISTS users (uniqueID TEXT PRIMARY KEY NOT NULL, username TEXT, password TEXT, facebookID TEXT, googleID TEXT, firstname TEXT, lastname TEXT, email TEXT)")
		} catch {
			print(error)
		}
	}*/

	/*func make() throws {
		print("IN MAKE")
		do {
			password = BCrypt.hash(password: password)
			try create() // can't use save as the id is populated
		} catch {
			print(error)
		}
	}*/
    
	func get(_ un: String, _ pw: String) throws -> AuthAccount {
      
        do {
            let userCollection = mongoConnect!.database["User"]
            let q: Query = "username" == un
            if let user = try userCollection.findOne(matching: q) {
                print ("User found! - \(user["firstname"].string)")
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
    
    
	func exists(_ un: String) -> Bool {
		do {
            let userCollection = mongoConnect!.database["User"]
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
    
    /*private func create() throws {
        let user : Document = [
            "token": ~self.token,
            "userid": ~self.userid,
            "created": ~self.created,
            "updated": ~self.updated,
            "idle": ~self.idle
        ]
        
        do {
            try mongo.database["Token"].insert(token)
        } catch {
            throw MongoError.error("Error inserting new Token document: \(error)")
        }
    }*/
}


