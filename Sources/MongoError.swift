//
//  MongoError.swift
//  PerfectTurnstileMongoDB
//
//  Created by Barry Kostjens on 22-11-16.
//
//

public enum MongoError: Error {
    case database			// "No Database Specified"
    case collectionNotFound
    case error(String)		// "Error"
    case noError			// "No Error"
    case notImplemented		// "Not Implemented"
    case noRecordFound		// no record
    
    init(){
        self = .noError
    }
    
    public func string() -> String {
        switch self {
        case .database:
            return "No Database Specified"
            
        case .collectionNotFound:
            return "Collection not found"
            
        case .noRecordFound:
            return "No Record Found"
            
        case .noError:
            return "No Error"
            
        case .notImplemented:
            return "Not Implemented"
            
        default:
            return "Error"
        }
    }
}
