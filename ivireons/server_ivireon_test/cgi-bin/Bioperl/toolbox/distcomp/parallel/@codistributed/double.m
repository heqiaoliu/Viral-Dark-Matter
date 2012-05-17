function D = double(A)
%DOUBLE Convert codistributed array to double precision
%   Y = DOUBLE(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       Ds = codistributed.ones(N,'single');
%       Dd = double(Ds)
%       classDs = classUnderlying(Ds)
%       classDd = classUnderlying(Dd)
%   end
%   
%   takes the N-by-N codistributed single matrix Ds and converts
%   it to the codistributed double matrix Dd.
%   classDs is 'single' while classDd is 'double'.
%   
%   See also DOUBLE, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2009/03/25 21:58:44 $

D = codistributed.pElementwiseUnaryOp(@double,A);
