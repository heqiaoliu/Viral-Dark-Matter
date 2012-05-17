function h = lpiirmaxflat
%LPIIRMAXFLAT  Constructor for the lowpass maxflat filter type.
%
%   Outputs:
%       h - Handle to this object

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/03/28 17:21:22 $

h = filtdes.lpiirmaxflat;

% Call the super's constructor
filterType_construct(h);

