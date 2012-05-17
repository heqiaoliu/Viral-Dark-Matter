function d = arraydescriptor(A)
%ARRAYDESCRIPTOR                 Private utility function for parallel

% Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2010/04/21 21:14:40 $

error(nargchk(1, 1, nargin, 'struct'));

if ~isa(A, 'codistributed')
    error('distcomp:util:arraydescriptor:invalidInput', ...
          'Input matrix must be codistributed.');
end
   
distA = getCodistributor(A);

if ~isa(distA, 'codistributor2dbc')
    error('distcomp:util:arraydescriptor:invalidInputCodist', ...
          'Input matrix must be distributed according to the ''codistributor2dbc'' scheme.');
end

% Construct the array descriptor
% Note: The block size is always square
DTYPE = 1;               % Block cyclic 2D: 1 for dense matrix
CTXT  = NaN;             % BLACS context to be determined
M     = size(A, 1);      % No. of rows of the distributed array
N     = size(A, 2);      % No. of columns of the distributed array
MB    = distA.BlockSize; % Row block size
NB    = distA.BlockSize; % Column Block size
RSRC  = 0;               % Zero-base. First process row where the first 
                         % row of the distributed array is located
CSRC  = 0;               % Zero-base. First process column where the first 
                         % column of the distributed array is located
LLD   = max( 1, size(getLocalPart(A), 1) );  % Leading dimension of the 
                                             % local array, LLD >= 1.

d = [DTYPE CTXT M N MB NB RSRC CSRC LLD];
