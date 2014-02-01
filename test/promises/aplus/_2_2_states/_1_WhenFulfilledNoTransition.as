package promises.aplus._2_2_states {
import org.flexunit.asserts.fail;

import promises.aplus.BasePromiseSpec;

public class _1_WhenFulfilledNoTransition extends BasePromiseSpec{

    [Test]
    public function firstFailing():void{
        fail("Hello "+deferred());
    }
}
}
