package promises.aplus._2_1_states {

import flash.utils.setTimeout;

import org.flexunit.asserts.assertFalse;

import promises.aplus.*;

/**
 * These are the tests for the the following section of the spec:
 * http://promisesaplus.com/#promise_states
 *
 * 2.1.3. When rejected, a promise:
 * 2.1.3.1. must not transition to any other state.
 * 2.1.3.2. must have a reason, which must not change.
 *
 * this is a port of the following js-tests:
 * https://github.com/promises-aplus/promises-tests/blob/master/lib/tests/2.1.2.js
 * 
 * @see #promiseHandler() for implementation details 
 * 
 */

public class _2_WhenRejectedNoTransition extends BasePromiseSpec {

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
        var onRejectedCalled:Boolean;
        promise.then(function onFulFilled():void {
            //fail when onRejected gets called after onRejected
            assertFalse("shouldn't have been rejected", onRejectedCalled);
            
            //mark test complete for cases where only onRejected gets called
            done();
        }, function onRejected():void {
            onRejectedCalled = true;
        });
    }

    [Test(async)]
    public function already_rejected():void {
        var done:Function = expectAsync();

        alreadyRejected(dummy, promiseHandler, done);
        afterTick(done,2);
    }

    [Test(async)]
    public function immediately_fejected():void {
        var done:Function = expectAsync();

        immediatelyRejected(dummy, promiseHandler, done);
        afterTick(done,2);
    }

    [Test(async)]
    public function eventually_fejected():void {
        var done:Function = expectAsync();

        eventuallyRejected(dummy, promiseHandler, done);
        afterTick(done,2);
    }

    [Test(async)]
    public function trying_to_reject_then_immediately_fulfill():void {
        var done:Function = expectAsync();

        var d:Deferred = deferred();
        promiseHandler(d.promise, done);
        d.reject(dummy);
        d.resolve(dummy);
        afterTick(done,2);
    }

    [Test(async)]
    public function trying_to_reject_then_fulfill_delayed():void {
        var done:Function = expectAsync();

        var d:Deferred = deferred();
        promiseHandler(d.promise, done);
        
        setTimeout(function ():void {
            d.reject(dummy);
            d.resolve(dummy);
        }, 50);
        
        afterTick(done,3);
    }

    [Test(async)]
    public function trying_to_reject_immediately_then_fulfill_delayed():void {
        var done:Function = expectAsync();

        var d:Deferred = deferred();
        promiseHandler(d.promise,done);
        d.reject(dummy);
        setTimeout(function ():void {
            d.resolve(dummy);
        }, 50);

        afterTick(done,3);
    }
}
}
