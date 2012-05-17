function y = eml_matlab_zlangeM(x)
%Embedded MATLAB Private Function

%   ZLANGE with 'M' option.
%   Equivalent to norm(x(:),inf) but hopefully avoids creating x(:).

%   Copyright 2005-2010 The MathWorks, Inc.
%#eml

y = zeros(class(x));
if ~isempty(x)
    for k = 1 : eml_numel(x)
        absxk = abs(x(k));
        if isnan(absxk)
            y = eml_guarded_nan(class(x));
            return
        end
        if absxk > y
            y = absxk;
        end
    end
end
