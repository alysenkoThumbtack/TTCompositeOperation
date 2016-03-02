# TTConcurrentOperation
<br>TTConcurrentOperation is a child of NSOperation that has custom "start()" method and provides an appotunity 
to create you own operations and say when each operation actually ends (NOT when main() function ends).
<br><br>For example, if you want to perform a series of HTTP requests, you can write something like that:

```swift
class HttpRequestSeriesOperation: TTConcurrentOperation {
    var apiClient: MyRealizationOfRestApiClient?
    
    override func main() {
        apiClient.doSomething(completion: { (error1) -> Void in
            // some handling
            
            if error1 != nil {
                self.apiClient.doSomethingElse(completion: { (error2) -> Void in
                    self.onComplete(self.isCancelled)
                })
            }
        })
    }
}
```
It's very important to call 'onComplete()' - it indicates that operation is finished

# TTCompositeOperation
TTCompositeOperation is based on TTConcurrentOperation and provides an appotunity to join several operations in one.
Each suboperations will be perfomed on NSOperationQueue (TTCompositeOperation contains own operation queue with .maxConcurrentOperationCount = 2).

TTCompositeOperation is NSOperation too, so it can be added to another TTCompositeOperation as suboperation.

You can add dependencies between suboperations (one operation can't be perfomed before another) -- it's a basic feature of NSOperation and NSOperationQueue.
See example to understand how it works:

```swift  
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
    }
}
```

<br>Or just make your own child of TTCompositeOperation:

```swift
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
```
