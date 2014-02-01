package promises.aplus {
import com.codecatalyst.promise.CodeCatalystSpecAdapter;

import org.flexunit.*;
import org.flexunit.asserts.*;
import org.hamcrest.core.*;
import org.hamcrest.object.*;

public class BasePromiseSpec {
    private static var specUnderTest:SpecAdapter;

    protected static function deferred():Deferred {
        return specUnderTest.deferred();
    }

    protected static function resolved(value:*):Promise {
        return specUnderTest.resolved(value);
    }
    protected static function rejected(reason:*):Promise {
        return specUnderTest.rejected(reason);
    }

    public static function alreadyFulfilled(value:*, test:Function, done:Function):void {
        specUnderTest.alreadyFulfilled(value, test, done);
    }

    public static function immediatelyFulfilled(value:*, test:Function, done:Function):void {
        specUnderTest.immediatelyFulfilled(value, test, done);
    }

    public static function eventuallyFulfilled(value:*, test:Function, done:Function):void {
        specUnderTest.eventuallyFulfilled(value, test, done);
    }

    public static function alreadyRejected(reason:*, test:Function, done:Function):void {
        specUnderTest.alreadyRejected(reason, test, done);
    }

    public static function immediatelyRejected(reason:*, test:Function, done:Function):void {
        specUnderTest.immediatelyRejected(reason, test, done);
    }

    public static function eventuallyRejected(reason:*, test:Function, done:Function):void {
        specUnderTest.eventuallyRejected(reason, test, done);
    }


    [Before]
    public final function setUpAdapter():void{
        //TODO is there a more flexible way to test another implementation then to change the next line?
        specUnderTest = new CodeCatalystSpecAdapter();
        assertNotNull("adapter implementation",specUnderTest);
        
        var d:Deferred = deferred();
        assertThat("spec creates instances that are different each time",
        d.implementingInstance, allOf(isNotNull(),not(equalTo(deferred().implementingInstance))))
    }

    [Before]
    public final function tearDownAdapter():void{
        specUnderTest = null;
    }
    
}
}
