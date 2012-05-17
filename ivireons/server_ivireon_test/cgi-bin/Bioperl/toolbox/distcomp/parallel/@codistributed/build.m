function D = build(L, dist, commFlag)
%CODISTRIBUTED.BUILD    Build a codistributed array from local parts
%   D = CODISTRIBUTED.BUILD(L, CODISTR) builds a codistributed array with
%   getLocalPart(D) = L.  The distribution scheme of D is specified by CODISTR.
%   Global error checking ensures that the local parts conform with the
%   specified distribution scheme.  CODISTR must be complete, which can be 
%   checked by calling CODISTR.isComplete().
%   
%   D = CODISTRIBUTED.BUILD(L, CODISTR, 'noCommunication') builds a
%   codistributed array, without performing communications.  CODISTR must
%   be complete, which can be checked by calling CODISTR.isComplete().
%   
%   The requirements on the size and structure of the local part L depend on
%   the class of CODISTR.  For the 1D and 2D block-cyclic codistributors, L
%   must have the same class and sparsity on all labs.  Furthermore, the local
%   part L must represent the region described by globalIndices method on
%   CODISTR.
%   
%   Example: 
%   % Create a codistributed array of size 1001-by-1001 such that column
%   % ii contains the value ii.
%   spmd
%       N = 1001;
%       globalSize = [N, N];
%       % Let the matrix be distributed over the second dimension, columns, and
%       % let the codistributor derive the partition from the global size.
%       codistr = codistributor1d(2, codistributor1d.unsetPartition, globalSize)
%   
%       % On 4 labs, codistr.Partition equals [251, 250, 250, 250].
%       % Allocate storage for the local part.
%       localSize = [N, codistr.Partition(labindex)];
%       L = zeros(localSize);
%   
%       % Use globalIndices to map the indices of the columns of the local part
%       % into the global column indices.  
%       globalInd = codistr.globalIndices(2); 
%       % On 4 labs, globalInd has the values:
%       % 1:251    on lab 1
%       % 252:501  on lab 2
%       % 502:751  on lab 3
%       % 752:1001 on lab 4
%   
%       % Initialize the columns of the local part to the correct value.
%       for localCol = 1:length(globalInd)
%           globalCol = globalInd(localCol);
%           L(:, localCol) = globalCol;
%       end
%       D = codistributed.build(L, codistr)
%   end
%   
%   See also CODISTRIBUTED, CODISTRIBUTED/ONES, CODISTRIBUTED/ZEROS, 
%   CODISTRIBUTOR, CODISTRIBUTOR1D/globalIndices, CODISTRIBUTOR2DBC/globalIndices


%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/05/14 16:50:53 $

codistributed.pDeployedCheck(); %#ok<DCUNK> private static method
mpiInit;
error(nargchk(2, 3, nargin, 'struct'));

if ~isa(dist, 'AbstractCodistributor')
    error('distcomp:codistributed:build:InvalidDist', ...
          'Second input argument must be a codistributor object.');
end

% Disambiguate between:
% codistributed.build(LP, codistr)
% codistributed.build(LP, codistr, 'noCommunication')
% as well as the use of the undocumented flags.

% We always error check unless otherwise specified.
buildOption = distributedutil.BuildOption.CommunicationAllowed;
if nargin >= 3
    err = false;
    if ischar(commFlag) 
        switch commFlag
            case 'noCommunication'
                buildOption = distributedutil.BuildOption.NoCommunication;
            case 'obsolete:calculateSize'
                buildOption = distributedutil.BuildOption.CalculateSize;
            case 'obsolete:matchLocalParts'
                buildOption = distributedutil.BuildOption.MatchLocalParts;
          otherwise
            err = true;
        end
    else
        err = true;
    end
    if err
        % Only mention documented options in error message.
        error('distcomp:codistributed:badCommFlag', ...
              'If present, third input argument must be ''noCommunication''');
    end
        
end

legacyAPI = (buildOption == distributedutil.BuildOption.CalculateSize ...
             || buildOption == distributedutil.BuildOption.MatchLocalParts);
if ~legacyAPI && ~dist.isComplete()
    error('distcomp:codistributed:buildFromIncomplete', ...
          ['The codistributor must be complete for building '...
          'a codistributed array from local parts.']);
end

% Defer to codistributor to perform error checking and to return a codistributor
% with all cached data set correctly.
dist = dist.hBuildFromLocalPartImpl(L, buildOption);

D = codistributed.pDoBuildFromLocalPart(L, dist); %#ok<DCUNK> private static method
