//
//  ViewController.swift
//  TTCompositeOperation
//
//  Created by alysenko on 01/03/16.
//  Copyright © 2016 alysenko. All rights reserved.
//

import UIKit

class MyCompositeOperation : TTCompositeOperation {
    override func main() {
        let op1 = NSBlockOperation { () -> Void in
            sleep(2)
            print("op1 finished")
        }
        
        let op2 = NSBlockOperation { () -> Void in
            sleep(2)
            print("op2 finished")
        }
        
        let op3 = NSBlockOperation { () -> Void in
            sleep(2)
            print("op3 finished")
        }
        
        op1.addDependency(op2)
        op1.addDependency(op3)
        
        addSuboperation(op1)
        addSuboperation(op2)
        addSuboperation(op3)
        
        super.main()
        
        // or just call
        //startSuboperations()
        // against 'super.main()'
    }
}

class ViewController: UIViewController {

    let operationQueue: NSOperationQueue = NSOperationQueue()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let op1 = NSBlockOperation { () -> Void in
            sleep(2)
            print("op1 finished")
        }
        
        let op2 = NSBlockOperation { () -> Void in
            sleep(2)
            print("op2 finished")
        }
        
        let op3 = NSBlockOperation { () -> Void in
            sleep(2)
            print("op3 finished")
        }
        
        // these dependencies mean that op1 will be performed after op2 and op3
        op1.addDependency(op2)
        op1.addDependency(op3)
        
        let compositeOperation = TTCompositeOperation()
        compositeOperation.addSuboperation(op1)
        compositeOperation.addSuboperation(op2)
        compositeOperation.addSuboperation(op3)
        
        // or
        //let compositeOperation = TTCompositeOperation(suboperations: [op1, op2, op3])
        
        operationQueue.addOperation(compositeOperation)
        
        //let myCompositeOperation = MyCompositeOperation()
        //operationQueue.addOperation(myCompositeOperation)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

