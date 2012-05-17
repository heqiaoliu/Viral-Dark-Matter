function enableExtension(this, varargin)
%ENABLEEXTENSION Called when extension object is enabled.
%   ENABLEEXTENSION(H) installs extension GUI, if provided, and calls
%   enable to allow subclasses to react.
%
%   ENABLEEXTENSION(H, false) installs the GUI but suppresses rendering.

% Copyright 2006-2007 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2007/03/13 19:45:22 $

% This is an interface method; it should not be overloaded in subclasses,
% unless the author is very familiar with the extension system.

installGUI(this, varargin{:});

% Call (overloaded) initialization method last
enable(this);

% [EOF]
