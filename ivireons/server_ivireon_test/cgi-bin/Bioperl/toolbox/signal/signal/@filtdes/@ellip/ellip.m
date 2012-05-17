function d = ellip
%ELLIP  Constructor for this design method object.
%
%   Outputs:
%       d - Handle to the design method object

%   Author(s): R. Losada
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.4 $  $Date: 2007/12/14 15:12:30 $

error(nargchk(0,3,nargin,'struct'));

d = filtdes.ellip;

% Call super's constructor
classiciir_construct(d);

% Set the tag
set(d,'Tag','Elliptic', 'MatchExactly', 'both');

