package org.flexunit.async.util {
import org.flexunit.internals.runners.statements.IAsyncStatement;
import org.flexunit.internals.runners.statements.MethodRuleBase;
import org.flexunit.rules.IMethodRule;
import org.flexunit.runners.model.FrameworkMethod;
import org.flexunit.token.AsyncTestToken;
import org.flexunit.token.ChildResult;

public class EnsureAsyncRule extends MethodRuleBase implements IMethodRule{


    private var current:AsyncTestScope;

    public function get scope():AsyncTestScope {
        return current;
    }

    override public function evaluate(parentToken:AsyncTestToken):void {
        super.evaluate(parentToken);
        
        //this method needs to be overwritten so the following method gets called:
        proceedToNextStatement();
    }
    
    override public function apply(base:IAsyncStatement, method:FrameworkMethod, test:Object):IAsyncStatement {

        if(method.isAsync){
            current = new AsyncTestScope(method,test);
        }
        
        
        //as last thing call this:
        return super.apply(base, method, test);
    }

    override protected function handleStatementComplete(result:ChildResult):void {
        if(current){
            current.verifyComplete(result);
            current = null;
        }
        
        //as last thing call this:
        super.handleStatementComplete(result);
    }
}
}
