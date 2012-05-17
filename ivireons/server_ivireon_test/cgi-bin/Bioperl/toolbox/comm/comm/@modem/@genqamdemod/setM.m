function M = setM(h, M)
%SETM Validate and set M for object H.

%   @modem/@genqamdemod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/06 15:47:38 $

% For M is determined by Constellation size
if (M ~= length(h.Constellation) )
    M = length(h.Constellation);    
    warning([getErrorId(h) ':MMustBeLengthConstellation'], 'M must be equal to the Constellation size.');
end;

%-------------------------------------------------------------------------------
% [EOF]