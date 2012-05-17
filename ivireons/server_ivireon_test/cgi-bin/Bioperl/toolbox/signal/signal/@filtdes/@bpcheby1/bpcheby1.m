function h = bpcheby1
%BPCHEBY1  Constructor for the bandpass chebyshev type I filter type.
%
%   Outputs:
%       h - Handle to this object

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/15 00:29:59 $

h = filtdes.bpcheby1;

% Call the super's constructor
filterType_construct(h);




