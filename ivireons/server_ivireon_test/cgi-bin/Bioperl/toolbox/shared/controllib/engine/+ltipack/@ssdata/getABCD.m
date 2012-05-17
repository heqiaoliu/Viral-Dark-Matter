function [a,b,c,d] = getABCD(D)
% Returns (A,B,C,D) matrices for explicit realization of 
% proper state-space model. These matrices are computed by:
%   * Setting all internal delays to zero
%   * Extracting a realization with invertible E
%   * Eliminating E to derive explicit state equations.
% An error is thrown if the model is improper or the zero-order
% Pade approximation of internal delays leads to (exactly) singular 
% algebraic loops.
%
% Zeroing the internal delays may result in an ill-conditioned 
% realization so don't use this function for critical computations 
% when internal delays may be present. Instead, use PADE to zero out 
% the delays and work with the resulting model.

%   Copyright 1986-2008 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:31:03 $

% Zero internal delays (order preserving, may error)
D = zeroInternalDelay(D);

% Compute matrices for explicit state-space form
if ~isempty(D.e)
   % Try extracting explicit proper equivalent
   [isProper,D] = isproper(D,'explicit');
   if ~isProper
      ctrlMsgUtils.error('Control:ltiobject:ssdata1')
   end
end
a = D.a;
b = D.b;
c = D.c;
d = D.d;
