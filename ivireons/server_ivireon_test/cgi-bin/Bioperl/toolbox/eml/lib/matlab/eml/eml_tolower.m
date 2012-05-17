function s = eml_tolower(s)
%Embedded MATLAB Private Function

%   Copyright 1984-2009 The MathWorks, Inc.
%#eml

for k = 1:eml_numel(s)
    if s(k) >= 'A' && s(k) <= 'Z'
        s(k) = s(k) + ('a' - 'A');
    end
end
