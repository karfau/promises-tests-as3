package promises.aplus._2_2_then {
import flash.utils.setTimeout;

import org.flexunit.asserts.assertFalse;
import org.flexunit.asserts.assertTrue;

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
        var done:Function = expectAsync();

        alreadyFulfilled(sentinel, assertFulfilledAfterReturned, done);
    }

    [Test(async)]
    public function then_returns_before_the_promise_becomes_fulfilled_or_rejected__immediatelyFulfilled():void {
        var done:Function = expectAsync();

        immediatelyFulfilled(sentinel, assertFulfilledAfterReturned, done);
    }

    [Test(async)]
    public function then_returns_before_the_promise_becomes_fulfilled_or_rejected__eventuallyFulfilled():void {
        var done:Function = expectAsync();

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
        var done:Function = expectAsync();

        alreadyRejected(sentinel, assertRejectedAfterReturned, done);
    }

    [Test(async)]
    public function must_be_called_after_promise_is_rejected__with_promise_s_rejection_reason_as_first_argument__immediatelyRejected():void {
        var done:Function = expectAsync();

        immediatelyRejected(sentinel, assertRejectedAfterReturned, done);
    }

    [Test(async)]
    public function must_be_called_after_promise_is_rejected__with_promise_s_rejection_reason_as_first_argument__eventuallyRejected():void {
        var done:Function = expectAsync();

        eventuallyRejected(sentinel, assertRejectedAfterReturned, done);
    }

    [Test]
    public function Clean_stack_execution_ordering__fulfillment_case__when_onFulfilled_is_added_immediately_before_the_promise_is_fulfilled():void{
        var d:Deferred = deferred();
        var onFulfilledCalled:Boolean = false;

        d.promise.then(function onFulfilled():void {
            onFulfilledCalled = true;
        });

        d.resolve(dummy);

        assertFalse(onFulfilledCalled);
    }

    [Test]
    public function Clean_stack_execution_ordering__fulfillment_case__when_onFulfilled_is_added_immediately_after_the_promise_is_fulfilled():void{
        var d:Deferred = deferred();
        var onFulfilledCalled:Boolean = false;

        d.resolve(dummy);

        d.promise.then(function onFulfilled():void {
            onFulfilledCalled = true;
        });

        assertFalse(onFulfilledCalled);
    }

    [Test(async)]
    public function Clean_stack_execution_ordering__fulfillment_case__when_onFulfilled_is_added_inside_another_onFulfilled():void{
        var done:Function = expectAsync();

        var promise:Promise = resolved();
        var firstOnFulfilledFinished:Boolean = false;

        promise.then(function ():void {
            promise.then(function ():void {
                assertTrue(firstOnFulfilledFinished);
                done();
            });
            firstOnFulfilledFinished = true;
        });
    }

    [Test(async)]
    public function Clean_stack_execution_ordering__fulfillment_case__when_onFulfilled_is_added_inside_an_onRejected():void{
        var done:Function = expectAsync();

        var promise:Promise = rejected(dummy);
        var promise2:Promise = resolved(dummy);
        var firstOnRejectedFinished:Boolean = false;

        promise.then(null, function ():void {
            promise2.then(function ():void {
                assertTrue(firstOnRejectedFinished);
                done();
            });
            firstOnRejectedFinished = true;
        });
    }

    [Test(async)]
    public function Clean_stack_execution_ordering__fulfillment_case__when_the_promise_is_fulfilled_asynchronously():void{
        var done:Function = expectAsync();

        var d:Deferred = deferred();
        var firstStackFinished:Boolean = false;

        setTimeout(function ():void {
            d.resolve(dummy);
            firstStackFinished = true;
        }, 0);

        d.promise.then(function ():void {
            assertTrue(firstStackFinished);
            done();
            setTimeout(function ():void{
                done();
            },0);
        });
    }
}
}
