function varargout = max(varargin)
%MAX Largest component of codistributed array
%   Y = MAX(X)
%   [Y,I] = MAX(X)
%   [Y,I] = MAX(X,[],DIM)
%   Z = MAX(X,Y)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed(magic(N))
%       m = max(D)
%       m1 = max(D,[],1)
%       m2 = max(D,[],2)
%   end
%   
%   m and m1 are both codistributed row vectors, m2 is a codistributed column 
%   vector.
%   
%   See also MAX, CODISTRIBUTED, CODISTRIBUTED/COLON, CODISTRIBUTED/ZEROS.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/12/29 01:59:01 $

[varargout{1:nargout}] = minmaxop(@max,varargin{:});
