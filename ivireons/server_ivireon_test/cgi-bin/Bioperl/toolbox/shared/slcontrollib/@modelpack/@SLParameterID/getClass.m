function cls = getClass(this)
% GETCLASS Returns the class of the value of the parameter identified by THIS.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2005 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2006/09/30 00:24:25 $

cls = get(this, 'Class');
