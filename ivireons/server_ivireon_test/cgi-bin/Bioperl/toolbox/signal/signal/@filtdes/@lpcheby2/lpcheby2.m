function h = lpcheby2
%LPCHEBY2  Constructor for the lowpass chebyshev type II filter type.
%
%   Outputs:
%       h - Handle to this object

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/15 00:43:47 $

h = filtdes.lpcheby2;

% Call the super's constructor
filterType_construct(h);





