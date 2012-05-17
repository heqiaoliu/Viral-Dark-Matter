function s = norm(A,p)
%NORM Matrix or vector norm for codistributed array
%   All norms supported by the built-in function have been overloaded for codistributed arrays.
%   
%   For matrices...
%         N = NORM(D) is the 2-norm of D.
%         N = NORM(D, 2) is the same as NORM(D).
%         N = NORM(D, 1) is the 1-norm of D.
%         N = NORM(D, inf) is the infinity norm of D.
%         N = NORM(D, 'fro') is the Frobenius norm of D.
%         N = NORM(D, P) is available for matrix D only if P is 1, 2, inf or 'fro'.
%    
%   For vectors...
%         N = NORM(D, P) = sum(abs(D).^P)^(1/P).
%         N = NORM(D) = norm(D, 2).
%         N = NORM(D, inf) = max(abs(D)).
%         N = NORM(D, -inf) = min(abs(D)).
%   
%   Example:
%   spmd
%       N = 1000;
%       D = diag(codistributed.colon(1,N))
%       n = norm(D,1)
%   end
%   
%   returns n = 1000.
%   
%   See also NORM, CODISTRIBUTED, CODISTRIBUTED/COLON, CODISTRIBUTED/ZEROS.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.8.2.1 $  $Date: 2010/06/07 13:33:25 $

    if ndims(A) > 2 
        error('distcomp:codistributed:norm:notVectorOrMatrix',...
              'First input must be either a vector or a matrix.')
    end 
    
    if nargin < 2
        p = 2;
    else 
        p = distributedutil.CodistParser.gatherIfCodistributed(p);
        if ~isa(A, 'codistributed')
            % Only the p was codistributed.
            s = norm(A, p);
            return;
        end 
    end 
    
    if ~isaUnderlying(A,'float')
        error('distcomp:codistributed:norm:notSupported', ...
              'NORM is only supported for floating point arrays.');
    end  
    
    if isempty(A)
        s = zeros(1, 1, classUnderlying(A));
        return;
    end 

    if ~iIsValidNorm( p )
        error('distcomp:codistributed:norm:invalidP',...
              'Invalid value for p in call to norm(A, p).');
    end
    
    if isvector(A)
        s = iVectorNorm(A, p);
    else
        s = iMatrixNorm(A, p);
    end
end % End norm

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s = iVectorNorm(A, p)
    switch p
      case 'fro'
        s = gather(sqrt(sum(abs(A).^2)));
      case {inf, 'inf'} 
        s = gather(max(abs(A)));
      case {-inf, '-inf'}
        s = gather(min(abs(A)));            
      otherwise 
        if isfloat(p) 
            s = gather(nthroot(sum(abs(A).^p), p));
        else
            ME=MException(...
                'distcomp:codistributed:norm:vectorNormNotSupport', ...
                  ['The only vector norms available are inf, -inf, ' ... 
                   'and p (a floating point scalar).']);
            throwAsCaller(ME)
        end    
    end
    s = full(s);
end 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s = iMatrixNorm(A, p)
    switch p
      case 1 
        s = gather(max(sum(abs(A),1)));
      case 2
        if issparse(A)
            ME = MException( ...
            'distcomp:codistributed:norm:sparseMat2NormUnsupported', ...
                'Sparse norm(S,2) is not available.');
            throwAsCaller(ME)
        else
            % Ensure svd warning is off when computing the two norm
            oldWarnState = warning('off', ...
                      'distcomp:codistributed:scalaSvd:changeOutputCodistr'); 
            s = gather( max( svd(A) ) );
            % then return it to its previous state
            warning(oldWarnState)
        end 
      case 'fro'      
        LP = getLocalPart(A);
        codistr = getCodistributor(A);
        s = codistr.hFrobeniusNormImpl(LP);  
      case {inf, 'inf'}
        s = gather(max(sum(abs(A),2)));
      otherwise
        ME = MException('distcomp:codistributed:norm:matrixNormNotSupport',...
              'The only matrix norms available are 1, 2, inf, and ''fro''.');
        throwAsCaller(ME)
    end
    s = full(s);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf = iIsValidNorm( p )
    tf = ( isscalar(p) && isnumeric(p) ) || ischar(p);
end
