function L = getLocalPart(D)
%getLocalPart Get local portion of a codistributed array
%   L = getLocalPart(D) returns the local portion of a codistributed array D.
%   The format of the local part depends on the distribution scheme of D.
%   
%   Example:
%   spmd
%     % With numlabs = 4
%     D = eye(4, codistributor1d(1))
%     L = getLocalPart(D)
%   end
%   
%     returns
%   
%     Lab 1: L = [1 0 0 0]
%     Lab 2: L = [0 1 0 0]
%     Lab 3: L = [0 0 1 0]
%     Lab 4: L = [0 0 0 1]
%   
%   See also CODISTRIBUTED/GETCODISTRIBUTOR, CODISTRIBUTOR, CODISTRIBUTOR1D, 
%   CODISTRIBUTOR2DBC, CODISTRIBUTED/GLOBALINDICES.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/03/25 21:59:03 $

L = D.Local;
