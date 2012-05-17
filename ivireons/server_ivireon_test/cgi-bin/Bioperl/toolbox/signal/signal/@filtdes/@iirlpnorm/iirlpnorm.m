function d = iirlpnorm
%IIRLPNORM  Constructor for this design method object.
%
%   Outputs:
%       d - Handle to the design method object

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/15 00:42:53 $


d = filtdes.iirlpnorm;

% Call the 'real' constructor
iirlpnorm_construct(d);

