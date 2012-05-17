function d = iirmaxflat
%IIRMAXFLAT  Constructor for this design method object.
%
%   Outputs:
%       d - Handle to the design method object

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/03/28 17:20:33 $


d = filtdes.iirmaxflat;

% Call super's constructor
numden_construct(d);

% Set the tag
set(d,'Tag','IIR maximally flat');


