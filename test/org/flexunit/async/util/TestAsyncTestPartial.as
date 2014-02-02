package org.flexunit.async.util {
import org.flexunit.assertThat;
import org.flexunit.asserts.assertFalse;
import org.flexunit.asserts.assertTrue;

public class TestAsyncTestPartial {
    private var partial:AsyncTestPartial;
    
    private var completeCallbackCalled:uint = 0;
    private function completeCallback():void{
        completeCallbackCalled++;
    }

    [Before]
    public function setup():void {
        partial = new AsyncTestPartial(completeCallback);
    }

    [After]
    public function clear():void {
        partial = null;
        completeCallbackCalled = 0;
    }

    [Test]
    public function isNotCompleteInitially():void {
        assertTrue(partial.isExecuting);
    }
    
    [Test]
    public function done_executes_completeCallback():void {
        partial.done();
        assertThat(completeCallbackCalled,1);
        assertFalse(partial.isExecuting);
    }
    
    [Test]
    public function done_executes_completeCallback_notRecursively():void {
        partial = new AsyncTestPartial(function recursiveBeast():void {
            assertFalse(partial.isExecuting);
            partial.done();
        });
        partial.done();
        assertFalse(partial.isExecuting);
    }
    
    [Test]
    public function done_doesnt_fail_when_callback_null():void {
        partial = new AsyncTestPartial(null);
        partial.done();
        assertFalse(partial.isExecuting);
    }
    
    [Test]
    public function done_executes_completeCallback_only_once():void {
        partial.done();
        partial.done();
        assertThat(completeCallbackCalled,1);
        assertFalse(partial.isExecuting);
    }
    
    [Test]
    public function cancel_doesnt_execute_completeCallback():void {
        partial.cancel();
        assertThat(completeCallbackCalled,0);
        assertFalse(partial.isExecuting);
    }
    [Test]
    public function cancel_then_done_doesnt_execute_completeCallback():void {
        partial.cancel();
        partial.done();
        assertThat(completeCallbackCalled,0);
        assertFalse(partial.isExecuting);
    }
    
}
}
