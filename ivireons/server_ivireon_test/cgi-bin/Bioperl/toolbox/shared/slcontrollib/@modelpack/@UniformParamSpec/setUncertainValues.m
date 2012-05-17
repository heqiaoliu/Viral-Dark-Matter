function setUncertainValues(this,nVals) 
% SETUNCERTAINVALUES  method to set the uncertain values for a
% UniformParamSpec object.
%
% this.setUncertainValues(nVals)
%
% NVALS a scalar double with the number of uncertain values to set
%
 
% Author(s): A. Stothert 08-Aug-2005
% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/11/17 14:00:44 $

dim   = this.ID.getDimensions;       %dimension of each uncertain value
uv    = rand([nVals, dim]);          %[0-1] random variable of correct size 
uset  = cell(nVals,1);
range = this.Maximum-this.Minimum;    

for ct = 1:nVals
   uset{ct,1} = this.Minimum+range.*reshape(uv(ct,:),dim);
end

this.UncertainValue = uset;