function h = remeznyq
%REMEZNYQ Constructor for this object.
%
%   Outputs:
%       h - Handle to this object

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/15 00:10:57 $

h = filtdes.remeznyq;

% Call the super's constructor
filterType_construct(h);

