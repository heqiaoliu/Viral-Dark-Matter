function b = isappdata(hObj, varargin)
%ISAPPDATA Returns true if the application data exists

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/08/19 17:59:02 $

b = isappdata(hObj.FigureHandle, varargin{:});

% [EOF]
