function varargout = log2(X)
%LOG2 Base 2 logarithm and dissect floating point number of codistributed array
%   Y = LOG2(X)
%   [F,E] = LOG2(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = 2.^codistributed.colon(1, N);
%       E = log2(D)
%   end
%   
%   See also LOG2, CODISTRIBUTED, CODISTRIBUTED/COLON.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/08/11 15:40:39 $
 
xDist = getCodistributor(X);
localX = getLocalPart(X);

exponentLP = xDist.hLog2Impl(localX, nargout);

for i = 1:nargout
    varargout{i} = codistributed.pDoBuildFromLocalPart(exponentLP{i}, xDist); %#ok<DCUNK>
end


