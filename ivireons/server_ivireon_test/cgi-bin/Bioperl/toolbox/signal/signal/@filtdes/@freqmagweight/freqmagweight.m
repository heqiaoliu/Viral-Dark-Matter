function h = freqmagweight
%freqmagweight  Constructor for this object.
%
%   Outputs:
%       h - Handle to this object

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/04/15 00:38:09 $


h = filtdes.freqmagweight;

% Call alternate constructor
fmw_construct(h);

