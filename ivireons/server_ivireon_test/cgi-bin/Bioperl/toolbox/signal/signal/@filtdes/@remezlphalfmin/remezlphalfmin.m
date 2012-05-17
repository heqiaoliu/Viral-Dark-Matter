function h = remezlphalfmin
%REMEZLPHALFMIN Constructor for this object.
%
%   Outputs:
%       h - Handle to this object

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/15 00:12:56 $


h = filtdes.remezlphalfmin;

% Call the super's constructor
filterType_construct(h);

