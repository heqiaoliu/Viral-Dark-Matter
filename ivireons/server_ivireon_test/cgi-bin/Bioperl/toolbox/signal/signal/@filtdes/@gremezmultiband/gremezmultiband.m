function h = gremezarbmag
%GREMEZARBMAG Constructor for this object.
%
%   Outputs:
%       h - Handle to this object

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:08:19 $

h = filtdes.gremezmultiband;

% Call the super's constructor
fmw_construct(h);

% [EOF]
