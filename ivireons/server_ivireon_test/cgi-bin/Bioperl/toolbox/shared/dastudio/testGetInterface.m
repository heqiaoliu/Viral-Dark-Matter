function schemas = testGetInterface( whichMenu, callbackInfo )

% Copyright 2009 The MathWorks, Inc.
    persistent testInterface;
    
    if isempty( testInterface )
        testInterface = DATest.TestAppInterface;
    end
    
    schemas = testInterface.getSchemas( whichMenu, callbackInfo );
end
