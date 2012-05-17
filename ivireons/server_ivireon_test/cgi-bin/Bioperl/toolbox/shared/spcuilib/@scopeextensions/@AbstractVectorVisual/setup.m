function setup(this, hVisParent)
%SETUP    Set the vector visualization.

%   Author(s): J. Schickler
%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/07/06 20:46:38 $

setupLine(this, hVisParent);

hAxes = get(this, 'Axes');

xlabel(hAxes, this.XLabel);
ylabel(hAxes, this.YLabel);

% [EOF]
