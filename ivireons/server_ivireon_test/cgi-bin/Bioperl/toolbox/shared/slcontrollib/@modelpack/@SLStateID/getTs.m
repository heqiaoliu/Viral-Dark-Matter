function Ts = getTs(this)
% GETTS Returns the sampling time of the state identified by THIS.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2005 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2006/09/30 00:24:59 $

Ts = get(this, 'Ts');
