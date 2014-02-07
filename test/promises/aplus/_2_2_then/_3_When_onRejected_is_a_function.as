package promises.aplus._2_2_then {
import flash.utils.setTimeout;

import org.flexunit.assertThat;
import org.flexunit.asserts.assertFalse;
import org.flexunit.asserts.assertTrue;
import org.hamcrest.object.strictlyEqualTo;

import promises.aplus.*;

/**
 * These are the tests for the the following section of the spec:
 * http://promisesaplus.com/#the__method
 * 
 * 2.2.2. If onRejected is a function:
 * 2.2.2.1. it must be called after promise is rejected, with promise’s reason as its first argument.
 * 2.2.2.2. it must not be called before promise is rejected.
 * 2.2.2.3. it must not be called more than once.
 *
 * this is a port of the following js-tests:
 * https://github.com/promises-aplus/promises-tests/blob/master/lib/tests/2.2.3.js
 *
 */
public class _3_When_onRejected_is_a_function extends BasePromiseSpec {

    private var sentinel:Object = { sentinel: "sentinel" };

    /**
     * there are two cases in which this can end the (async) execution of the test:
     * a) when the reject handler gets called with a value different from sentinel the test fails
     * b) when the reject handler gets called with value being sentinel it executes the done parameter
     *
     * all test use the timeout to fail after a certain delay when the handler is not called.
     */
    protected function promiseHandler(promise:Promise, done:Function):void {
        promise.then(null, function onRejected(reason:*):void {
            assertThat(reason,strictlyEqualTo(sentinel));
            done();
        });
    }

    [Test(async)]
    public function must_be_called_after_promise_is_rejected__with_promise_s_rejection_reason_as_first_argument__alreadyRejected():void {
        var done:Function = expectAsync();

        alreadyRejected(sentinel, promiseHandler, done);
    }

    [Test(async)]
    public function must_be_called_after_promise_is_rejected__with_promise_s_rejection_reason_as_first_argument__immediatelyRejected():void {
        var done:Function = expectAsync();

        immediatelyRejected(sentinel, promiseHandler, done);
    }

    [Test(async)]
    public function must_be_called_after_promise_is_rejected__with_promise_s_rejection_reason_as_first_argument__eventuallyRejected():void {
        var done:Function = expectAsync();

        eventuallyRejected(sentinel, promiseHandler, done);
    }


    [Test(async)]
    public function it_must_not_be_called_before_promise_is_rejected__rejected_after_a_delay():void {
        var done:Function = expectAsync();

        var d:Deferred = deferred();
        var isRejected:Boolean = false;

        d.promise.then(null, function onRejected():void {
            assertTrue(isRejected, true);
            done();
        });

        setTimeout(function ():void {
            d.reject(dummy);
            isRejected = true;
        }, 50);
    }

    [Test(async)]
    public function it_must_not_be_called_before_promise_is_rejected__never_rejected():void {
        var done:Function = expectAsync();

        var d:Deferred = deferred();
        var onRejectedCalled:Boolean = false;

        d.promise.then(null, function onRejected():void {
            onRejectedCalled = true;
            done();
        });

        afterTick(function ():void {
            assertFalse(onRejectedCalled);
            done();
        }, 3);
    }

    [Test(async)]
    public function it_must_not_be_called_more_then_once__already_rejected():void {
        var done:Function = expectAsync();

        var timesCalled:int = 0;

        rejected(dummy).then(null, function onRejected():void {
            timesCalled++;
            assertThat(timesCalled, 1);
            done();
        });
    }

    [Test(async)]
    public function it_must_not_be_called_more_then_once__trying_to_reject_a_pending_promise_more_than_once__immediately():void {
        var done:Function = expectAsync();

        var d:Deferred = deferred();
        var timesCalled:int = 0;
        
        d.promise.then(null, function onRejected():void {
            timesCalled++;
            assertThat(timesCalled, 1);
            done();
        });

        d.reject(dummy);
        d.reject(dummy);
    }

    [Test(async)]
    public function it_must_not_be_called_more_then_once__trying_to_reject_a_pending_promise_more_than_once__delayed():void {
        var done:Function = expectAsync();

        var d:Deferred = deferred();
        var timesCalled:int = 0;
        
        d.promise.then(null, function onRejected():void {
            timesCalled++;
            assertThat(timesCalled, 1);
            done();
        });

        setTimeout(function ():void {
            d.reject(dummy);
            d.reject(dummy);
        }, 50);
    }

    [Test(async)]
    public function it_must_not_be_called_more_then_once__trying_to_reject_a_pending_promise_more_than_once__immediately_then_delayed():void {
        var done:Function = expectAsync();

        var d:Deferred = deferred();
        var timesCalled:int = 0;
        
        d.promise.then(null, function onRejected():void {
            timesCalled++;
            assertThat(timesCalled, 1);
            done();
        });

        d.reject(dummy);
        setTimeout(function ():void {
            d.reject(dummy);
        }, 50);
    }

    [Test(async)]
    public function it_must_not_be_called_more_then_once__when_multiple_then_calls_are_made__spaced_apart_in_time():void {
        var done:Function = expectAsync();

        var d:Deferred = deferred();
        var timesCalled:Array = [0,0,0];

        d.promise.then(null, function onRejected():void {
            timesCalled[0]++;
            assertThat(timesCalled[0], 1);
        });
        
        afterTick(function ():void {
            d.promise.then(null, function onRejected():void {
                timesCalled[1]++;
                assertThat(timesCalled[1], 1);
            });
        }, 0);
        afterTick(function ():void {
            d.promise.then(null, function onRejected():void {
                timesCalled[2]++;
                assertThat(timesCalled[2], 1);
            });
        }, 1);

        afterTick(function ():void {
            d.reject(dummy);
            setTimeout(done,100);
        }, 2);
        
    }
    [Test(async)]
    public function it_must_not_be_called_more_then_once__when_then_is_interleaved_with_rejection():void {
        var done:Function = expectAsync();

        var d:Deferred = deferred();
        var timesCalled:Array = [0,0];

        d.promise.then(null, function onRejected():void {
            timesCalled[0]++;
            assertThat(timesCalled[0], 1);
        });
        
        d.reject(dummy);
        
        d.promise.then(null, function onRejected():void {
            timesCalled[1]++;
            assertThat(timesCalled[1], 1);
        });

        setTimeout(done,150);

    }


}
}
