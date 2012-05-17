function d = firlpnorm
%FIRLPNORM  Constructor for this design method.
%
%   Outputs:
%       d - Handle to the design method object

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/15 00:36:39 $

d = filtdes.firlpnorm;

% Call super's constructor
lpnorm_construct(d);

% Set the tag
set(d,'Tag','FIR least P-th norm');







