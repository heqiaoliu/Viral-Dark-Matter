function extension = getExtension(this, varargin)
%GETEXTENSION Get the extension.

%   Author(s): J. Schickler
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/08/24 15:06:12 $

% Find the extension on the <this>.ExtensionDb object.  This is relying on
% the current implementation of connections in the extension manager to get
% an associated extension.  This violates our best practice for object
% containment, but there is currently no way to get a needed extension at
% extmgr.Driver construction time.
extension = getExtension(this.up, varargin{:});

% [EOF]
