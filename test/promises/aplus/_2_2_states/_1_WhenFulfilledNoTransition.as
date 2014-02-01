package promises.aplus._2_2_states {

import org.flexunit.asserts.*;

import promises.aplus.BasePromiseSpec;
import promises.aplus.Promise;

/**
 * These are the tests for the the following section of the spec:
 * http://promisesaplus.com/#promise_states
 *
 * 2.1.2. When fulfilled, a promise:
 * 2.1.2.1. must not transition to any other state.
 * 2.1.2.2. must have a value, which must not change.
 *
 * this is a port of the following js-tests:
 * https://github.com/promises-aplus/promises-tests/blob/master/lib/tests/2.1.2.js
 *
 * @see #promiseHandler() for implementation details
 *
 */
public class _1_WhenFulfilledNoTransition extends BasePromiseSpec{

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
        var onFulfilledCalled:Boolean;
        promise.then(function onFulfilled():void {
            onFulfilledCalled = true;
        }, function onRejected():void {

            //fail when onRejected gets called after onFulfilled
            assertFalse("shouldn't have been rejected", onFulfilledCalled);

            //mark test complete for cases where only onRejected gets called
            done();
        });
    }

    [Test(async)]
    public function already_fulfilled():void {
        alreadyFulfilled(dummy, promiseHandler, done);
        afterTick(done,2*tick);
    }

}
}
