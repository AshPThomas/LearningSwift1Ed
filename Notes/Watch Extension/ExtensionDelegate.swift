//
//  ExtensionDelegate.swift
//  Watch Extension
//
//  Created by Jon Manning on 3/11/2015.
//  Copyright © 2015 Jonathon Manning. All rights reserved.
//

import WatchKit
import WatchConnectivity

class SessionManager : NSObject, WCSessionDelegate {
    
    struct NoteInfo {
        var name : String
        var URL : NSURL?
        
        init(dictionary:[String:AnyObject]) {
            
            let name = dictionary[WatchMessageContentNameKey] as? String ?? "(no name)"
            self.name = name
            
            if let URLString = dictionary[WatchMessageContentURLKey] as? String {
                self.URL = NSURL(string: URLString)
            }
            
        }
    }
    
    static let sharedSession = SessionManager()
    
    var session : WCSession { return WCSession.defaultSession() }
    
    var notes : [NoteInfo] = []
    
    override init() {
        super.init()
        session.delegate = self
        session.activateSession()
        
    }
    
    func createNote(text:String, completionHandler: ([NoteInfo], NSError?)->Void) {
        let message = [
            WatchMessageTypeKey : WatchMessageTypeCreateNoteKey,
            WatchMessageContentTextKey : text
        ]
        
        session.sendMessage(message, replyHandler: {
            reply in
            
            self.updateNoteListWithReply(reply)
            
            completionHandler(self.notes, nil)
            
        }, errorHandler: {
            error in
            
            completionHandler([], error)
        })
    }
    
    func updateNoteListWithReply(reply:[String:AnyObject]) {
        
        if let noteList = reply[WatchMessageContentListKey] as? [[String:AnyObject]] {
            
            
            // Convert all dictionaries to notes
            self.notes = noteList.map({ (dict) -> NoteInfo in
                return NoteInfo(dictionary: dict)
            })
            
        }
        print("Loaded \(self.notes.count) notes")
    }
    
    func updateList(completionHandler: ([NoteInfo], NSError?)->Void) {
        
        let message = [
            WatchMessageTypeKey : WatchMessageTypeListAllNotesKey
        ]
        
        session.sendMessage(message, replyHandler: {
            reply in
            
            self.updateNoteListWithReply(reply)
            
            completionHandler(self.notes, nil)
            
        }, errorHandler: { error in
            print("Error!")
            completionHandler([], error)
                
        })
    }
    
    func loadNote(noteURL: NSURL, completionHandler: (String?, NSError?) -> Void) {
        
        let message = [
            WatchMessageTypeKey: WatchMessageTypeLoadNoteKey,
            WatchMessageContentURLKey: noteURL.absoluteString
        ]

        session.sendMessage(message, replyHandler: {
            reply in
            
            let text = reply[WatchMessageContentTextKey] as? String
            
            completionHandler(text, nil)
        },
        errorHandler: { error in
            completionHandler(nil, error)
        })
    }
    
    
}

class ExtensionDelegate: NSObject, WKExtensionDelegate {

    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        
        
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

}
