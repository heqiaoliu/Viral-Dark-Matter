function setType(this, type)
% SETTYPE Sets the I/O type of the port identified by THIS.
%
% TYPE is an enumerated string of type Model_IOType: 'Input' or 'Output'.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2005 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2006/09/30 00:23:47 $

warning('modelpack:AbstractMethod', ...
        'Method needs to be implemented by subclasses.');
