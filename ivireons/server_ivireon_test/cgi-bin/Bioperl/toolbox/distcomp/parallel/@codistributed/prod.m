function P = prod(varargin)
%PROD Product of elements of codistributed array
%   PROD(X)
%   PROD(X,DIM)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = 4 * (codistributed.colon(1, N) .^ 2);
%       D2 = D ./ (D - 1);
%       p = prod(D2)
%   end
%   
%   returns p as approximately pi/2 (by the Wallis product).
%   
%   See also PROD, CODISTRIBUTED, CODISTRIBUTED/COLON, CODISTRIBUTED/ZEROS.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 22:00:06 $

P = codistributed.pReductionOpAlongDim(@prod,varargin{:});
