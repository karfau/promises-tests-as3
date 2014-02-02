package org.flexunit.async.util {
public class AsyncTestPartial {

    private var _executing:Boolean = true;
    public function get isExecuting():Boolean {
        return _executing;
    }

    private var callAfterExecutionDone:Function;

    private var _start:uint;
    public function get start():uint {
        return _start;
    }

    private var _duration:int = -1;
    public function get duration():int {
        return _duration;
    }

    private var _origin:String;
    public function get origin():String {
        return _origin;
    }

    public function AsyncTestPartial(callAfterExecutionDone:Function = null) {
        this.callAfterExecutionDone = callAfterExecutionDone;
        _start = new Date().getTime();
        _origin = new Error('creation stacktrace:').getStackTrace();
    }

    public function done():void {
        if(!_executing){
            return;
        }
        _duration = new Date().getTime() - _start;
        var calling:Function = callAfterExecutionDone;
        callAfterExecutionDone = null;
        _executing = false;
        if (calling != null) {
            calling();
        }
    }

    public function cancel():void {
        callAfterExecutionDone = null;
        _executing = false;
    }

    public function toString():String {
        var msg:String = "AsyncTestPartial {";
        if (!_executing) {
            return "complete (duration " + _duration + "ms)}";
        } else {
            return "incomplete (started " + _start + "): " + _origin + "}";
        }
    }
}
}
