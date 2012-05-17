function [errmsg,a2SD,b2SD,Tsd] = eml_fi_math_with_same_types(Ta,Tb)
% EML Fixed-point helper function that checks to see that 
% Ta & Tb have the same DataType.
    
% Initialize outputs
errmsg = '';
a2SD = false;
b2SD = false;
Tsd = [];

% Get the DataTypes
taDataType = Ta.DataType;
tbDataType = Tb.DataType;

% If a & Tb are scaled check for scaled-double'ness on them and promote the
% one that is not scaled-double to be so.
if isscaledtype(Ta) && isscaledtype(Tb)
    if isscaleddouble(Ta) && ~isscaleddouble(Tb)
        b2SD = true;
        Tsd = Tb; 
        Tsd.DataType = 'ScaledDouble';
    elseif isscaleddouble(Tb) && ~isscaleddouble(Ta)
        a2SD = true;
        Tsd = Ta; 
        Tsd.DataType = 'ScaledDouble';
    else
        return;
    end
elseif ~strcmpi(taDataType,tbDataType)
    errmsg = 'Math operations are not allowed on FI objects with different data types.';
end

