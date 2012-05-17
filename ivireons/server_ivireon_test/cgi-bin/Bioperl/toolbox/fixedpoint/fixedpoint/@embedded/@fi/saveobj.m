function y = saveobj(x)
%SAVEOBJ Save filter for FI objects whose "DataType" property is "double"

%   Copyright 2003-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2006/12/20 07:12:49 $

% If x is a fi-double save it as a struct
y = [];
if (isdouble(x))
    y = struct(x);
    % Remove unnecessary fields like FractionLength & Slope
    y = rmfield(y,...
                {'FractionLength','Slope','ProductFractionLength',...
                 'ProductSlope','SumFractionLength','SumSlope'});
    % Add the double data as a field
    y.Data = double(x);
end
    

    
    
