function h = lpellip
%LPELLIP  Constructor for the lowpass elliptic filter type.
%
%   Outputs:
%       h - Handle to this object

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/15 00:44:01 $

h = filtdes.lpellip;

% Call the super's constructor
filterType_construct(h);





