function X = gather(D, labTarget)
%GATHER Convert a codistributed array into a replicated array
%   X = GATHER(D) is a replicated array formed from the codistributed array D.
%   
%   X = GATHER(D, LABTARGET) converts a codistributed array D to a variant
%   array X, such that all of the data is contained on lab LABTARGET, and
%   X is a 0-by-0 empty double on all other labs.
%   
%   D = CODISTRIBUTED(GATHER(D), getCodistributor(D)) returns the original
%   codistributed array D.
%   
%   Example:
%   spmd
%      N = 1000;
%      D = codistributed(magic(N));
%      M = gather(D);
%   end
%   
%   returns M = magic(N) on all labs.
%   
%   See also CODISTRIBUTED, GCAT, GOP.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/05/14 16:51:08 $

error(nargchk(1, 2, nargin, 'struct'));

if ~isa(D, 'codistributed')
    error('distcomp:codistributed:gather:firstInput', ...
          'First argument must be a codistributed array.')
end
if nargin == 1
    labTarget = 0;
else
    labTarget = distributedutil.CodistParser.gatherIfCodistributed(labTarget);
    if ~distributedutil.CodistParser.isValidLabindex(labTarget)
        error('distcomp:codistributed:gather:incorrectLabIndex', ...
              ['When provided, the second input argument to GATHER must be ' ...
               'a valid lab index.']);    
    end
end

codistr = getCodistributor(D);
LP = getLocalPart(D);
X = codistr.hGatherImpl(LP, labTarget);
