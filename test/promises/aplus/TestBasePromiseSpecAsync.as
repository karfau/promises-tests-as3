package promises.aplus {
import flash.utils.setTimeout;

import org.flexunit.AssertionError;
import org.flexunit.assertThat;
import org.hamcrest.core.allOf;
import org.hamcrest.core.isA;
import org.hamcrest.object.hasPropertyWithValue;
import org.hamcrest.object.notNullValue;
import org.hamcrest.text.containsString;

//noinspection JSUnusedGlobalSymbols
public class TestBasePromiseSpecAsync {

    private var test:TestImpl;

    private var callableExecutions:uint = 0;
    private function callable():void {
        callableExecutions++;
    }

    [Before]
    public function setup():void {
        callableExecutions = 0;
        test = new TestImpl();
        test.executedTest = this;
        test.setUpAsync();
    }


    [After]
    public function teardown():void {
        test.tearDownAsync();
        test = null;
    }

    [Test]
    public function afterTick_without_async_fails():void {
        var thrown:Error;
        try {
            test.callAfterTicks(0, callable);
        } catch (error:Error) {
            thrown = error;
        }
        assertThat(thrown, allOf(
                notNullValue(), isA(AssertionError),
                hasPropertyWithValue('message', containsString('not marked async'))
        ));
    }

    [Test(async,timeout="150")]
    public function afterTick_is_not_calling_directly():void {
        test.callAfterTicks(0, callable);
        assertThat(callableExecutions, 0);
    }

    [Test(async,timeout="200")]
    public function afterTick_is_called_later():void {
        test.callAfterTicks(0, callable);
        setTimeout(function asserttion():void {
            assertThat(callableExecutions,1);
        },150);
    }

    [Test(async,expects="Error",description="some flexunit internal error gets thrown")]
    public function expectAsync_done_is_not_called_fails_with_timeout():void {
        test.expectAsync();
    }

    [Test(async)]
    public function expectAsync_call_done_directly():void {
        test.expectAsync();
        test.callDoneHandler();
    }

    [Test(async,timeout="200")]
    public function expectAsync_call_done_later():void {
        test.expectAsync();
        setTimeout(test.callDoneHandler,150);
    }
}
}

import promises.aplus.BasePromiseSpec;

class TestImpl extends BasePromiseSpec {

    public function set executedTest(value:Object):void{
        executedTestInstance = value;
    }

    public function callDoneHandler():void {
        done();
    }
    
    public function callAfterTicks(ticks:uint, callable:Function):void {
        afterTick(callable, ticks);
    }
}