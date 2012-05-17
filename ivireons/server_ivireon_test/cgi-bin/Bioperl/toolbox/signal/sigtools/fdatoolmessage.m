function msg = fdatoolmessage(id, varargin)
%FDATOOLMESSAGE Translates the string from an ID.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2010/01/25 22:53:02 $

% Build up the ID.
id = ['signal:fdatool:' id];

% Get the Message catalog object.
mObj = MessageID(id);

% Get the individual message.
msg  = message(mObj, varargin{:});

% [EOF]
