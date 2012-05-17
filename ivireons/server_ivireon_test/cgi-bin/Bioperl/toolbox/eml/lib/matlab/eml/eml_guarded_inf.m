function y = eml_guarded_inf(cls)
%Embedded MATLAB Private Function

%   Returns inf(cls) if nonfinites are supported, otherwise realmax(cls);

%   Copyright 2006-2007 The MathWorks, Inc.
%#eml

eml_transient;
if nargin == 0
    if eml_option('NonFinitesSupport')
        y = inf;
    else
        y = realmax;
    end
else
    eml_assert(eml_is_float_class(cls), 'Unsupported class.');
    if eml_option('NonFinitesSupport')
        y = inf(cls);
    else
        y = realmax(cls);
    end
end
