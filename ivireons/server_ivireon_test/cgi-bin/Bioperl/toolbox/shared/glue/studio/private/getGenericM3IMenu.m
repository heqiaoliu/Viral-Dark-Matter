% Copyright 2005-2008 The MathWorks, Inc.
function schemas = getGenericM3IMenu( whichMenu, callbackInfo )

    % build our generic menu item class, and call a dispatch menu on it.
    theDispatchObject = GenericM3IMenu();
    
    % dispatch to it!
    schemas = theDispatchObject.dispatchToMethod(whichMenu, callbackInfo);
    
end

