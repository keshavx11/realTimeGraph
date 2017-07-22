//
//  SocketIOManager.swift
//  realTimeGraph
//
//  Created by Keshav Bansal on 21/07/17.
//  Copyright © 2017 Keshav. All rights reserved.
//

import UIKit

class SocketIOManager: NSObject {
    static let sharedInstance = SocketIOManager()
    
    var socket: SocketIOClient =  SocketIOClient(socketURL: NSURL(string: "http://ios-test.us-east-1.elasticbeanstalk.com")! as URL)
    
    override init() {
        super.init()
        socket.joinNamespace("/random")
    }
    
    func establishConnection() {
        socket.connect()
    }
    
    func closeConnection() {
        socket.disconnect()
    }
    
    func connectToServer(completion: @escaping (Int, Bool) -> Swift.Void){
        socket.on("capture") {(data, socketAck) -> Void in
            completion(data[0] as! Int, true)
        }
    }
}
