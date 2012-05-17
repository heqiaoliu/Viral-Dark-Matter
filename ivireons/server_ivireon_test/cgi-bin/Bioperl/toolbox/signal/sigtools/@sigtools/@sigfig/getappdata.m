function out = getappdata(hObj, varargin)
%GETAPPDATA Returns the application data specified

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/08/19 17:58:59 $

out = getappdata(hObj.FigureHandle, varargin{:});

% [EOF]
