function remove(h,varargin)
%REMOVE Unrender and remove node from hierarchy.
%  REMOVE(H,NAME) unrenders and removes the named child from
%  the hierarchy, where NAME is specified relative to H.
%  All children of the named child will also be unrendered
%  and removed.
%
%  REMOVE(H) unrenders and removes H from the hierarchy.
%  All children of H will also be unrendered and removed.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2006/06/27 23:30:44 $

% Example:
%   Create File and File->Save menus (using a bottom-up approach):
%      hSave = uimgr.uimenu('Save');
%      hFile = uimgr.uimenu('File',hSave);
%      hAll = uimgr.uigroup('Menus',hFile);
%
%   Now remove the Save menu from the hierarchy:
%      hAll.remove({'File','Save'});
%   or
%      hAll.remove('File','Save');
%   or
%      hFile.remove('Save');

if nargin>1
    % Find child
    h = h.findchild(varargin{:});  % e.g., find {'File','Save'}
    if isempty(h)
        error('uimgr:ChildNotFound', 'Child not found.');
    end
end

% Unrender this widget, and all children widgets
h.unrender;

% Remove this node from hierarchy, leaving intact all
% children connected to this (now dangling) node
h.disconnect;

% [EOF]
