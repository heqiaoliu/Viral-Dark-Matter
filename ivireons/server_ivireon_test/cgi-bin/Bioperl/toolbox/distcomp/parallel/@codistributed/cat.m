function C = cat(catdim,varargin)
%CAT Concatenate codistributed arrays
%   C = CAT(DIM,A,B,...) implements CAT(DIM,A,B,...) for codistributed arrays.
%   If all of A, B, ... are distributed by the DIM-th dimension, so is C.
%   If any of A, B, ... are distributed by some other dimension, so is C.
%   
%   Example:
%   spmd
%       N1 = 500;
%       N2 = 1000;
%       D1 = codistributed.ones(N1,N2);
%       D2 = codistributed.zeros(N1,N2);
%       D3 = cat(1,D1,D2) % D3 is 1000-by-1000
%       D4 = cat(2,D1,D2) % D4 is 500-by-2000
%   end
%   
%   See also CAT, VERTCAT, HORZCAT, CODISTRIBUTED, CODISTRIBUTED/ONES, 
%   CODISTRIBUTED/ZEROS.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2009/05/14 16:50:55 $

catdim = distributedutil.CodistParser.gatherIfCodistributed(catdim);
if ~isscalar(catdim) || ~isPositiveIntegerValuedNumeric(catdim)
    error('distcomp:codistributed:cat:catdimensions', ...
          'DIM must be a positive integer-valued scalar.')
end

% This implementation only supports codistributor1d.
codistributed.pVerifyUsing1d('cat', varargin{:}); %#ok<DCUNK> private static

numArrays = length(varargin);
arrayIsCodist = false(1, length(varargin));
distribdimC = 0;
for k=1:numArrays
    arrayIsCodist(k) = isa(varargin{k}, 'codistributed');
    if distribdimC ==0 && arrayIsCodist(k)
        cDist = getCodistributor(varargin{k});
        distribdimC = cDist.Dimension;
    end
end

if ~any( arrayIsCodist )
    % Must have got here with a codistributed catdim. Short-circuit with a call
    % to default cat. This might error if the arguments to be concatenated
    % are inconsistent.
    C = cat( catdim, varargin{:} );
    return
end


if numArrays > 2
   nh = floor(numArrays/2);
   C = cat(catdim,cat(catdim,varargin{1:nh}),cat(catdim,varargin{nh+1:numArrays}));
   if distribdimC > 0
       C = redistribute(C, codistributor('1d', distribdimC));
   end
   return
elseif numArrays == 1
   C = varargin{1};
   return
end

A = varargin{1};
B = varargin{2};
for d = [1:catdim-1 catdim+1:ndims(A)]
    if size(B,d) ~= size(A,d)
        error('distcomp:codistributed:cat:dimensions', ...
              'Distributed array concatenation dimensions are not consistent.')
    end
end
if ~isa(B, 'codistributed')
    B = codistributed.pConstructFromReplicated(B, codistributor('1d', catdim));  %#ok<DCUNK> Calling a private static method.
end
if ~isa(A, 'codistributed')
    A = codistributed.pConstructFromReplicated(A, codistributor('1d', catdim)); %#ok<DCUNK> Calling a private static method.
end

aDist = getCodistributor(A);
bDist = getCodistributor(B);
if aDist.Dimension ~= catdim
    A = redistribute(A, codistributor('1d', catdim));
    aDist = getCodistributor(A);
end
if bDist.Dimension ~= catdim
    B = redistribute(B, codistributor('1d', catdim));
    bDist = getCodistributor(B);
end
odd = mod(numlabs, 2);
Ap = [aDist.Partition zeros(1, odd)];
Bp = [zeros(1, odd) bDist.Partition];
k = 1:2:(numlabs+odd);
Ap2 = [Ap(k)+Ap(k+1) zeros(1, (numlabs-odd)/2)];
Bp2 = [zeros(1, (numlabs-odd)/2) Bp(k)+Bp(k+1)];
A = redistribute(A, codistributor('1d', catdim, Ap2));
B = redistribute(B, codistributor('1d', catdim, Bp2));

passed = true;
try
    lclprt = cat(catdim,getLocalPart(A), getLocalPart(B));
catch exception
    passed = false;
end
gPassed = gop(@and, passed); % determine if local cat() succeeded

if gPassed
    try
        % creation of codistributed array will communicate so to avoid deadlock
        % the try-catch above assures local cat() succeeded on each lab
        C = codistributed.build(lclprt, codistributor('1d', catdim, Ap2+Bp2), 'obsolete:calculateSize');
    catch exception
        passed = false;
    end
end

if (~gPassed || ~gop(@and, passed))
    if ~passed % failure on this lab
        newEx = MException(exception.identifier, ...
                           ['An error occurred while concatenating local pieces of the ', ...
                            'codistributed array. The original error on this LAB was:\n%s'], ...
                           exception.message);
        throw(newEx);
    else % failure on one other lab
        error('distcomp:codistributed:cat:localCat', ...
              'Local cat() failed on one of the labs.')
    end
end
if distribdimC > 0
    C = redistribute(C, codistributor('1d', distribdimC));
end
