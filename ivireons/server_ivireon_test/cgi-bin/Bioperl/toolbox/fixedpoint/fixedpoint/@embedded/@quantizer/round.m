function x = round(q,x)
%ROUND  Round using quantizer, but do not check for overflow
%   ROUND(Q,X) uses the round mode and fraction length of quantizer Q to
%   round the numeric data X, but does not check for overflow.  Compare
%   to QUANTIZER/QUANTIZE.
%
%   Example:
%     warning on
%     q = quantizer('fixed', 'convergent', 'wrap', [3 2]);
%     x = (-2:eps(q)/4:2)';
%     y = round(q,x);
%     plot(x,[x,y],'.-'); axis square
%
%   See also QUANTIZER, EMBEDDED.QUANTIZER/QUANTIZE

%   Thomas A. Bryan
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2006/12/20 07:14:17 $

switch q.mode
 case {'double', 'none'}
  % No operation on 'double' or 'none'
 otherwise
  % Round everything else
  p = pow2(q.fractionlength);
  rmode = q.roundmode;
  % round   == MATLAB's round:    round ties toward max abs.
  % nearest == fixed-point round: round ties toward +inf.
  % fix, floor, ceil == MATLAB's fix, floor, ceil.
  % convergent == round to nearest: round ties to nearest even integer.
  x = feval(rmode,p*x)/p;
end
