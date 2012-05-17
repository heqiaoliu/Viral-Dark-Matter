function this = spckeybinding(varargin)
%SPCKEYBINDING Construct a spckeybinding object
%   SPCKEYBINDING(NAME,KEY(S),FUNCTION,DESCRIPTION) sets the UIMgr node
%   NAME, the KEY(S) to bind to the FUNCTION, and a description of the 
%   keybinding 
%
%   % Example:
%
%       uimgr.spckeybinding('playpause',{'P', 'Space'},...
%                 @(h,ev)slPlayPause(this), 'Play/pause simulation');
%
%       See also spckeygroup on how to construct keygroup objects

%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/07/23 18:44:21 $

% Allow subclass to invoke this directly
this = uimgr.spckeybinding;

% Fill in all other prop/value pairs
if (nargin > 0)
    this.uiitem(varargin{1});
else
    this.uiitem(varargin{:})
end

this.hKeyBinding = spcwidgets.KeyBinding(varargin{2:end});

% [EOF]
