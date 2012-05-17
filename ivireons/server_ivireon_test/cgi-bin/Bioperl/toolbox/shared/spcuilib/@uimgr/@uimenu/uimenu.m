function h = uimenu(varargin)
%UIMENU Constructor for a uimenu object.
%    UIMENU(NAME,PLACE,FCN) specifies menu name NAME, placement PLACE,
%    and function-handle FCN which is responsible for constructing the
%    underlying HG menu that is being wrapped in the UIMgr Architecture.
%
%    Two arguments, hParent and state, are automatically passed to
%    the function FCN, so the function can instantiate a  widget
%    parented to the appropriate menugroup or tooblargroup.  FCN may be an 
%    anonymous function.  A typical example of FCN is
%           @myMenuFcn
%    where the function is as follows:
%
%         function y = myMenuFcn(hParent,state)
%         y = uipushtool(hParent, ...
%             'label','Open a file...', ...
%             'checked',state,...
%             'callback', @openTheFileAction);
%
%    FCN may be optionally replaced by a string, indicating the text
%    for the menu label.  In this case, a default menu function is
%    is automatically provided, and the FCN string is used as follows:
%
%         @(hParent,state)uimenu(hParent,'label',FCN)
%
%    UIMENU(NAME,PLACE), UIMENU(NAME,FCN), and UIMENU(NAME)
%    assume default values for PLACE (which defaults to 0) and FCN
%    which defaults to an empty function.  Note that FCN must be
%    filled in prior to rendering the menu using the render()
%    method.
% 
%    % Example:
% 
%        hLoad = uimgr.uimenu('Load','&Load'); 
%  
%        % where the first argument is the name to use for the new UIMgr
%        % node and the second is the string to use for the menu item 
%        % itself.  

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2009/10/29 16:09:31 $

% Allow subclass to invoke this directly
if (nargin>0) && isscalar(varargin{1}) && isa(varargin{1}, 'uimgr.uimenu')
    h = varargin{1};
    varargin(1) = [];
else
    h = uimgr.uimenu;
end

% State property name for menus
h.StateName = 'Checked';

% Fill in all other prop/value pairs
h.uiitem(varargin{:});

% [EOF]
