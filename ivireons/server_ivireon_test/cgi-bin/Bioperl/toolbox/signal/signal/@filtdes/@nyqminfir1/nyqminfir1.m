function h = nyqminfir1
%NYQMINFIR1 Constructor for this object.
%
%   Outputs:
%       h - Handle to this object

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/07/17 13:17:41 $

h = filtdes.nyqminfir1;

% Call the super's constructor
filterType_construct(h);

