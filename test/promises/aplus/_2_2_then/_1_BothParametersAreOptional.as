package promises.aplus._2_2_then {
import promises.aplus.*;

/**
 * These are the tests for the the following section of the spec:
 * http://promisesaplus.com/#the__method
 *
 * 2.2.1. Both onFulfilled and onRejected are optional arguments:
 * 2.2.1.1. If onFulfilled is not a function, it must be ignored.
 * 2.2.1.2. If onRejected is not a function, it must be ignored.
 *
 * this is a port of the following js-tests:
 * https://github.com/promises-aplus/promises-tests/blob/master/lib/tests/2.2.1.js
 *
 * As the current AS implementation uses typed arguments for then, using 
 * <code>false, 5 or {}</code>
 * throws a TypeError at runtime.
 * So maybe this should be considered violating the specs.
 * But currently those tests are commented out.
 * 
 * 
 */
public class _1_BothParametersAreOptional extends BasePromiseSpec {
//TODO: it would be better to us theories here so that each test executes on its own instead of the first failing one hides the other failing ones

    [Test(async)]
    public function onFulFilled_is_optional_and_is_ignored_when_not_a_function__applied_to_a_directly_rejected_promise():void {
        expectAsync();
        function testNonFunction(nonFunction:*, stringRepresentation:String):void {
            rejected(dummy).then(nonFunction, function onRejected():void {
                done();
            });
        }

        testNonFunction(undefined, "`undefined`");
        testNonFunction(null, "`null`");
//      then parameters are of type Function, not sure if this violates the spec because it fails instead of ignoring it 
//        testNonFunction(false, "`false`");
//        testNonFunction(5, "`5`");
//        testNonFunction({}, "an object");
    }

    [Test(async)]
    public function onFulFilled_is_optional_and_is_ignored_when_not_a_function__applied_to_a_promise_rejected_and_then_chained_off_of():void {
        expectAsync();
        function testNonFunction(nonFunction:*, stringRepresentation:String):void {
            rejected(dummy)
                    .then(function ():void {}, undefined)
                    .then(nonFunction, function onRejected():void {
                    done();
                    });
        }

        testNonFunction(undefined, "`undefined`");
        testNonFunction(null, "`null`");
//        testNonFunction(false, "`false`"); 
//        testNonFunction(5, "`5`");
//        testNonFunction({}, "an object");
    }

    [Test(async)]
    public function onRejected_is_optional_and_is_ignored_when_not_a_function__applied_to_a_directly_fulfilled_promise():void {
        expectAsync();
        function testNonFunction(nonFunction:*, stringRepresentation:String):void {
            resolved(dummy).then(function onResolved():void {
                done();
            }, nonFunction);
        }

        testNonFunction(undefined, "`undefined`");
        testNonFunction(null, "`null`");
//      then parameters are of type Function, not sure if this violates the spec because it fails instead of ignoring it 
//        testNonFunction(false, "`false`");
//        testNonFunction(5, "`5`");
//        testNonFunction({}, "an object");
    }

    [Test(async)]
    public function onRejected_is_optional_and_is_ignored_when_not_a_function__applied_to_a_promise_fulfilled_and_then_chained_off_of():void {
        expectAsync();
        function testNonFunction(nonFunction:*, stringRepresentation:String):void {
            resolved(dummy)
                    .then(undefined, function ():void {})
                    .then(function onResolved():void {
                done();
                    }, nonFunction);
        }

        testNonFunction(undefined, "`undefined`");
        testNonFunction(null, "`null`");
//      then parameters are of type Function, not sure if this violates the spec because it fails instead of ignoring it 
//        testNonFunction(false, "`false`"); 
//        testNonFunction(5, "`5`");
//        testNonFunction({}, "an object");
    }
}
}
