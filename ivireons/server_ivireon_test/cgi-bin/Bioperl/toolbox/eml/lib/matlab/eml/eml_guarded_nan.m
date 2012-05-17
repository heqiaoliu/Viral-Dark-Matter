function y = eml_guarded_nan(cls)
%Embedded MATLAB Private Function

%   Returns nan(cls) if nonfinites are supported, otherwise zeros(cls).

%   Copyright 2006-2007 The MathWorks, Inc.
%#eml

eml_transient;
if nargin == 0
    if eml_option('NonFinitesSupport')
        y = nan;
    else
        y = 0;
    end
else
    eml_assert(eml_is_float_class(cls), 'Unsupported class.');
    if eml_option('NonFinitesSupport')
        y = nan(cls);
    else
        y = zeros(cls);
    end
end
