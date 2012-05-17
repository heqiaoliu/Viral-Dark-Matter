function varargout = min(varargin)
%MIN Smallest component of codistributed array
%   Y = MIN(X)
%   [Y,I] = MIN(X)
%   [Y,I] = MIN(X,[],DIM)
%   Z = MIN(X,Y)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed(magic(N))
%       m = min(D)
%       m1 = min(D,[],1)
%       m2 = min(D,[],2)
%   end
%   
%   m and m1 are both codistributed row vectors, m2 is a codistributed column 
%   vector.
%   
%   See also MIN, CODISTRIBUTED, CODISTRIBUTED/COLON, CODISTRIBUTED/ZEROS.
%   


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/12/29 01:59:02 $

[varargout{1:nargout}] = minmaxop(@min,varargin{:});
