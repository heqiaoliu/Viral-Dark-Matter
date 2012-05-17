function close(hObj, varargin)
%CLOSE Close the figure

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/08/19 17:58:53 $

close(hObj.FigureHandle, varargin{:});

% [EOF]