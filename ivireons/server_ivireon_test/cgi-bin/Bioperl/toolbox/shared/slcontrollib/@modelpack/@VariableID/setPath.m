function setPath(this, path)
% SETPATH Sets the relative path to the object identified by THIS.
%
% PATH is a string.
%
% ATTN: Model name is not part of the path name.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2006/09/30 00:25:52 $

warning('modelpack:AbstractMethod', ...
        'Method needs to be implemented by subclasses.');
