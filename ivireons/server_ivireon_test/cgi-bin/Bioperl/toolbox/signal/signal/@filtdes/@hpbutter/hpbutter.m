function h = hpbutter
%HPBUTTER  Constructor for the highpass butterworth filter type.
%
%   Outputs:
%       h - Handle to this object

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/15 00:39:27 $

h = filtdes.hpbutter;

% Call the super's constructor
filterType_construct(h);





