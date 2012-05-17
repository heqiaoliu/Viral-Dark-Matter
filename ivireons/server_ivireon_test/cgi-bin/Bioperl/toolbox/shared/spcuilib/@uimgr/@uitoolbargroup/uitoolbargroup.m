function h = uitoolbargroup(varargin)
%UITOOLBARGROUP Constructor for uitoolbargroup object.
%   UITOOLBARGROUP A toolbar group is a collection of toolbars at the top 
%   of an HG figure window.
%
%   UITOOLBARGROUP(NAME) creates a UITOOLBARGROUP object and sets
%   the object name to NAME.
%
%   UITOOLBARGROUP(NAME,PLACE,T1,T2,...) sets the group name, the
%   toolbar group rendering placement, and adds uitoolbar
%   objects T1, T2, etc.  Specifying the objects T1, T2, ...,
%   is optional.
%
%   UITOOLBARGROUP(NAME,T1,T2,...) and UITOOLBARGROUP(NAME) sets
%   the placement to 0.
%
%   Use "help uitoolbar" to see what the uitoolbar FUNCTION is;
%   that is the essence of what the uitoolbargroup class provides.
%   Unlike the standard uitoolbar, however, the uitoolbar class
%   can additionally contain uibuttongroup objects within it,
%   and a toolbar group provides for multiple separate toolbars.
%  
%   % Example 1:
%
%   hMainToolbar = uimgr.uitoolbar('Main');
%   hPlaybackToolbar = uimgr.uitoolbar('Playback');
%   h = uimgr.uitoolbargroup('Toolbars', hMainToolbar, hPlaybackToolbar);
%   
%   % where the first argument is the name to use for the new UIMgr node, 
%   % and the second and third items are the handles to previously created
%   % toolbars
    


% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2009/07/06 20:47:26 $

% Allow subclass to invoke this directly
h = uimgr.uitoolbargroup;

% This object does not support a user-specified widget function;
% the uitoolbargroup simply confirms that a figure is present,
% and contains uitoolbar objects.
h.allowWidgetFcnArg = false;

% Continue with standard group instantiation
h.uigroup(varargin{:});

% [EOF]
