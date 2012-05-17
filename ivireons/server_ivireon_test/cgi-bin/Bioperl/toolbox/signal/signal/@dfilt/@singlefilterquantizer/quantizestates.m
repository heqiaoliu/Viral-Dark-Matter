function S = quantizestates(q,S)
%QUANTIZESTATES   

%   Author(s): V. Pellissier
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/07/27 20:31:25 $


if strcmpi(class(S),'filtstates.dfiir'),
    S.Numerator = single(double(S.Numerator));
    S.Denominator = single(double(S.Denominator));
else
    S = single(double(S));
end

% [EOF]
