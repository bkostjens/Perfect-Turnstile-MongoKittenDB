//
//  Realm.swift
//  PerfectTurnstileSQLite
//
//  Created by Jonathan Guthrie on 2016-10-17.
//
//

import Turnstile
import TurnstileCrypto

class AuthRealm : Realm {
    
    var server: MongoConnect
    
	private var random: Random = URandom()
    
    public init(server:MongoConnect) {
        self.server = server
    }

	public func authenticate(credentials: Credentials) throws -> Account {


//		print("======= ENTRY =======")

		switch credentials {
		case let credentials as UsernamePassword:
			return try authenticate(credentials: credentials)
		case let credentials as AccessToken:
			return try authenticate(credentials: credentials)
			//		case let credentials as FacebookAccount:
			//			return try authenticate(credentials: credentials)
			//		case let credentials as GoogleAccount:
		//			return try authenticate(credentials: credentials)
		default:
			throw UnsupportedCredentialsError()
		}

	}

	private func authenticate(credentials: AccessToken) throws -> Account {
//		print("======= AUTHENTICATE AccessToken =======")
		let account = AuthAccount(server: server)
		let token = AccessTokenStore(server: server)
//		print(credentials.string)
		do {
			try token.get(identifier: credentials.string)
			if token.check() == false {
				throw IncorrectCredentialsError()
			}
			try account.get(identifier: token.userid)
			return account
		} catch {
			throw IncorrectCredentialsError()
		}
	}


	private func authenticate(credentials: UsernamePassword) throws -> Account {
//		print("======= AUTHENTICATE =======")
        let account = AuthAccount(server: server)
        
		do {
			let thisAccount = try account.get(credentials.username, credentials.password)
			return thisAccount
		} catch {
			throw IncorrectCredentialsError()
		}
	}

	//	private func authenticate(credentials: FacebookAccount) throws -> Account {
	//		if let account = accounts.filter({$0.facebookID == credentials.uniqueID}).first {
	//			return account
	//		} else {
	//			return try register(credentials: credentials)
	//		}
	//	}
	//
	//	private func authenticate(credentials: GoogleAccount) throws -> Account {
	//		if let account = accounts.filter({$0.googleID == credentials.uniqueID}).first {
	//			return account
	//		} else {
	//			return try register(credentials: credentials)
	//		}
	//	}

	/**
	Registers PasswordCredentials against the AuthRealm.
	*/
	public func register(credentials: Credentials) throws -> Account {

//		print("======= REGISTER =======")

        let account = AuthAccount(server:server)
        let newAccount = AuthAccount(server:server)
		newAccount.id(String(random.secureToken))

		switch credentials {
		case let credentials as UsernamePassword:
			do {
				if account.exists(credentials.username) {
					throw AccountTakenError()
				}
				newAccount.username = credentials.username
				newAccount.password = credentials.password
				do {
					try newAccount.make() // can't use save as the id is populated
				} catch {
					print("REGISTER ERROR: \(error)")
				}
			} catch {
				throw AccountTakenError()
			}
			//		case let credentials as FacebookAccount:
			//			guard accounts.filter({$0.facebookID == credentials.uniqueID}).first == nil else {
			//				throw AccountTakenError()
			//			}
			//			newAccount.facebookID = credentials.uniqueID
			//		case let credentials as GoogleAccount:
			//			guard accounts.filter({$0.googleID == credentials.uniqueID}).first == nil else {
			//				throw AccountTakenError()
			//			}
		//			newAccount.googleID = credentials.uniqueID
		default:
			throw UnsupportedCredentialsError()
		}
		return newAccount
	}
}
