function D = utCheckAssignValueSize(D,Value,iodim)
% Checks if value assigned to some @ltidata property (via SET
% or dot assignment) is compatible with the model array size.

%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/02/08 22:46:47 $
nsys = numel(D);
% Sizes of array of values
sva = size(Value);
sva = sva(iodim+1:end);
nv = prod(sva);
% Check compatibility
if nv~=nsys
   if nv~=1 && nsys~=1
      % Error when number of models is different and no scalar
      % expansion interpretation is possible
      ctrlMsgUtils.error('Control:ltiobject:utCheckAssignValueSize1')
   elseif nsys==1
      % Treat setting property of single model to multi-model value
      % as a way to create a model array (scalar expansion along array
      % dimensions)
      D = repmat(D,[sva 1]);
   end
end
