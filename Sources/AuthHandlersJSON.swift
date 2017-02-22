//
//  AuthHandlersJSON.swift
//  PerfectTurnstileSQLite
//
//  Created by Jonathan Guthrie on 2016-10-11.
//
//


import PerfectLib
import PerfectHTTP
import PerfectMustache
import Foundation

import TurnstilePerfect
import Turnstile
import TurnstileCrypto
import TurnstileWeb


public var tokenStore: AccessTokenStore?

public class AuthHandlersJSON {
    
    
    /* =================================================================================================================
     Login
     ================================================================================================================= */
    
    open static func loginHandlerPOST(request: HTTPRequest, _ response: HTTPResponse) {
        response.setHeader(.contentType, value: "application/json")
        print ("params: ",try! request.postBodyString!.jsonDecode())
        
        guard let postBodyString = request.postBodyString else {
            Log.error(message: "Error fetching the post body parameters")
            response.appendBody(string: try! "Error fetching the post body parameters".jsonEncodedString())
            response.completed()
            return
        }
        
        var resp = [String: String]()
        var decodedParams : [String: String]?
        
        do {
            decodedParams = try postBodyString.jsonDecode() as? [String: String]
        } catch {
            
        }
        
        guard let params = decodedParams,
            let username = params["username"],
            let password = params["password"] else {
                resp["error"] = "Missing username or password"
                do {
                    try response.setBody(json: resp)
                } catch {
                    print(error)
                }
                response.completed()
                return
        }
        let credentials = UsernamePassword(username: username, password: password)
        
        do {
            try request.user.login(credentials: credentials)
            
            let token = tokenStore?.new((request.user.authDetails?.account.uniqueID)!)
            resp["login"] = "ok"
            resp["token"] = token
            resp["userID"] = request.user.authDetails?.account.uniqueID
        } catch {
            resp["error"] = "Invalid username or password"
        }
        do {
            try response.setBody(json: resp)
        } catch {
            print(error)
        }
        response.completed()
    }
    /* =================================================================================================================
     /Login
     ================================================================================================================= */
    
    
    
    /* =================================================================================================================
     Register
     ================================================================================================================= */
    //	open static func registerHandlerGET(request: HTTPRequest, _ response: HTTPResponse) {
    //		response.render(template: "register")
    //	}
    open static func registerHandlerPOST(request: HTTPRequest, _ response: HTTPResponse) {
        response.setHeader(.contentType, value: "application/json")
        var resp = [String: String]()
        
        guard let postBodyString = request.postBodyString else {
            Log.error(message: "Error fetching the post body parameters")
            response.appendBody(string: try! "Error fetching the post body parameters".jsonEncodedString())
            response.completed()
            return
        }
        
        var decodedParams : [String: String]?
        
        do {
            decodedParams = try postBodyString.jsonDecode() as? [String: String]
        } catch {
            
        }
        
        guard let params = decodedParams,
            let username = params["username"],
            let password = params["password"] else {
                resp["error"] = "Missing username or password"
                do {
                    try response.setBody(json: resp)
                } catch {
                    print(error)
                }
                response.completed()
                return
        }
        
        let credentials = UsernamePassword(username: username, password: password)
        
        do {
            try request.user.register(credentials: credentials)
            
            try request.user.login(credentials: credentials)
            //register
            resp["error"] = "none"
            resp["login"] = "ok"
            resp["token"] = response.request.user.authDetails?.sessionID
        } catch let e as TurnstileError {
            resp["error"] = e.description
        } catch {
            resp["error"] = "An unknown error occurred."
        }
        do {
            try response.setBody(json: resp)
        } catch {
            print(error)
        }
        response.completed()
    }
    /* =================================================================================================================
     /Register
     ================================================================================================================= */
    
    
    
    
    /* =================================================================================================================
     Logout
     ================================================================================================================= */
    open static func logoutHandler(request: HTTPRequest, _ response: HTTPResponse) {
        response.setHeader(.contentType, value: "application/json")
        var resp = [String: String]()
        
        request.user.logout()
        resp["error"] = "none"
        resp["logout"] = "complete"
        
        do {
            try response.setBody(json: resp)
        } catch {
            print(error)
        }
        response.completed()
    }
    /* =================================================================================================================
     /Logout
     ================================================================================================================= */
    
    
    
