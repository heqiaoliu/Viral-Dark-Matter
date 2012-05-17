function h = bpcheby2
%BPCHEBY2  Constructor for the bandpass chebyshev type II filter type.
%
%   Outputs:
%       h - Handle to this object

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/15 00:30:13 $

h = filtdes.bpcheby2;

% Call the super's constructor
filterType_construct(h);





