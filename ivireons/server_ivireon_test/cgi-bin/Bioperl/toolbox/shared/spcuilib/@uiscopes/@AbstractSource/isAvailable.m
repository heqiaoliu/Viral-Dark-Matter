function y = isAvailable(this)
%ISAVAILABLE Determines if source available for use
%   False may be returned if data source not licensed,
%   hardware or interface is unavailable for use, etc.

% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2007/05/23 19:08:41 $

% The base class returns TRUE always, convenient
% for subclasses that are always available
y = true;

% [EOF]
