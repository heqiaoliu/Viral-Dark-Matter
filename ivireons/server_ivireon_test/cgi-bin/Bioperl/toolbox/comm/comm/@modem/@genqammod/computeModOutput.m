function y = computeModOutput(h, x)
%COMPUTEMODOUTPUT Compute modulator output for modulator object H. 

% @modem/@genqammod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/06 15:47:41 $

% Get constellation and make sure that it has the same orientation as the
% input.  Assumes that constellation is a row vector.
if ( size(x, 2) == 1 )
    constellation = h.Constellation(:);
else
    constellation = h.Constellation;
end

% Mapping is always binary, so map directly
y = constellation(x+1);

%--------------------------------------------------------------------
% [EOF]