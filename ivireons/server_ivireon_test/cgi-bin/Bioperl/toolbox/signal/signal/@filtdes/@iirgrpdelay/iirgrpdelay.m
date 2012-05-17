function d = iirgrpdelay
%IIRGRPDELAY  Constructor for this design method.
%
%   Outputs:
%       d - Handle to the design method object

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/15 00:10:05 $

d = filtdes.iirgrpdelay;

% Call super's constructor
lpnorm_construct(d);


% Set the tag
set(d,'Tag','Arbitrary group delay');







