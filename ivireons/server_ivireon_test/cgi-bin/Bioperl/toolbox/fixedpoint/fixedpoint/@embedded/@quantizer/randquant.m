function u = randquant(q,varargin)
%RANDQUANT Uniformly distributed quantized random number
%   RANDQUANT(Q,N)
%   RANDQUANT(Q,M,N)
%   RANDQUANT(Q,M,N,P,...)
%   RANDQUANT(Q,[M,N])
%   RANDQUANT(Q,[M,N,P,...])
%
%   Works like RAND except the numbers are quantized and:
%   (1) If Q is a fixed-point quantizer then the numbers cover the
%       range of Q. 
%   (2) If Q is a floating-point quantizer then the numbers cover +- the
%       square-root of the realmax of Q.
%
%   Example:
%     q=quantizer([4 3]);
%     rand('state',0)
%     randquant(q,3)
%   returns
%     0.7500   -0.1250   -0.2500
%    -0.6250    0.6250   -1.0000
%     0.1250    0.3750    0.5000
%
%   See also QUANTIZER, EMBEDDED.QUANTIZER/RANGE, 
%            EMBEDDED.QUANTIZER/REALMAX, RAND

%   Thomas A. Bryan
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2006/12/20 07:14:12 $

u = rand(varargin{:});

switch q.mode
  case {'fixed','ufixed'}
    [a,b]=range(q);
    u = (b-a)*u+a;
  otherwise
    % In floating-point, cover +-sqrt(realmax(q))
    r = sqrt(q.realmax);
    u = r*(2*u-1);
end

u = q.quantizenumeric(u);
