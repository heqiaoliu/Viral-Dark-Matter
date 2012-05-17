function h = uiitem(varargin)
%UIITEM Instantiate UIMgr item object.
%    UIITEM(NAME,PLACE,FCN) specifies item name NAME, placement
%    PLACE, and function-handle FCN which is responsible for
%    constructing a graphical widget.  NAME must be unique among
%    all child items at this level in the UIMgr hierarchy.
%
%    One argument, hParent, is automatically passed to the function
%    FCN, so the function can instantiate an instance of a widget
%    parented to the appropriate graphical parent object.  FCN may
%    be an anonymous function.  A typical example of FCN is
%           @(hParent)myListFcn(hParent,otherArgs)
%
%    UIITEM(NAME,PLACE), UIITEM(NAME,FCN), and
%    UIITEM(NAME) assume default values for PLACE (which defaults
%    to 0) and FCN which defaults to an empty function.  Note that FCN must
%    be filled in prior to rendering the button using the render()
%    method.

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2009/03/09 19:34:22 $

% Subclasses of uiitem must support the following:
%   - a single "state" property, registered via StateName property
% Methods:
%   - delete()
%
% Subclasses of uiitem must support the following:
%   - a user-supplied function that returns a scalar handle when
%     executed for child creation via uiitem construction
%
% Subclasses of uiitem may optionally support:
%   - Separator
%   - Visible
%   - Enable

% Allow subclass to invoke this directly
if (nargin>0) && isscalar(varargin{1}) 
    h = varargin{1};
    varargin(1) = [];
else
    h = uimgr.uiitem;
end
parseArgs(h,varargin);  % can be overloaded

% Do NOT instantiate Explorer object - we do a lazy instantiation
% of the object when the explore() method is called.  This
% saves time and memory for uiitem instantiation, especially
% when this is only used during creation/debug.
%
% h.explorer = uimgr.uiexplorer(h);  % purposely deferred

% Do NOT instantiate the SyncList object - we do a lazy instantiation
% of the object when the add() method is called.  This
% saves time and memory for uiitem instantiation, especially
% since item sync is not always utilized.
%
% h.SyncList = uimgr.uisynclist;  % purposely deferred

% [EOF]
