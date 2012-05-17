function h = findobj(hObj, varargin)
%FINDOBJ Find objects with specified property values.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/08/19 17:58:56 $

h = findobj(hObj.FigureHandle, varargin{:});

% [EOF]
