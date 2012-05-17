function sync2way(dst,src,varargin)
%sync2way Two-way synchronization of two groups.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2006/06/27 23:31:15 $

sync(dst,src,varargin{:});
sync(src,dst,varargin{:});

% [EOF]
