function setDimensions(this,dim) 
% SETDIMENSIONS set the dimension of the value specified by the parameter
% spec object. Setting the dimension will also reset the object propertys to
% match the new dimension.
%
% this.setDimension(dim)
%
% Input
%   dim - a row vector with the dimension 
 
% Author(s): A. Stothert 01-Nov-2007
% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2007/12/14 15:01:29 $

if ~(isnumeric(dim) && size(dim,1)==1 && ndims(dim) == 2 && numel(dim) > 1)
   ctrlMsgUtils.error('SLControllib:modelpack:errDimension')
end

if this.isDimensionEditable
   this.Dimension    = dim;
   this.InitialValue = zeros(dim);
   this.Maximum      = inf(dim);
   this.Minimum      = -inf(dim);
   this.Known        = true(dim);
   this.TypicalValue = zeros(dim);
else
   ctrlMsgUtils.error('SLControllib:modelpack:errEditableDimension')
end
