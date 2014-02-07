package org.flexunit.async.util {
import flash.errors.IllegalOperationError;

import org.flexunit.internals.runners.model.MultipleFailureException;
import org.flexunit.runners.model.FrameworkMethod;
import org.flexunit.token.ChildResult;

public class AsyncTestScope {
    private var method:FrameworkMethod;
    private var test:Object;
    

    public function AsyncTestScope(method:FrameworkMethod, test:Object) {
        this.method = method;
        this.test = test;
    }
    
    public var asyncCompleteHandle:Function;
    
    public function done():void{
        if(result){
            addResultError(new IllegalOperationError("async callback used after test finished running"));
            result.token.sendResult(result.error);
        }else{
            asyncCompleteHandle();
        }
    }

    private var result:ChildResult;
    
    private function addResultError(error:Error):void {
        if (result.error) {
            var multi:MultipleFailureException = result.error as MultipleFailureException;
            if (multi) {
                multi.addFailure(error);
            } else {
                multi = new MultipleFailureException([result.error, error]);
            }
            result.error = multi;
        } else {
            result.error = error;
        }
    }
    
    internal function verifyComplete(result:ChildResult):void {
        this.result = result;
        if(asyncCompleteHandle == null){
            var noDone:Error = new Error("expected async behaviour but no asyncCompleteHandle was set.");
            addResultError(noDone);
        }
    }

}
}
