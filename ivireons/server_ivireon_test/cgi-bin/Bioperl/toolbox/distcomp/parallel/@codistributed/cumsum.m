function P = cumsum(varargin)
%CUMSUM Cumulative sum of elements of codistributed array
%   CUMSUM(X)
%   CUMSUM(X,DIM)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.colon(1, N);
%       c = cumsum(D)
%       c1 = cumsum(D,1)
%       c2 = cumsum(D,2)
%   end
%   
%   returns c1 the same as D and c the same as c2.
%   c(1000) = (1+1000)*1000/2 = 500500.
%   
%   See also CUMSUM, CODISTRIBUTED, CODISTRIBUTED/COLON.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:58:39 $

P = codistributed.pCumop(@cumsum,varargin{:});
