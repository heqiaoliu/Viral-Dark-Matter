function show(hBinding,varargin)
%SHOW Display key help.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2007/03/13 19:47:57 $

hGroup=hBinding.up;
if ~isempty(hGroup)
    show(hGroup,varargin{:}); % flag: update, don't create
end

% [EOF]
