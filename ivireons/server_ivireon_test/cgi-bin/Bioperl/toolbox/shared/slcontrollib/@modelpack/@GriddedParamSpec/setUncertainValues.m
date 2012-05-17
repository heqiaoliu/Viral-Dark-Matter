function setUncertainValues(this,inVal) 
% SETUNCERTAINVALUES  method to set the uncertain values for a
% GriddedParamSpec object
%
% this.setUncertainValues(nVals)
% this.setUncertainValues(Vals)
%
% NVALS a scalar double with the number of grid values to set, this is used
%       to select nVals from the parameter minimum to maximum value
% VALS a double array with the grid values to set
%

% Author(s): A. Stothert 08-Aug-2005
% Copyright 2005-2007 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/01/15 18:56:52 $

if numel(inVal) == 1 && isnumeric(inVal)
   %Scalar input want to step through full parameter range
   delta = (this.Maximum-this.Minimum)/(inVal-1);
   uset  = cell(inVal,1);
   for ct = 1:inVal
      uset{ct,1} = this.Minimum+(ct-1)*delta;
   end
else
   %Specified values input, need to check that specified values are of the
   %right dimension.
   dim = this.getID.getDimensions;
   dimIn = size(inVal);
   if any(dim>1) && ~all(dimIn(2:end)==dim)
      strSize = sprintf('%dx',dim);
      ctrlMsgUtils.error('SLControllib:modelpack:stErrorDimensionColumn',strSize(1:end-1));
   end
   if any(dim>1)
      %Vector or matrix uncertain values
      this.UncertainValues = cell(dimIn(1),1);
      for ct = 1:dimIn(1)
         this.UncertainValues{ct,1} = squeeze(reshape(inVal(ct,:),dimIn(2:end)));
      end
   else
      %Scalar uncertain values
      this.UncertainValues = cell(numel(inVal),1);
      this.UncertainValues = num2cell(inVal(:));
   end
end