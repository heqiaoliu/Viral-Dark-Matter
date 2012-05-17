function varargout = copyobj(varargin)
%COPYOBJ Copy QUANTIZER object
%   Q1 = COPYOBJ(Q) makes a copy of QUANTIZER object Q and returns it in QUANTIZER
%   object Q1.
%
%   [Q1,Q2,...] = COPYOBJ(Qa,Qb,...) copies Qa into Q1, Qb into Q2, etc.
%
%   [Q1,Q2,...] = COPYOBJ(Q) makes multiple copies of the same object.
%
%   Example:
%     Q = quantizer([8 7]);
%     Q1 = copyobj(Q)
%
%   See also QUANTIZER

%   Thomas A. Bryan, 20 January 2000
%   Copyright 1999-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2007/12/10 21:33:12 $


n=max(1,nargout);
if nargin>1 & n~=nargin
  error('quantizer:copyobj:narginNargoutMismatch',...
        ['Number of input and output arguments must match with multiple' ...
         ' inputs.'])
end
wrn = warning('off');
for k=1:n
  q_original = varargin{min(k,nargin)};
  q_copy = copy(q_original);
  varargout{k} = q_copy;
end
warning(wrn)