    /* =================================================================================================================
     Facebook Signin
     ================================================================================================================= */
    //	open static func facebookHandler(request: HTTPRequest, _ response: HTTPResponse) {
    //		response.setHeader(.contentType, value: "application/json")
    //		var resp = [String: String]()
    //
    //		let state = URandom().secureToken
    //		let redirectURL = facebook.getLoginLink(redirectURL: "http://localhost:8181/login/facebook/consumer", state: state)
    //
    //		response.addCookie(HTTPCookie(name: "OAuthState", value: state, domain: nil, expires: HTTPCookie.Expiration.relativeSeconds(3600), path: "/", secure: nil, httpOnly: true))
    //		response.redirect(path: redirectURL.absoluteString)
    //	}
    //	open static func facebookHandlerConsumer(request: HTTPRequest, _ response: HTTPResponse) {
    //		response.setHeader(.contentType, value: "application/json")
    //		var resp = [String: String]()
    //
    //		guard let state = request.cookies.filter({$0.0 == "OAuthState"}).first?.1 else {
    //			resp["error"] = "unknown error"
    //			do {
    //				try response.setBody(json: resp)
    //			} catch {
    //				print(error)
    //			}
    //			response.completed()
    //			return
    //		}
    //		response.addCookie(HTTPCookie(name: "OAuthState", value: state, domain: nil, expires: HTTPCookie.Expiration.absoluteSeconds(0), path: "/", secure: nil, httpOnly: true))
    //		let uri = "http://localhost:8181" + request.uri
    //
    //		do {
    //			let credentials = try facebook.authenticate(authorizationCodeCallbackURL: uri, state: state) as! FacebookAccount
    //			try request.user.login(credentials: credentials, persist: true)
    //			response.redirect(path: "/")
    //		} catch let error {
    //			let description = (error as? TurnstileError)?.description ?? "Unknown Error"
    //			resp["error"] = description
    //			do {
    //				try response.setBody(json: resp)
    //			} catch {
    //				print(error)
    //			}
    //			response.completed()
    //		}
    //	}
    /* =================================================================================================================
     /Facebook Signin
     ================================================================================================================= */
    
    
    
    /* =================================================================================================================
     Google Signin
     ================================================================================================================= */
    //	open static func googleHandler(request: HTTPRequest, _ response: HTTPResponse) {
    //		response.setHeader(.contentType, value: "application/json")
    //		var resp = [String: String]()
    //
    //		let state = URandom().secureToken
    //		let redirectURL = google.getLoginLink(redirectURL: "http://localhost:8181/login/google/consumer", state: state)
    //
    //		response.addCookie(HTTPCookie(name: "OAuthState", value: state, domain: nil, expires: nil, path: "/", secure: nil, httpOnly: true))
    //		response.redirect(path: redirectURL.absoluteString)
    //	}
    //	open static func googleHandlerConsumer(request: HTTPRequest, _ response: HTTPResponse) {
    //		response.setHeader(.contentType, value: "application/json")
    //		var resp = [String: String]()
    //
    //		guard let state = request.cookies.filter({$0.0 == "OAuthState"}).first?.1 else {
    //			response.render(template: "login", context: ["flash": "Unknown Error"])
    //			return
    //		}
    //		response.addCookie(HTTPCookie(name: "OAuthState", value: state, domain: nil, expires: HTTPCookie.Expiration.absoluteSeconds(0), path: "/", secure: nil, httpOnly: true))
    //		let uri = "http://localhost:8181" + request.uri
    //
    //		do {
    //			let credentials = try google.authenticate(authorizationCodeCallbackURL: uri, state: state) as! GoogleAccount
    //			try request.user.login(credentials: credentials, persist: true)
    //			response.redirect(path: "/")
    //		} catch let error {
    //			let description = (error as? TurnstileError)?.description ?? "Unknown Error"
    //			resp["error"] = description
    //			do {
    //				try response.setBody(json: resp)
    //			} catch {
    //				print(error)
    //			}
    //			response.completed()
    //		}
    //	}
    /* =================================================================================================================
     /Google Signin
     ================================================================================================================= */
    
    
    
    
    open static func testHandler(request: HTTPRequest, _ response: HTTPResponse) {
        response.setHeader(.contentType, value: "application/json")
        
        var resp = [String: String]()
        
        resp["authenticated"] = "AUTHED: \(request.user.authenticated)"
        resp["authDetails"] = "DETAILS: \(request.user.authDetails)"
        
        
        do {
            try response.setBody(json: resp)
        } catch {
            print(error)
        }
        response.completed()
    }
    
}

