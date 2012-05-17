function legend(hObj, varargin)
%LEGEND   Add a legend to FVTool.
%   LEGEND(H, STR1, STR2, etc.) Add a legend to the FVTool associated with
%   H.  STR1 will be associated with the first filter, STR2 will be
%   associated with the second filter, etc.
%
%   LEGEND(H, ..., 'Location', LOC) Add a legend to FVTool in the location
%   LOC.  See LEGEND for more information.  LOC is 'Best' by default.
%
%   LEGEND(H, 'Location', LOC) Changes the location of the legend without
%   changing the strings in the legend.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/10/18 21:11:30 $

hFVT = getcomponent(hObj, 'fvtool');

legend(hFVT, varargin{:});

% [EOF]
