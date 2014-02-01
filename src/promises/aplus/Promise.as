package promises.aplus {

/**
 * Wrapper for implementations so the tests doesn't have to be changed.
 */
public class Promise {
    
    private var impl:*;
    public function get implementingInstance():*{
        return impl;
    }

    public function Promise(impl:*) {
        if(!Boolean(impl)) throw new ArgumentError("expected implementation but was null");
        this.impl = impl;
    }

    public function then(onFulfilled:*,onRejected:*):*{
        return impl.then(onFulfilled,onRejected);
    }
}
}
