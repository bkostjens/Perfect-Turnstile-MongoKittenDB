//
//  SessionManager.swift
//  PerfectTurnstileSQLite
//
//  Created by Jonathan Guthrie on 2016-10-19.
//  Ported to MongoDB by Barry Kostjens on 2016-11-24.
//

import Foundation
import TurnstileCrypto
import Turnstile

/**
MongoDBSessionManager manages sessions via SQLite storage
*/

public class PerfectSessionManager: SessionManager {
    
    var server: MongoConnect
    
	/// Dictionary of sessions
	//private var sessions = [String: String]()
	private let random: Random = URandom()

	/// Initializes the Session Manager. No config needed!
    public init(server: MongoConnect) {
        self.server = server
    }

	/// Creates a session for a given Subject object and returns the identifier.
	public func createSession(account: Account) -> String {
		let identifier = tokenStore?.new(account.uniqueID)
		return identifier!
	}

	/// Deletes the session for a session identifier.
	public func destroySession(identifier: String) {
        print ("DestroySession: ",identifier)
        let token = AccessTokenStore(server: server)
		do {
            try token.get(identifier: identifier)
			try token.delete()
		} catch {
			print(error)
		}
	}

	/**
	Creates a Session-backed Account object from the Session store. This only
	contains the SessionID.
	*/
	public func restoreAccount(fromSessionID identifier: String) throws -> Account {
        let token = AccessTokenStore(server: server)
		do {
            try token.get(identifier: identifier)
			guard token.check()! else { throw InvalidSessionError() }
			return SessionAccount(uniqueID: token.userid)
		} catch {
			throw InvalidSessionError()
		}
	}
}
