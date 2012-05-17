function d = firls
%FIRLS  Constructor for this design method object.
%
%   Outputs:
%       d - Handle to the design method object

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/04/15 00:36:57 $

d = filtdes.firls;

% Call super's constructor
singleOrder_construct(d);

% Set the tag
set(d,'Tag','FIR least-squares');





