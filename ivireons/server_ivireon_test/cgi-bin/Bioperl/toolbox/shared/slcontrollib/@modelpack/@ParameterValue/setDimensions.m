function setDimensions(this,dim) 
% SETDIMENSIONS set the dimension of the value specified by the parameter
% value object. Setting the dimension will also reset the value property to
% zero.
%
% this.setDimension(dim)
%
% Input
%   dim - a row vector with the dimension 
 
 
% Author(s): A. Stothert 05-Nov-2007
% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2007/12/14 15:01:36 $

if ~(isnumeric(dim) && size(dim,1)==1 && ndims(dim) == 2 && numel(dim) > 1)
   ctrlMsgUtils.error('SLControllib:modelpack:errDimension')
end

if this.isDimensionEditable
   this.Dimension = dim;
   this.Value     = zeros(dim);
else
   ctrlMsgUtils.error('SLControllib:modelpack:errEditableDimension')
end