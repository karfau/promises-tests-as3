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
 * 2.2.4. onFulfilled or onRejected must not be called until the execution context stack contains only platform code.
 *
 * this is a port of the following js-tests:
 * https://github.com/promises-aplus/promises-tests/blob/master/lib/tests/2.2.4.js
 *
 */
public class _4_onFulfilled_or_onRejected_MustNotBeCalledBeforeEmptyStack extends BasePromiseSpec {

    private var sentinel:Object = { sentinel: "sentinel" };
    
    /**
     * there are two cases in which this can end the (async) execution of the test:
     * a) when the onFulfilled gets called "to early" the test fails
     * b) when the resolve handler gets called "at the right time" it executes the done parameter
     *
     * all test use the timeout to fail after a certain delay when the handler is not called.
     */
    private function assertFulfilledAfterReturned(promise:Promise, done:Function):void {
        var thenHasReturned:Boolean = false;

        promise.then(function onFulfilled():void {
            assertTrue(thenHasReturned);
            done();
        });

        thenHasReturned = true;
    }

    [Test(async)]
    public function then_returns_before_the_promise_becomes_fulfilled_or_rejected__alreadyFulfilled():void {
        alreadyFulfilled(sentinel, assertFulfilledAfterReturned, done);
    }

    [Test(async)]
    public function then_returns_before_the_promise_becomes_fulfilled_or_rejected__immediatelyFulfilled():void {
        immediatelyFulfilled(sentinel, assertFulfilledAfterReturned, done);
    }

    [Test(async)]
    public function then_returns_before_the_promise_becomes_fulfilled_or_rejected__eventuallyFulfilled():void {
        eventuallyFulfilled(sentinel, assertFulfilledAfterReturned, done);
    }


    /**
     * there are two cases in which this can end the (async) execution of the test:
     * a) when the onFulfilled gets called "to early" the test fails
     * b) when the resolve handler gets called "at the right time" it executes the done parameter
     *
     * all test use the timeout to fail after a certain delay when the handler is not called.
     */
    private function assertRejectedAfterReturned(promise:Promise, done:Function):void {
        var thenHasReturned:Boolean = false;

        promise.then(null, function onFulfilled():void {
            assertTrue(thenHasReturned);
            done();
        });

        thenHasReturned = true;
    }

    [Test(async)]
    public function must_be_called_after_promise_is_rejected__with_promise_s_rejection_reason_as_first_argument__alreadyRejected():void {
        alreadyRejected(sentinel, assertRejectedAfterReturned, done);
    }

    [Test(async)]
    public function must_be_called_after_promise_is_rejected__with_promise_s_rejection_reason_as_first_argument__immediatelyRejected():void {
        immediatelyRejected(sentinel, assertRejectedAfterReturned, done);
    }

    [Test(async)]
    public function must_be_called_after_promise_is_rejected__with_promise_s_rejection_reason_as_first_argument__eventuallyRejected():void {
        eventuallyRejected(sentinel, assertRejectedAfterReturned, done);
    }


}
}
