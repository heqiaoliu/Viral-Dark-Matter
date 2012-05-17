function isSLStructType = util_is_sltruct_type(dtypeStr)

%   Copyright 2009 The MathWorks, Inc.

    isSLStructType = false;
    try
        tmpVar = evalin('base', dtypeStr);
        isSLStructType = isa(tmpVar,'Simulink.StructType');
    catch Mex         %#ok<NASGU>
    end    
end