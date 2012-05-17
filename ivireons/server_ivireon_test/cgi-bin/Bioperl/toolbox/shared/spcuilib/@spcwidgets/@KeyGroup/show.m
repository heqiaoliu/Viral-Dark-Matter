function show(hGroup,varargin)
%SHOW Display key help.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2007/03/13 19:48:05 $

hKeyMgr = hGroup.up;  % assume parent is a KeyMgr object
if ~isempty(hKeyMgr)
    show(hKeyMgr,varargin{:}); % flag: update, don't create
end

% [EOF]
