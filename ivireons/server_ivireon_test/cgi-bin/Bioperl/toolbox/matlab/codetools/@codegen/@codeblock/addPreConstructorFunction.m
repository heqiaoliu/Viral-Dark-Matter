function addPreConstructorFunction(hThis,hFunc)

% Copyright 2003-2006 The MathWorks, Inc.

hFuncList = get(hThis,'PreConstructorFunctions');
hFuncList = [hFuncList,hFunc];
set(hThis,'PreConstructorFunctions',hFuncList);
