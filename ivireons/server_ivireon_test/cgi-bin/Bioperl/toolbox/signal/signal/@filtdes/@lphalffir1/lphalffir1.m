function h = lphalffir1
%LPHALFFIR1 Constructor for this object.
%
%   Outputs:
%       h - Handle to this object

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/15 00:14:06 $


h = filtdes.lphalffir1;

% Call the super's constructor
filterType_construct(h);

