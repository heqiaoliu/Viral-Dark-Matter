function legend(this, varargin)
%LEGEND FVTool Legend.
%   LEGEND(H,string1,string2,string3, ...) Bring up the FVTool legend using
%   string1 as the name of the first filter, string2 as the name of the
%   second filter, etc.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.3 $  $Date: 2004/04/13 00:23:56 $

legend(this.CurrentAnalysis, varargin{:});

set(this, 'Legend', 'On');

% [EOF]
