function [str, id] = message(id, varargin)
%MESSAGE  Return the uiservices specific message.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/04/27 19:55:58 $

id = ['Spcuilib:uiservices:' id];
str = DAStudio.message(id, varargin{:});

% [EOF]
