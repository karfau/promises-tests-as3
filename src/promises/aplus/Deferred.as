package promises.aplus {

/**
 * Wrapper for implementations so the tests doesn't have to be changed.
 */
public class Deferred {
    
    private var impl:*;
    public function get implementingInstance():*{
        return impl;
    }

    public function Deferred(impl:*) {
        if(!Boolean(impl)) throw new ArgumentError("expected implementation but was null");
        this.impl = impl;
    }

    public function get promise():Promise{
        return new Promise(impl.promise);
    }
    public function resolve( value:* ):void
    {
        impl.resolve( value );
    }

    /**
     * Reject this Deferred with the specified error.
     *
     * Once a Deferred has been rejected, it is considered to be complete
     * and subsequent calls to resolve() or reject() are ignored.
     *
     * @param reason Rejection reason.
     */
    public function reject( reason:* ):void
    {
        impl.reject( reason );
    }
}
}
