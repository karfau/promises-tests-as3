package promises.aplus._2_2_then {
import org.hamcrest.Matcher;
import org.hamcrest.collection.array;

import promises.aplus.*;

import flash.utils.setTimeout;

import org.flexunit.assertThat;

import org.flexunit.asserts.assertFalse;
import org.flexunit.asserts.assertTrue;
import org.hamcrest.object.strictlyEqualTo;

/**
 * These are the tests for the the following section of the spec:
 * http://promisesaplus.com/#the__method
 * 
 * 2.2.2. If onFulfilled is a function:
 * 2.2.2.1. it must be called after promise is fulfilled, with promise’s value as its first argument.
 * 2.2.2.2. it must not be called before promise is fulfilled.
 * 2.2.2.3. it must not be called more than once.
 *
 * this is a port of the following js-tests:
 * https://github.com/promises-aplus/promises-tests/blob/master/lib/tests/2.2.2.js
 *
 */
public class _2_When_onFulfilled_is_a_function extends BasePromiseSpec {

    private var sentinel:Object = { sentinel: "sentinel" };
    
    /**
     * there are two cases in which this can end the (async) execution of the test:
     * a) when the reject handler gets called after the resolved handler the test fails
     * b) when the reject handler gets called first it executes the done parameter
     *
     * all testcases use afterTick() for a second delay in which execution of the rejected handler after the resolved handler could happen,
     * before completing the execution of the test.
     *
     * @see com.codecatalyst.promise.spec.BasePromiseSpec.afterTick()
     */
    protected function promiseHandler(promise:Promise, done:Function):void {
        promise.then(function onFulfilled(value:*):void {
            assertThat(value,strictlyEqualTo(sentinel));
            done();
        });
    }

    [Test(async)]
    public function must_be_called_after_promise_is_fulfilled__with_promise_s_fulfillment_value_as_first_argument__alreadyFulfilled():void {
        alreadyFulfilled(sentinel, promiseHandler, done);
    }

    [Test(async)]
    public function must_be_called_after_promise_is_fulfilled__with_promise_s_fulfillment_value_as_first_argument__immediatelyFulfilled():void {
        immediatelyFulfilled(sentinel, promiseHandler, done);
    }

    [Test(async)]
    public function must_be_called_after_promise_is_fulfilled__with_promise_s_fulfillment_value_as_first_argument__eventuallyFulfilled():void {
        eventuallyFulfilled(sentinel, promiseHandler, done);
    }


    [Test(async)]
    public function it_must_not_be_called_before_promise_is_fulfilled__fulfilled_after_a_delay():void {
        expectAsync();
        var d:Deferred = deferred();
        var isFulfilled:Boolean = false;

        d.promise.then(function onFulfilled():void {
            assertTrue(isFulfilled, true);
            done();
        });

        setTimeout(function ():void {
            d.resolve(dummy);
            isFulfilled = true;
        }, 50);
    }

    [Test(async)]
    public function it_must_not_be_called_before_promise_is_fulfilled__never_fulfilled():void {
        expectAsync();
        var d:Deferred = deferred();
        var onFulfilledCalled:Boolean = false;

        d.promise.then(function onFulfilled():void {
            onFulfilledCalled = true;
            done();
        });

        afterTick(function ():void {
            assertFalse(onFulfilledCalled);
            done();
        }, 3);
    }

    [Test(async)]
    public function it_must_not_be_called_more_then_once__already_fulfilled():void {
        expectAsync();
        var timesCalled:int = 0;

        resolved(dummy).then(function onFulfilled():void {
            timesCalled++;
            assertThat(timesCalled, 1);
            done();
        });
    }

    [Test(async)]
    public function it_must_not_be_called_more_then_once__trying_to_fulfill_a_pending_promise_more_than_once__immediately():void {
        expectAsync();
        var d:Deferred = deferred();
        var timesCalled:int = 0;
        
        d.promise.then(function onFulfilled():void {
            timesCalled++;
            assertThat(timesCalled, 1);
            done();
        });

        d.resolve(dummy);
        d.resolve(dummy);
    }

    [Test(async)]
    public function it_must_not_be_called_more_then_once__trying_to_fulfill_a_pending_promise_more_than_once__delayed():void {
        expectAsync();
        var d:Deferred = deferred();
        var timesCalled:int = 0;
        
        d.promise.then(function onFulfilled():void {
            timesCalled++;
            assertThat(timesCalled, 1);
            done();
        });

        setTimeout(function ():void {
            d.resolve(dummy);
            d.resolve(dummy);
        }, 50);
    }

    [Test(async)]
    public function it_must_not_be_called_more_then_once__trying_to_fulfill_a_pending_promise_more_than_once__immediately_then_delayed():void {
        expectAsync();
        var d:Deferred = deferred();
        var timesCalled:int = 0;
        
        d.promise.then(function onFulfilled():void {
            timesCalled++;
            assertThat(timesCalled, 1);
            done();
        });

        d.resolve(dummy);
        setTimeout(function ():void {
            d.resolve(dummy);
        }, 50);
    }

    [Test(async)]
    public function it_must_not_be_called_more_then_once__when_multiple_then_calls_are_made__spaced_apart_in_time():void {
        expectAsync();
        var d:Deferred = deferred();
        var timesCalled:Array = [0,0,0];

        var matcher:Matcher = array(1,1,1);
        function complete():void {
            if(matcher.matches(timesCalled)){
                done();
            }
        } 
        
        d.promise.then(function onFulfilled():void {
            timesCalled[0]++;
            assertThat(timesCalled[0], 1);
            complete();
        });
        setTimeout(function ():void {
            d.promise.then(function onFulfilled():void {
                timesCalled[1]++;
                assertThat(timesCalled[1], 1);
                complete();
            });
        }, 50);
        setTimeout(function ():void {
            d.promise.then(function onFulfilled():void {
                timesCalled[2]++;
                assertThat(timesCalled[2], 1);
                complete();
            });
        }, 100);

        setTimeout(function ():void {
            d.resolve(dummy);
        }, 150);
    }
    [Test(async)]
    public function it_must_not_be_called_more_then_once__when_then_is_interleaved_with_fulfillment():void {
        expectAsync();
        var d:Deferred = deferred();
        var timesCalled:Array = [0,0];

        var matcher:Matcher = array(1,1);
        function complete():void {
            if(matcher.matches(timesCalled)){
                done();
            }
        } 
        
        d.promise.then(function onFulfilled():void {
            timesCalled[0]++;
            assertThat(timesCalled[0], 1);
            complete();
        });
        
        d.resolve(dummy);
        
        d.promise.then(function onFulfilled():void {
            timesCalled[1]++;
            assertThat(timesCalled[1], 1);
            complete();
        });

    }


}
}
