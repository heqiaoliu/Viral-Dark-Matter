function B = redistribute(A, destCodistr)
%REDISTRIBUTE Redistribute a codistributed array with another codistributor
%   D2 = REDISTRIBUTE(D1, CODISTR) redistributes a codistributed array D1 to
%   have the distribution scheme CODISTR.
%   
%   Example:
%   spmd
%       N = 1000;
%       M = codistributed(magic(N), codistributor('1d', 2));
%       P = codistributed(pascal(N), codistributor('1d', 1));
%       R = redistribute(P, getCodistributor(M));
%   end
%   
%   See also CODISTRIBUTED, CODISTRIBUTOR/CODISTRIBUTOR.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/10/12 17:29:04 $

error(nargchk(2, 2, nargin, 'struct'));

if ~isa(A, 'codistributed')
    error('distcomp:redistribute:firstInput', ...
          'First argument must be a codistributed array.')
end

if ~isa(destCodistr, 'AbstractCodistributor')
    error('distcomp:redistribute:secondInput', ...
          'REDISTRIBUTE received invalid distribution scheme input of class ''%s''.', ...
          class(destCodistr))
end

LP = getLocalPart(A);
codistr = getCodistributor(A);
[LP, codistr] = distributedutil.Redistributor.redistribute(codistr, LP, destCodistr);
B = codistributed.pDoBuildFromLocalPart(LP, codistr); %#ok<DCUNK>
