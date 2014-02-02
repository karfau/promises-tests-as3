package promises.aplus {
import flash.errors.IllegalOperationError;
import flash.utils.setTimeout;

import org.flexunit.AssertionError;
import org.flexunit.assertThat;
import org.flexunit.asserts.fail;
import org.hamcrest.core.allOf;
import org.hamcrest.core.isA;
import org.hamcrest.number.lessThan;
import org.hamcrest.object.equalTo;
import org.hamcrest.object.hasPropertyWithValue;
import org.hamcrest.object.notNullValue;
import org.hamcrest.object.strictlyEqualTo;
import org.hamcrest.text.containsString;

//noinspection JSUnusedGlobalSymbols
public class TestBasePromiseSpecAsync {

    private var test:TestImpl;

    private var callableExecutions:uint = 0;
    private var expectedCallableExecutions:Number = NaN;

    private function callable():void {
        callableExecutions++;
    }

    [Before]
    public function setup():void {
        test = new TestImpl();
        test.executedTest = this;
        test.setUpAsync();
    }


    [After]
    public function teardown():void {
        if (!isNaN(expectedCallableExecutions)) {
            assertThat("teardown checked expectedCallableExecutions", callableExecutions, equalTo(expectedCallableExecutions));
        }
        callableExecutions = 0;
        expectedCallableExecutions = NaN;

        test.tearDownAsync();
        test = null;
    }

    //+++++++++++++++++++++++++++++++
    // afterTick
    //+++++++++++++++++++++++++++++++

    [Test]
    public function afterTick_without_async_fails():void {
        var thrown:Error;
        try {
            test.callAfterTicks(0, callable);
        } catch (error:Error) {
            thrown = error;
        }
        assertThat(thrown, allOf(
                notNullValue(), isA(IllegalOperationError),
                hasPropertyWithValue('message', containsString('expectAsync()'))
        ));
    }

    [Test(async, timeout="200")]
    public function afterTick_is_not_calling_directly_but_later():void {
        test.expectAsync();
        test.callAfterTicks(0, function ():void {
            callable();
            test.callDoneHandle();
        });

        assertThat(callableExecutions, 0);

        expectedCallableExecutions = 1;//checked in teardown
    }

    [Test(async, timeout="400")]
    public function afterTick_is_called_after_setTimeout_with_same_amount_of_ticks():void {
        test.expectAsync();
        var ticks:uint = 1;
        
        //callable should be called AFTER (later then) one tick
        test.callAfterTicks(ticks, function ():void {
            callable();
            test.callDoneHandle();
        });

//        so checking AT one tick it should not have been called yet.
        setTimeout(function assertionNotJet():void {
            assertThat(callableExecutions, 0);
        }, ticks * BasePromiseSpec.tick);//this is called

        expectedCallableExecutions = 1;//checked in teardown
    }


    [Test(async, timeout="100",
            expects="Error", description="some FlexUnit internal error wraps error thrown for timeout and from teardownAsync")]
    public function afterTick_with_lots_of_ticks_fails_with_timeout():void {
        var toMuchTicks:uint = 10;

        assertThat("timeout should be smaller then ticks", BasePromiseSpec.tick * toMuchTicks, lessThan(/*timeout in metadata*/100));
        
        /* from local experience: 
         * while BasePromiseSpec.tick is 5 (milliseconds) 
         * the shortest amount of milliseconds the flashplayer seems to reach is about 50 ms.
         * But any time smaller then about 50 will cause things to be executed in the same "tick".
         * This is the reason why the timeout often aligns to 
         * timeout = 50ms * (<ticks required for regular execution> + x)
         */
        test.callAfterTicks(toMuchTicks, function shouldFail():void {
            fail("should not get called after timeout");
        });
    }

    //+++++++++++++++++++++++++++++++
    // expectAsync
    //+++++++++++++++++++++++++++++++

    [Test]
    public function expectAsync_without_async_fails():void {
        var thrown:Error;
        try {
            test.expectAsync();
        } catch (error:Error) {
            thrown = error;
        }
        assertThat(thrown, allOf(
                notNullValue(), isA(AssertionError),
                hasPropertyWithValue('message', containsString('not marked async'))
        ));
    }

    [Test]
    public function getDoneHandle_without_async_fails():void {
        var thrown:Error;
        try {
            test.getDoneHandle();
        } catch (error:Error) {
            thrown = error;
        }
        assertThat(thrown, allOf(
                notNullValue(), isA(AssertionError),
                hasPropertyWithValue('message', containsString('not marked async'))
        ));
    }

    [Test(async)]
    public function getDoneHandle_twice_returns_same_instance():void {
        var done:Function = test.getDoneHandle();
        assertThat(done, strictlyEqualTo(test.getDoneHandle()));

        done();
    }

    [Test(async)]
    public function callDoneHandle_twice_should_work():void {
        test.expectAsync();
        test.callDoneHandle();
        test.callDoneHandle();
    }


    [Test(async, expects="Error", description="some FlexUnit internal error wraps error thrown for timeout and from teardownAsync")]
    public function expectAsync_done_is_not_called_fails_with_timeout():void {
        test.expectAsync();
    }

    [Test(async)]
    public function expectAsync_call_done_directly():void {
        test.expectAsync();
        test.callDoneHandle();
    }

    [Test(async, timeout="250")]
    public function expectAsync_call_done_later():void {
        test.expectAsync();
        setTimeout(test.callDoneHandle, 150);
    }


    //+++++++++++++++++++++++++++++++
    // combined
    //+++++++++++++++++++++++++++++++

    [Test(async, timeout="200")]
    public function expectAsync_then_afterTicks_only_creates_one_asyncHandle():void {
        test.expectAsync();
        test.callAfterTicks(0,function nothing():void {
            test.callDoneHandle();
        });
        
    }

    [Test(async, expects="Error", 
            description="done marks test complete immediatly so afterTick is still executin when teardownAsync checks")]
    public function expectAsync_then_afterTicks_then_done_fails_in_teardown():void {
        test.expectAsync();
        test.callAfterTicks(0,function nothing():void {});
        test.callDoneHandle();
    }

    [Test(async)]
    public function expectAsync_then_afterTicks_uses_done_everything_should_be_complete():void {
        test.expectAsync();
        test.callAfterTicks(0,test.getDoneHandle());
    }
}
}

import promises.aplus.BasePromiseSpec;

class TestImpl extends BasePromiseSpec {

    public function set executedTest(value:Object):void {
        executedTestInstance = value;
    }

    public function callDoneHandle():void {
        done();
    }

    public function getDoneHandle():Function {
        return done;
    }

    public function callAfterTicks(ticks:uint, callable:Function):void {
        afterTick(callable, ticks);
    }

}