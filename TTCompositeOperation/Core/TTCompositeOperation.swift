//
//  BFCompositeOperation.swift
//  bloomfire
//
//  Created by alysenko on 27/08/15.
//  Copyright (c) 2015 Bloomfire Inc. All rights reserved.
//

import Foundation

//operation which consist of several suboperations
//see: http://stackoverflow.com/questions/13762406/nsoperation-forcing-an-operation-to-wait-others-dynamically

//update 21.09.2015: this approach is bad because it generates a lot of bloking threads (call of 'NSOperationQueue.waitUntilAllOperationsAreFinished()' does it)
// so it's better to make BFCompositeOperation and all its childs concurrent (but it still use own NSOperationsQueue for suboperations execution)
//see: https://developer.apple.com/library/ios/documentation/General/Conceptual/ConcurrencyProgrammingGuide/OperationObjects/OperationObjects.html#//apple_ref/doc/uid/TP40008091-CH101-SW8
//and swift adaptation: http://stackoverflow.com/questions/24109701/nsoperation-property-overrides-isexecuting-isfinished

@objc class TTCompositeOperation : TTConcurrentOperation {
    private var suboperationsQueue: NSOperationQueue!
    private var suboperations: NSMutableArray!
    
    private var completionOperation: NSBlockOperation!
    
    override init() {
        super.init()
        
        suboperationsQueue = NSOperationQueue()
        suboperationsQueue.maxConcurrentOperationCount = 2
        suboperations = NSMutableArray()
        
        completionOperation = NSBlockOperation(block: {[weak self] () -> Void in
            if let s = self {
                s.onComplete(s.cancelled)
            }
        })
    }
    
    init(suboperations: NSArray) {
        super.init()
        
        suboperationsQueue = NSOperationQueue()
        suboperationsQueue.maxConcurrentOperationCount = 2
        self.suboperations = NSMutableArray(array: suboperations)
        
        completionOperation = NSBlockOperation(block: {[weak self] () -> Void in
            if let s = self {
                s.onComplete(s.cancelled)
            }
        })
        
        for operation in self.suboperations {
            completionOperation.addDependency(operation as! NSOperation)
        }
    }
    
    func addSuboperation(operation: NSOperation) {
        suboperations.addObject(operation)
        completionOperation.addDependency(operation)
    }
    
    override func cancel() {
        suboperationsQueue.cancelAllOperations()
        super.cancel()
    }
    
    override func main() {
        startSuboperations()
    }
    
    func startSuboperations() {
        for operation in suboperations {
            let op = operation as! NSOperation
            suboperationsQueue.addOperation(op)
        }
        
        suboperationsQueue.addOperation(completionOperation)
        suboperations.removeAllObjects()
    }
}