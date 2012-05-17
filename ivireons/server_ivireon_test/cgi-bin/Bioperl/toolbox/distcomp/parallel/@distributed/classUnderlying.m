function c = classUnderlying( obj )
%classUnderlying Class of elements contained within a distributed array
%   C = classUnderlying(D) returns the name of the class of the elements
%   contained within the distributed array D.
%   
%   Examples:
%       N        = 1000;
%       D_uint8  = distributed.ones(1, N, 'uint8');
%       D_single = distributed.nan(1, N, 'single');
%       c_uint8  = classUnderlying(D_uint8) % returns 'uint8'
%       c_single = classUnderlying(D_single)  % returns 'single'
%   
%   See also CLASS, DISTRIBUTED.


%   Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.6.2 $   $Date: 2009/05/14 16:51:36 $

% Protect against broken distributed.
errorIfInvalid( obj );

c = obj.ClassUnderlying;
end
