function y = random(obj,varargin)
%RANDOM Random number generation. 
%   Y = RANDOM(PD) generates a random number drawn from the
%   probability distribution PD.
%
%   Y = RANDOM(PD,N) generates an N-by-N array Y of random numbers.
%
%   Y = RANDOM(PD,N,M,...) or Y=RANDOM(PD,[N,M,...]) generates an
%   N-by-M-by-... array of random numbers.
%
%   See also ProbDist, ProbDistUnivParam, RANDOM.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:19:26 $

p = obj.Params;
F = obj.randfunc;

if isempty(F)
    % Compute by inverting the cdf if necessary
    u = rand(varargin{:});
    y = icdf(obj,u);
else
    % Otherwise call efficiently for 1- or 2-parameter functions
    if isscalar(p)
        y = F(p,varargin{:});
    elseif numel(p)==2
        y = F(p(1),p(2),varargin{:});
    else
        pc = num2cell(p);
        y = F(pc{:},varargin{:});
    end
end
