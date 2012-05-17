function this = fmincon_xuvary(opcond,options,LinearizationIOs)

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2007/12/14 15:27:05 $

% Construct the object
this = OptimizationObjects.fmincon_xuvary;
this.LinearizationIOs = LinearizationIOs;
this.linoptions = options;
initialize(this,opcond);