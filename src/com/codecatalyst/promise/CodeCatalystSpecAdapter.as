package com.codecatalyst.promise {
import promises.aplus.SpecAdapter;

public class CodeCatalystSpecAdapter extends SpecAdapter {

    override protected function createDeferred():* {
        return new Deferred();
    }
}
}
