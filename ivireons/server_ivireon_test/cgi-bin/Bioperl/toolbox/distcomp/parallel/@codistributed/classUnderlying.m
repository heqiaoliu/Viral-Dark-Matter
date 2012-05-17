function clz = classUnderlying( obj )
%classUnderlying Class of elements contained within a codistributed array
%   C = classUnderlying(D) returns the name of the class of the elements
%   contained within the codistributed array D.
%   
%   Examples:
%   spmd
%       N        = 1000;
%       D_uint8  = codistributed.ones(1, N, 'uint8');
%       D_single = codistributed.nan(1, N, 'single');
%       c_uint8  = classUnderlying(D_uint8) % returns 'uint8'
%       c_single = classUnderlying(D_single)  % returns 'single'
%   end
%   
%   See also CLASS, CODISTRIBUTED.


%   Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.6.2 $   $Date: 2009/08/11 15:40:33 $
    
    objDist = getCodistributor(obj);
    localObj = getLocalPart(obj);
    
    % call hidden implementation
    clz = objDist.hClassUnderlyingImpl(localObj);
end
