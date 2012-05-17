function [bool] = isequal(hArg1,hArg2)
% Return true if both input args have equivalent value

% Copyright 2006 The MathWorks, Inc.

if ~isa(hArg2,'codegen.codeargument')
    bool = false;
    return;
end

val1 = get(hArg1,'Value');
val2 = get(hArg2,'Value');

if isempty(val1) && isempty(val2)
    if hArg1 == hArg2
        bool = true;
    else
        bool = false;
    end
else
    % Cast to handle if old style double handle type
    if ishandle(val1)
        val1 = handle(val1);
    end
    if ishandle(val2)
        val2 = handle(val2);
    end

    bool = all(isequal(val1,val2));
end