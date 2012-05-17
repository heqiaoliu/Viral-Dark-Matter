function setappdata(hObj, varargin)
%SETAPPDATA Saves the application data specified

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/08/19 17:59:08 $

setappdata(hObj.FigureHandle, varargin{:});

% [EOF]
