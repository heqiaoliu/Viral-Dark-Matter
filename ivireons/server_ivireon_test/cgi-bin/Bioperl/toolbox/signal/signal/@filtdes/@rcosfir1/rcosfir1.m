function h = rcosfir1
%RCOSFIR1 Constructor for this object.
%
%   Outputs:
%       h - Handle to this object

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/15 00:14:45 $


h = filtdes.rcosfir1;

% Call the super's constructor
filterType_construct(h);

