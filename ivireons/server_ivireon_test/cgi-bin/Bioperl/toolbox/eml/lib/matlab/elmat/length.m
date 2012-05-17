function n = length(x)
%Embedded MATLAB Library Function

%   Copyright 2006-2008 The MathWorks, Inc.
%#eml

eml_allow_enum_inputs;
eml_assert(nargin == 1, 'Not enough input arguments');
s = size(x);
n = 0;
for k = 1:eml_numel(s)
    if s(k) == 0
        n = 0;
        break
    elseif s(k) > n
        n = s(k);
    end
end
