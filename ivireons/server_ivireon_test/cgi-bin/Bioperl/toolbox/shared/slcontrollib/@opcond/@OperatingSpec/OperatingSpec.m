function this = OperatingSpec(model) 
% OPERATINGSPEC  Create the operating point specification object
%
 
% Author(s): John W. Glass 14-Feb-2007
% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2007/04/25 03:19:51 $

this = opcond.OperatingSpec;

% Load case
if nargin == 0
    return
end
    
this.model = model;
this.Version = opcond.getVersion;