function [objH, errStr] = getObjH(obj)

%   Copyright 2009-2010 The MathWorks, Inc.

    errStr = '';
    objH = [];
    if ischar(obj)
        try
            objH = get_param(obj,'Handle');
        catch Mex
            errStr = Mex.message;
        end
    else
        if ishandle(obj)
            objH = obj;
        else
            errStr = 'Invalid object';
        end
    end
end      

