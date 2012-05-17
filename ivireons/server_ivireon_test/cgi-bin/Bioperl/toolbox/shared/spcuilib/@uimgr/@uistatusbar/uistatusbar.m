function h = uistatusbar(varargin)
%UISTATUSBAR Constructor for uistatusbar object.
%   UISTATUSBAR - A statusbar is a readout region at the bottom of an HG
%   figure window, and can additionally contain uistatus and uistatusgroup
%   objects within it.  See "help spcwidgets.uistatusbar" for more details
%   on widget properties.
%
%   UISTATUSBAR(NAME,PLACE,FCN,S1,S2,...) sets the object name, the
%   rendering placement, the user widget creation function, and
%   adds child statusbar option objects S1, S2, etc.  Specifying child
%   statusbar objects is optional.  If omitted, placement is set to 0.
%
%   The child statusbar option objects S1, S2, ..., will appear at the
%   right side of the statusbar.  If FCN is omitted, a default statusbar
%   will be automatically created.  Note that the .StateValue property
%   of the UISTATUSBAR object will be used as the status text.
%
%   Supported constructor signatures:
%    UISTATUSBAR(NAME)
%    UISTATUSBAR(NAME,        C1,C2,...)
%    UISTATUSBAR(NAME,PLACE)
%    UISTATUSBAR(NAME,    FCN)
%    UISTATUSBAR(NAME,PLACE,    C1,C2,...)
%    UISTATUSBAR(NAME,    FCN,C1,C2,...)
%    UISTATUSBAR(NAME,PLACE,FCN)
%    UISTATUSBAR(NAME,PLACE,FCN,C1,C2,...)
% 
%   Example:
% 
%   % Create status bar
%       hs = uimgr.uistatusbar('StatusBar');
% 
%   % Create status options
%       ho2 = uimgr.uistatus('Rate');
%       ho3 = uimgr.uistatus('Frame');
%
%   % Create a status group and put the status items in it
%       hStdOpts = uimgr.uistatusgroup('StdOpts',ho2,ho3);
%
%   % add the statusgroup to the status bar
%       hs.add(hStdOpts);

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2009/08/14 04:07:38 $

% Allow subclass to invoke this directly
h = uimgr.uistatusbar;

% StatusBar should be treated as a single item when it
% is a sync destination, so its visibility (etc) is set as
% a single entity.  Menus don't behave this way, however;
% menus that are groups (and even have a group widget)
% still should look like a collection of children.  Ditto
% for buttons. So StatusBar overrides this to true.
h.TreatAsItemForSyncDst = true;

% State property name for spcwidgets.uistatusbar objects
h.StateName  = 'Text';

% This object OPTIONALLY SUPPORTS a user-specified widget function;
% by default, the uistatusbar instantiates an spcwidgets.uistatusbar
% with no tooltip, callback etc.  The state is the 'text' string.
%
% Caller *can* specify their own widget fcn, however, in order to
% set other initial properties settings (tooltip, callback, etc).
%
% (Contrast this with the uimgr.uitoolbar constructor, which supplies
%  a default widget fcn but does NOT allow the user to specify their
%  own.  Why the difference?  toolbars have no user-specified proprties,
%  whereas statusbars do.  So at render time, user may desire certain
%  properties to be pre-set.  But that's optional.)
%
h.allowWidgetFcnArg = true;

% We always create a statusbar widget every time we render
h.WidgetFcn = @(h)createStatusbar(h);

% Continue with standard group instantiation
% Note: args may override .WidgetFcn above, and that is supported
h.uigroup(varargin{:});

function hWidget = createStatusbar(h)
hWidget = ...
    spcwidgets.StatusBar(h.GraphicalParent,h.StateName,'Ready');
% [EOF]
