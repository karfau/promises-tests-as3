package promises.aplus {
import flash.errors.IllegalOperationError;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

import org.flexunit.*;
import org.flexunit.asserts.*;
import org.flexunit.async.Async;
import org.flexunit.async.util.AsyncTestPartial;
import org.flexunit.async.util.EnsureAsyncRule;
import org.hamcrest.core.*;
import org.hamcrest.object.*;

public class BasePromiseSpec {
    private var specUnderTest:SpecAdapter;

    protected function deferred():Deferred {
        return specUnderTest.deferred();
    }

    protected function resolved(value:*=undefined):Promise {
        return specUnderTest.resolved(value);
    }

    protected function rejected(reason:*=undefined):Promise {
        return specUnderTest.rejected(reason);
    }

    public function alreadyFulfilled(value:*, test:Function, done:Function):void {
        specUnderTest.alreadyFulfilled(value, test, done);
    }

    public function immediatelyFulfilled(value:*, test:Function, done:Function):void {
        specUnderTest.immediatelyFulfilled(value, test, done);
    }

    public function eventuallyFulfilled(value:*, test:Function, done:Function):void {
        specUnderTest.eventuallyFulfilled(value, test, done);
    }

    public function alreadyRejected(reason:*, test:Function, done:Function):void {
        specUnderTest.alreadyRejected(reason, test, done);
    }

    public function immediatelyRejected(reason:*, test:Function, done:Function):void {
        specUnderTest.immediatelyRejected(reason, test, done);
    }

    public function eventuallyRejected(reason:*, test:Function, done:Function):void {
        specUnderTest.eventuallyRejected(reason, test, done);
    }
    
    [Rule]
    public var async:EnsureAsyncRule = new EnsureAsyncRule();

    protected var dummy:Object = {dummy: "dummy"};// we fulfill or reject with this when we don't intend to test against it
    
    public function expectAsync():Function {
        if(async.scope.asyncCompleteHandle == null) {
            async.scope.asyncCompleteHandle = createAsyncHandler();
        }
        return async.scope.done;
    }


    [Before]
    public final function setUpAdapter():void {

        specUnderTest = SpecAdapter.createInstance();
        assertNotNull("adapter implementation", specUnderTest);

        var d:Deferred = deferred();
        assertThat("spec creates instances that are different each time",
                d.implementingInstance, allOf(isNotNull(), not(equalTo(deferred().implementingInstance))));
    }

    [After]
    public final function tearDownAdapter():void {
        specUnderTest = null;
    }

    //noinspection JSMethodCanBeStatic
    protected function get asyncTimeout():Number {
        return 300;
    }

    //noinspection JSMethodCanBeStatic
    public function get tick():Number {
        return 5;
    }

    private var asyncHandlers:Vector.<AsyncTestPartial>;

    [Before]
    public function setUpAsync():void {
        asyncHandlers = new Vector.<AsyncTestPartial>();
    }

    [After]
    public function tearDownAsync():void {

        var incompleteAsyncHandlers:Array = [];
        for each (var partial:AsyncTestPartial in asyncHandlers) {
            if (partial.isExecuting) {
                incompleteAsyncHandlers.push(partial.toString());
                partial.cancel();
            }
        }

        asyncHandlers = null;
//        _done = null;

        //throws AssertionError so do cleanup before
        if (incompleteAsyncHandlers.length > 0) {
            var milliseconds:Number = new Date().getTime();
            fail(incompleteAsyncHandlers.length + " asyncHandlers are still executing @ " + milliseconds + ":\n" + incompleteAsyncHandlers.join(",\n"));
        }
    }

    protected var executedTestInstance:Object;

    private function createAsyncHandler():Function {
        var async:AsyncTestPartial = new AsyncTestPartial(
                Async.asyncHandler(
                        executedTestInstance || this,
                        function (...___):void {
                        },
                        asyncTimeout
                )
        );
        asyncHandlers[asyncHandlers.length] = async;
        return async.done;
    }

    protected function afterTick(execute:Function, ticks:int = 1):void {

        if (async.scope == null) {
            throw new IllegalOperationError("afterTick was called but no asyncHandler was created. Read the docs about how to use expectAsync() and afterTick().")
        }

        //noinspection UnnecessaryLocalVariableJS
        var partial:AsyncTestPartial = new AsyncTestPartial(execute);
        asyncHandlers[asyncHandlers.length] = partial;

        var timeoutId:uint;
        var ticked:int = 0;

        function loop():void {
            clearTimeout(timeoutId);
            ticked++;
            if (ticked > ticks) {
                partial.done();
            } else {
                timeoutId = setTimeout(loop, tick);
            }
        }

        timeoutId = setTimeout(loop, tick);
    }


}
}
