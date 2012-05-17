function this = OperatingReport(model)
% OPERATINGREPORT  Create the operating report specification object
%
 
% Author(s): John W. Glass 14-Feb-2007
% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2007/04/25 03:19:44 $

this = opcond.OperatingReport;

% Load case
if nargin == 0
    return
end
    
this.model = model;
this.Version = opcond.getVersion;