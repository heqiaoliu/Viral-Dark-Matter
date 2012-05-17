function h = bscheby1
%BSCHEBY1  Constructor for the bandstop chebyshev type I filter type.
%
%   Outputs:
%       h - Handle to this object

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/15 00:32:48 $

h = filtdes.bscheby1;

% Call the super's constructor
filterType_construct(h);





