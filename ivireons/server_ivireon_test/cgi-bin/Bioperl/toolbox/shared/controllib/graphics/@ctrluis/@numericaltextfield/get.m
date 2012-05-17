function result = get(this,varargin)
% GET  method to get object properties
%
 
% Author(s): A. Stothert 17-Mar-2006
% Copyright 2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:16:46 $

nResult = numel(varargin);
if nResult > 1
   result  = cell(nResult,1);
   for ct = 1:nResult
      result{ct} = findProp(this,varargin{ct});
   end
else
   result = findProp(this,varargin{1});
end

