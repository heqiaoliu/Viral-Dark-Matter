function hMenu = createContextMenuItem(varargin)
% Helper function to append additional context menus

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $     $Date: 2010/03/31 18:20:29 $

hMenu = uimenu('parent',varargin{1}, ...
    'label',varargin{2}, ...
    'callback',varargin{3:end});
