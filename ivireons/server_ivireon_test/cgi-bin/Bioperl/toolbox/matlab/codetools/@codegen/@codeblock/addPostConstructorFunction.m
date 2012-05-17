function addPostConstructorFunction(hThis,hFunc)

% Copyright 2003-2006 The MathWorks, Inc.

hFuncList = get(hThis,'PostConstructorFunctions');
hFuncList = [hFuncList,hFunc];
set(hThis,'PostConstructorFunctions',hFuncList);
