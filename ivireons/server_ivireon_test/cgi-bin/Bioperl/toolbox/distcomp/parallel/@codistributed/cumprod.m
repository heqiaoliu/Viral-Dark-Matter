function P = cumprod(varargin)
%CUMPROD Cumulative product of elements of codistributed array
%   CUMPROD(X)
%   CUMPROD(X,DIM)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = 4 * (codistributed.colon(1, N) .^ 2);
%       D2 = D ./ (D - 1);
%       c = cumprod(D2)
%       c1 = cumprod(D2,1)
%       c2 = cumprod(D2,2)
%   end
%   
%   returns c1 the same as D2 and c the same as c2. c(end) is
%   approximately pi/2 (by the Wallis product).
%   
%   See also CUMPROD, CODISTRIBUTED, CODISTRIBUTED/COLON.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:58:38 $

P = codistributed.pCumop(@cumprod,varargin{:});
