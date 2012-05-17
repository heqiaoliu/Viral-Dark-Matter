function h = lpnorm
%LPNORM  Constructor for the lpnorm specifications object.
%
%   Outputs:
%       h - Handle to the lpnorm object

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/15 00:45:56 $


h = filtdes.lpnorm;
% Call the real constructor
lpnorm_construct(h);
