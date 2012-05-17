function r=random(pd,varargin)
%RANDOM Random number generation for piecewise distribution.
%    R=RANDOM(OBJ) generates a pseudo-random number R drawn from the
%    piecewise distribution object OBJ.
%
%    R=RANDOM(OBJ,N) generates an N-by-N matrix.  RANDOM(OBJ,M,N) or
%    RANDOM(OBJ,[M,N]) generates an M-by-N matrix.  RANDOM(OBJ,M,N,P,...) or
%    RANDOM(OBJ,[M,N,P,...]) generates an M-by-N-by-P-by-... array.
%
%    See also PIECEWISEDISTRIBUTION, PIECEWISEDISTRIBUTION/CDF, PIECEWISEDISTRIBUTION/ICDF.

%   Copyright 2006-2007 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2010/03/16 00:21:07 $

% Start with uniform random variable to determine the segment    
u = rand(varargin{:});
r = zeros(size(u));

% Determine the segment that each point occupies
s = segment(pd,[],u);

% Invoke the appropriate random number generator for each segment
for j=1:max(s(:))
    t = (s==j);
    if any(t(:))
        fun = pd.distribution(j).random;
        if isempty(fun)
            r(t) = pd.distribution(j).icdf(u(t));
        else
            sz = [sum(t(:)),1];
            r(t) = fun(sz);
        end
    end
end
