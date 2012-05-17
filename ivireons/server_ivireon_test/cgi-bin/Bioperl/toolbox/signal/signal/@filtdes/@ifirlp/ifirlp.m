function h = ifirlp
%IFIRLP Constructor for this object.
%
%   Inputs:
%
%   Outputs:
%       h - Handle to this object

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2003/03/02 10:21:03 $

h = filtdes.ifirlp;

% Call the super's constructor
filterType_construct(h);

% [EOF]
