function [varargout]=stats(obj)
%ProbDistUnivParam/STATS Mean and variance of distribution.
%    [M,V] = STATS(OBJ) returns the mean M and variance V for the
%    distribution defined by the probability distribution object OBJ.
%
%    See also ProbDist, ProbDistUnivParam, MEAN, VAR.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:19:41 $

if nargout>2
    error('stats:ProbDistUnivParam:stats:TooManyOutputs','Too many output arguments.');
end

F = obj.statfunc;
if isempty(F)
    error('stats:ProbDistUnivParam:stats:Undefined',...
          'No STATS function is defined for this distribution.');
end

% Call as efficiently as possible for 1- and 2-parameter distributions
p = obj.Params;
if isscalar(p)
    [varargout{1:max(1,nargout)}] = F(p);
elseif numel(p)==2
    [varargout{1:max(1,nargout)}] = F(p(1),p(2));
else
    pc = num2cell(p);
    [varargout{1:max(1,nargout)}] = F(pc{:});
end
