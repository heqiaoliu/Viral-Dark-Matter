function res = cv_get_param(handle, param)

% Copyright 2003-2007 The MathWorks, Inc.
res = [];
try
    if ishandle(handle)
        res = get_param(handle, param);
    end
catch Mex %#ok<NASGU>
end
    
    