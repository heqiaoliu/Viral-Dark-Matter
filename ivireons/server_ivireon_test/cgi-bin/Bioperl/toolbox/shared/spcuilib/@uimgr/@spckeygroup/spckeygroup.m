function this = spckeygroup(varargin)
%SPCKEYGROUP Constructor for spckeygroup object.
%   SPCKEYGROUP(NAME,PLACE,K1,K2,...) sets the group name, the
%   keygroup rendering placement, and adds keybinding objects
%   K1, K2, etc.  Specifying keybinding objects is optional.
%
%   % Example:
%
%       hKeyPlayback = uimgr.spckeygroup('Playback');
%             hKeyPlayback.add(...
%                 uimgr.spckeybinding('playpause',{'P', 'Space'},...
%                 @(h,ev)slPlayPause(this), 'Play/pause simulation'));
%
%       See also spckeybinding on how to construct keybinding objects

%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/07/06 20:47:07 $

% Allow subclass to invoke this directly
this = uimgr.spckeygroup;

this.uigroup(varargin{:});

this.hKeyGroup = spcwidgets.KeyGroup(varargin{1});

% [EOF]
