function portno = getPortNumber(this)
% GETPORTNUMBER Returns the number of the port identified by THIS.
%
% PORTNO is a scalar integer (vector of integers if THIS is an object array).

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2005 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2006/09/30 00:24:44 $

portno = get(this, {'PortNumber'});
portno = cat(1, portno{:});
