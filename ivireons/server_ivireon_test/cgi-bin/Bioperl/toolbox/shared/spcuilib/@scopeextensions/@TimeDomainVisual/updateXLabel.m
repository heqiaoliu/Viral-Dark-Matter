function updateXLabel(this)
%UPDATEXLABEL 

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/12/07 20:45:12 $

xlabel(this.Axes, uiscopes.message('TimeXLabel', this.TimeUnits));

% [EOF]