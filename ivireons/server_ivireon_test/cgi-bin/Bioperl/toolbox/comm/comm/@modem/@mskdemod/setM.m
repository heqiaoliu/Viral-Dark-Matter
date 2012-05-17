function M = setM(h, M)
%SETM Validate and set M for object H.

%   @modem/@mskdemod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/14 15:02:53 $

% For MSK M must be 2
if (M ~= 2)
    M = 2;
    warning([getErrorId(h) ':MMustBe2'], 'M must be 2 for MSK and is set accordingly.');
end;

%-------------------------------------------------------------------------------
% [EOF]