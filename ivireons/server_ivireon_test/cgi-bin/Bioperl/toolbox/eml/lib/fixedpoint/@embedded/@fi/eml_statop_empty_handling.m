function y = eml_statop_empty_handling(x, isnumin1, ty, dim)%#eml
%EML_STATOP_EMPTY_HANDLING Internal use only function
%   Y = EML_STATOP_EMPTY_HANDLING(X, ISNUMIN1, Ty, DIM) generates the output
%   for statistical functions like mean and median when the input is empty.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2009/09/09 21:06:34 $

if isnumin1&&isequal(x, [])
    y = fi(0, ty);
else
    sizex = size(x);
    if dim <= length(sizex)
        
        sizex(dim) = 1;
    end
    y = fi(zeros(sizex), ty);
end
