function Z = all(varargin)
%ALL True if all elements of a codistributed vector are nonzero
%   A = ALL(D)
%   A = ALL(D,DIM)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.colon(1,N)
%       t = all(D)
%   end
%   
%   returns t the codistributed logical scalar with value true.
%   
%   See also ALL, CODISTRIBUTED, CODISTRIBUTED/COLON, CODISTRIBUTED/ZEROS.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:57:51 $

Z = codistributed.pReductionOpAlongDim(@all,varargin{:});
