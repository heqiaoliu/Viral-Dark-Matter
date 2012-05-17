function p = sspole(a,e)
%SSPOLE  Computes poles of state-space model.
% 
%   P = SSPOLE(A,E) returns the finite eigenvalues of (A,E).
%
%   For maximum accuracy,
%     * E should be nonsingular (see ssdata/pole for how to enforce this)
%     * (A,E) should be properly scaled in descriptor case
%
%   LOW-LEVEL UTILITY.

%   Author(s): P.Gahinet 
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2006/06/20 20:04:08 $
if isempty(e)
   p = eig(a);
else
   p = eig(a,e);
end
