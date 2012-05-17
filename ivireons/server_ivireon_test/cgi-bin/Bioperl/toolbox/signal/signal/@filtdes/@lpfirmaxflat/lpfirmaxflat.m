function h = lpfirmaxflat
%LPFIRMAXFLAT  Constructor for the lowpass maxflat filter type.
%
%   Outputs:
%       h - Handle to this object

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/03/28 17:20:59 $

h = filtdes.lpfirmaxflat;

% Call the super's constructor
filterType_construct(h);

