function setTs(this, Ts)
% SETTS Sets the sampling time of the state identified by THIS.
%
% TS is a double scalar.  Set to zero for continuous states.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2005 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2006/09/30 00:25:26 $

warning('modelpack:AbstractMethod', ...
        'Method needs to be implemented by subclasses.');
