function S = quantizestates(q,S)
%QUANTIZESTATES   

%   Author(s): V. Pellissier
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/10/18 21:03:24 $

if strcmpi(class(S),'filtstates.dfiir'),
    S.Numerator = double(S.Numerator);
    S.Denominator = double(S.Denominator);
else
    S = double(S);
end

% [EOF]
