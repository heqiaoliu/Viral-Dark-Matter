function path = getPath(this)
% GETPATH Returns the relative path to the parameter identified by THIS.
%
% ATTN: Model name is not part of the path name.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2006 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2006/09/30 00:24:30 $

path = get(this, 'Path');
