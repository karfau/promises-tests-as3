package promises.aplus {
import flash.errors.IllegalOperationError;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

import org.flexunit.*;
import org.flexunit.asserts.*;
import org.flexunit.async.Async;
import org.flexunit.async.util.AsyncTestPartial;
import org.hamcrest.core.*;
import org.hamcrest.object.*;

public class BasePromiseSpec {
    private static var specUnderTest:SpecAdapter;

    protected static function deferred():Deferred {
        return specUnderTest.deferred();
    }

    protected static function resolved(value:*):Promise {
        return specUnderTest.resolved(value);
    }

    protected static function rejected(reason:*):Promise {
        return specUnderTest.rejected(reason);
    }

    public static function alreadyFulfilled(value:*, test:Function, done:Function):void {
        specUnderTest.alreadyFulfilled(value, test, done);
    }

    /*
     public static function immediatelyFulfilled(value:*, test:Function, done:Function):void {
     specUnderTest.immediatelyFulfilled(value, test, done);
     }

     public static function eventuallyFulfilled(value:*, test:Function, done:Function):void {
     specUnderTest.eventuallyFulfilled(value, test, done);
     }

     public static function alreadyRejected(reason:*, test:Function, done:Function):void {
     specUnderTest.alreadyRejected(reason, test, done);
     }

     public static function immediatelyRejected(reason:*, test:Function, done:Function):void {
     specUnderTest.immediatelyRejected(reason, test, done);
     }

     public static function eventuallyRejected(reason:*, test:Function, done:Function):void {
     specUnderTest.eventuallyRejected(reason, test, done);
     }
     */

    protected var dummy:Object = {dummy: "dummy"};// we fulfill or reject with this when we don't intend to test against it

    private var _done:Function;
    protected function get done():Function {
        if (_done == null) {
            _done = createAsyncHandler();
        }

        return _done;
    }

    public function expectAsync():void {
        //noinspection JSUnusedLocalSymbols
        var initializedNow:Function = done;
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

    public static function get tick():Number {
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
        _done = null;

        //throws AssertionError so do cleanup before
        if (incompleteAsyncHandlers.length > 0) {
            var milliseconds:Number = new Date().getTime();
            fail(incompleteAsyncHandlers.length + " asyncHandlers are still executing @ " + milliseconds + ":\n\t" + incompleteAsyncHandlers.join(",\n\t"));
        }
    }

    protected var executedTestInstance:Object;

    private function createAsyncHandler():Function {
        var async:AsyncTestPartial = new AsyncTestPartial(
                Async.asyncHandler(
                        executedTestInstance || this,
                        function (...___):void {},
                        asyncTimeout
                )
        );
        asyncHandlers[asyncHandlers.length] = async;
        return async.done;
    }

    protected function afterTick(execute:Function, ticks:int = 1):void {

        if (_done == null) {
            throw new IllegalOperationError("afterTick was called but no asyncHandler was created. Read the docs about how to use expectAsync() and afterTick().")
        }
        
        //noinspection UnnecessaryLocalVariableJS
        var async:AsyncTestPartial = new AsyncTestPartial(execute);
        asyncHandlers[asyncHandlers.length] = async;
        
        var timeoutId:uint;
        var ticked:int = 0;

        function loop():void {
            clearTimeout(timeoutId);
            ticked++;
            if (ticked > ticks) {
                async.done();
            } else {
                timeoutId = setTimeout(loop, tick);
            }
        }

        timeoutId = setTimeout(loop, tick);
    }


}
}
