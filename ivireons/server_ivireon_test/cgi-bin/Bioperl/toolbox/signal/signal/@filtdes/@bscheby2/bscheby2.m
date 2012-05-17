function h = bscheby2
%BSCHEBY2  Constructor for the bandstop chebyshev type II filter type.
%
%   Outputs:
%       h - Handle to this object

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/15 00:33:02 $

h = filtdes.bscheby2;

% Call the super's constructor
filterType_construct(h);





