function sys = pade(sys,Ni,No,Nf)
%PADE  Pade approximation of time delays.
%
%   [NUM,DEN] = PADE(T,N) returns the Nth-order Pade approximation 
%   of the continuous-time delay exp(-T*s) in transfer function form.
%   The row vectors NUM and DEN contain the polynomial coefficients  
%   in descending powers of s.
%
%   When invoked without left-hand argument, PADE(T,N) plots the
%   step and phase responses of the N-th order Pade approximation 
%   and compares them with the exact responses of the time delay
%   (Note: the Pade approximation has unit gain at all frequencies).
%
%   SYSX = PADE(SYS,N) returns a delay-free approximation SYSX of 
%   the continuous-time delay system SYS by replacing all delays 
%   by their Nth-order Pade approximation.  The default is N=1.
%
%   SYSX = PADE(SYS,NU,NY,NINT) specifies independent approximation
%   orders for each input, output, and I/O or internal delay.  
%   Here NU, NY, and NINT are integer arrays such that
%     * NU is the vector of approximation orders for the input channels
%     * NY is the vector of approximation orders for the output channels
%     * NINT are the approximation orders for the I/O delays (TF or
%       ZPK models) or internal delays (state-space models)
%   You can use scalar values for NU, NY, or NINT to specify a uniform 
%   approximation order.  You can also set some entries of NU, NY, or 
%   NINT to Inf to prevent approximation of the corresponding delays.
%
%   See also DELAY2Z, C2D, LTI.

%   Author(s): Andrew C.W. Grace, P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:49:17 $

%  Reference:  Golub and Van Loan, Matrix Computations, John Hopkins
%              University Press, pp. 557ff.
ni = nargin;
error(nargchk(1,4,ni))
switch ni
case 1
   Ni = 1;  No = 1;  Nf = 1;
case 2
   if isscalar(Ni)
      % Uniform approximation
      No = Ni;  Nf = Ni;
   else
      % Old syntax
      No = Inf;  Nf = Inf;
   end
case 3
   Nf = Inf;
end  

% Map [] to Inf
if isempty(Ni)
   Ni = Inf;
end
if isempty(No)
   No = Inf;
end
if isempty(Nf)
   Nf = Inf;
end

try
   if isct_(sys)
      sys = pade_(sys,Ni,No,Nf);
   else
      % Use DELAY2Z for discrete models
      if ~isa(sys,'FRDModel')
         ctrlMsgUtils.warning('Control:transformation:PadeDiscrete')
      end
      sys = delay2z(sys);
   end
catch E
   ltipack.throw(E,'command','pade',class(sys))
end
