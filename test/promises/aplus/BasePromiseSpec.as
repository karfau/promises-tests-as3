package promises.aplus {
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

import org.flexunit.*;
import org.flexunit.asserts.*;
import org.flexunit.async.Async;
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
            _done = createAsyncHandler('done');
        }

        return _done;
    }

    public function expectAsync():void {
        //noinspection JSUnusedLocalSymbols
        var initializedNow:Function = done;
    }


    [Before]
    public final function setUpAdapter():void{
        
        specUnderTest = SpecAdapter.createInstance();
        assertNotNull("adapter implementation",specUnderTest);
        
        var d:Deferred = deferred();
        assertThat("spec creates instances that are different each time",
        d.implementingInstance, allOf(isNotNull(),not(equalTo(deferred().implementingInstance))))
    }

    [After]
    public final function tearDownAdapter():void{
        specUnderTest = null;
    }

    //noinspection JSMethodCanBeStatic
    protected function get asyncTimeout():Number {
        return 300;
    }

    //noinspection JSMethodCanBeStatic
    protected function get tick():Number {
        return 5;
    }

    private var asyncHandlers:Array;

    [Before]
    public function setUpAsync():void {
        asyncHandlers = [];
    }

    [After]
    public function tearDownAsync():void {

        var incompleteAsyncs:Array = [];
        var usage:String;
        for each (var object:Object in asyncHandlers) {
            if (!object.completed) {
                if(object.usage is String){
                    usage = object.usage;
                }else{
                    usage = "{ origin: "+object.usage.origin+", ticks: "+object.usage.ticks+", ticked: "+object.usage.ticked+" }"
                }
                incompleteAsyncs.push("{usage: "+object.usage+",start: "+object.start+"}");
            }
        }

        asyncHandlers = null;

        //throws AssertionError so do cleanup before
        if (incompleteAsyncs.length > 0) {
            var milliseconds:Number = new Date().getTime();
            fail(incompleteAsyncs.length + " asyncHandlers were not called back @ " + milliseconds + ":\n\t" + incompleteAsyncs.join(",\n\t"));
        }
    }

    protected var executedTestInstance:Object;
    private function createAsyncHandler(usage:*, handler:Function = null):Function {
        var currentList:Array = asyncHandlers;
        var index:uint = asyncHandlers.length;
        var asyncHandle:Function = Async.asyncHandler(executedTestInstance || this, function (...___):void {
            if (handler != null) {
                handler();
            }
        }, asyncTimeout);
        currentList[index] = {
            usage: usage,
            start: new Date().getTime(),
            handle: asyncHandle,
            completed: false
        };
        function asyncComplete():void {
            currentList[index].completed = true;
            asyncHandle();
        }

        return asyncComplete;
    }

    protected function afterTick(execute:Function, ticks:int = 1):void {
        var usage:Object = { origin: 'afterTick', ticks: ticks, ticked: 0};

        var afterTickDone:Function = createAsyncHandler(usage);
        var timoutId:uint;
        function loop():void {
            usage.ticked++;
            clearTimeout(timoutId);

            if (usage.ticked >= ticks) {
                timoutId = setTimeout(function doneInRightOrder():void {
                    if (Boolean(execute)) {
                        execute()
                    }
                    afterTickDone();
                    clearTimeout(timoutId)
                }, tick);
            } else {
                timoutId = setTimeout(loop, tick);
            }
        }

        timoutId = setTimeout(loop,tick);
    }
    
    


}
}
