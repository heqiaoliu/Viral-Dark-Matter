function deletefilter(hObj, varargin)
%DELETEFILTER Delete a filter from FVTool

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/08/19 17:58:14 $

hFVT = getcomponent(hObj, 'fvtool');

hFVT.deletefilter(varargin{:});

% [EOF]
