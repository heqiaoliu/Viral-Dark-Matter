function d = remez
%FIRLS  Constructor for this design method object.
%
%   Outputs:
%       d - Handle to the design method object

%   Author(s): R. Losada
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2004/04/13 00:10:43 $

d = filtdes.remez;

% Call super's constructor
dynMinOrder_construct(d);

% Set the tag
set(d,'Tag','Equiripple');

