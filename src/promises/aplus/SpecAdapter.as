package promises.aplus {

import com.codecatalyst.promise.CodeCatalystSpecAdapter;

import flash.utils.clearTimeout;
import flash.utils.setTimeout;

public class SpecAdapter {

    public static function createInstance():SpecAdapter {
        //TODO is there a more flexible way to test another implementation then to change the next line?
        return new CodeCatalystSpecAdapter();
    }

    protected function createDeferred():* {
    }

    public final function deferred():Deferred {
        return new Deferred(createDeferred());
    }

    public final function rejected(reason:*):Promise {
        var d:Deferred = deferred();
        d.reject(reason);
        return d.promise;
    }

    public final function resolved(value:*):Promise {
        var d:Deferred = deferred();
        d.resolve(value);
        return d.promise;
    }

    public final function alreadyFulfilled(value:*, test:Function, done:Function):void {
        test(resolved(value), done)
    }

    public final function immediatelyFulfilled(value:*, test:Function, done:Function):void {
        var d:Deferred = deferred();
        test(d.promise, done);
        d.resolve(value);
    }

    public final function eventuallyFulfilled(value:*, test:Function, done:Function):void {
        var d:Deferred = deferred();
        test(d.promise, done);
        var handle:uint = setTimeout(function ():void {
            clearTimeout(handle);
            d.resolve(value);
        }, 50);
    }

    public final function alreadyRejected(reason:*, test:Function, done:Function):void {
        test(rejected(reason), done)
    }

    public final function immediatelyRejected(reason:*, test:Function, done:Function):void {
        var d:Deferred = deferred();
        test(d.promise, done);
        d.reject(reason);
    }

    public final function eventuallyRejected(reason:*, test:Function, done:Function):void {
        var d:Deferred = deferred();
        test(d.promise, done);
        var handle:uint = setTimeout(function ():void {
            clearTimeout(handle);
            d.reject(reason);
        }, 50);
    }

}
}
