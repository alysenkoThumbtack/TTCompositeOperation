//
//  BFConcurrentOperation.swift
//  bloomfire
//
//  Created by alysenko on 24/09/15.
//  Copyright (c) 2015 Bloomfire Inc. All rights reserved.
//

import Foundation

//see: https://developer.apple.com/library/ios/documentation/General/Conceptual/ConcurrencyProgrammingGuide/OperationObjects/OperationObjects.html#//apple_ref/doc/uid/TP40008091-CH101-SW8
//and swift adaptation: http://stackoverflow.com/questions/24109701/nsoperation-property-overrides-isexecuting-isfinished

//each child should call onComplete() when operation must be finished

@objc class TTConcurrentOperation: NSOperation {
    let isExecutingKey = "isExecuting"
    let isFinishedKey = "isFinished"

    private var _executing: Bool = false
    private var _finished: Bool = false
    
    override var executing: Bool {
        get {
            return _executing
        }
        
        set {
            if _executing != newValue {
                willChangeValueForKey(isExecutingKey)
                _executing = newValue
                didChangeValueForKey(isExecutingKey)
            }
        }
    }
    
    override var finished: Bool {
        get {
            return _finished
        }
        
        set {
            if _finished != newValue {
                willChangeValueForKey(isFinishedKey)
                _finished = newValue
                didChangeValueForKey(isFinishedKey)
            }
        }
    }
    
    override var asynchronous : Bool {
        return true
    }
    
    override func cancel() {
        super.cancel()
        
        onComplete(self.cancelled)
    }
    
    override func start() {
        willStart()
        didStart()
    }
    
    func willStart() {
        if self.cancelled {
            onComplete(self.cancelled)
            return
        }
    }
    
    func didStart() {
        if self.cancelled {
            return
        }
        
        executing = true
        NSThread.detachNewThreadSelector("main", toTarget: self, withObject: nil)
    }
    
    func onComplete(cancelled: Bool = false) {
        willComplete(cancelled)
        didComplete(cancelled)
    }
    
    func willComplete(cancelled: Bool = false) {
        
    }
    
    func didComplete(cancelled: Bool = false) {
        executing = false
        finished = true
    }
}