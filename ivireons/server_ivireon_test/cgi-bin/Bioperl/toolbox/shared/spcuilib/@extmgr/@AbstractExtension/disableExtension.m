function disableExtension(this, varargin)
%DISABLEEXTENSION Called when extension object is disabled.
%   DISABLEEXTENSION(H) calls disable to allow subclasses to disable and
%   then uninstalls extension GUI, if provided.

% Copyright 2006-2009 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2009/09/09 21:28:51 $

% This is an interface method; it should not be overloaded in subclasses,
% unless the author is very familiar with the extension system.

% Call (possibly overloaded) extension termination method first.
disable(this);

% Uninstall GUI components.
uninstallGUI(this, varargin{:});

% [EOF]
