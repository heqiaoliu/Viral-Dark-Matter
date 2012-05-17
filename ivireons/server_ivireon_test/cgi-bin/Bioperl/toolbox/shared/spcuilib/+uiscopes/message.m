function [msg, id] = message(id, varargin)
%MESSAGE  Return the message given the id.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/12/07 20:45:09 $

% Build up the ID.
id = ['Spcuilib:scopes:' id];

% Get the Message catalog object.
mObj = MessageID(id);

% Get the individual message.
msg  = message(mObj, varargin{:});

% [EOF]
