function [aout,b,c,d] = pade(T,n)
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

%   Andrew C.W. Grace 8-13-89
%   P. Gahinet   7-22-96, 5-98
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.17.4.7 $  $Date: 2010/02/08 22:25:01 $

%  Reference:  Golub and Van Loan, Matrix Computations, John Hopkins
%              University Press, pp. 557ff.
ni = nargin;
no = nargout;
error(nargchk(1,2,ni,'struct'))

% Compute coefficients
try
   [a,b] = padecoef(T,n);
catch E
   throw(E);
end

if no==0,
   % Graphical Output if no left hand arguments (step response and Bode plot)
   if T==0,
      ctrlMsgUtils.warning('Control:analysis:PadeZeroDelay')
      return
   end
   clf, subplot(211)
   t1 = 0:T/100:2*T;
   y1 = step(a,b,t1);
   t2 = sort([t1 T*(1-10*eps)]);
   plot(t1,y1,'b-',t2,(t2>=T),'r--')
   legend('Pade approximation','Pure delay','Location','SouthEast')
   xlabel('Time (s)')
   ylabel('Amplitude')
   title(sprintf('Pade approximation of order %d: step response comparison',n))
   
   % Get frequency Wc where phase error becomes significant
   wc = log10(2*pi/T);        % initial guess
   w = logspace(wc-1,wc+3,50);
   fr = polyval(a,1i*w)./polyval(b,1i*w);
   phase = unwrap(atan2(imag(fr),real(fr)));
   phase0 = -w*T;               % exact phase shift
   idiff = find(abs(phase-phase0) > 0.1*abs(phase));
   wc = w(idiff(1));
   lwc = floor(log10(wc));
   if wc/10^lwc<5,  
      wc = lwc;  
   else  
      wc = lwc+1;  
   end
   
   % Get detailed phase profile around Wc
   w = logspace(wc-1,wc+1,100);
   fr = polyval(a,1i*w)./polyval(b,1i*w);
   phase1 = (180/pi)*unwrap(atan2(imag(fr),real(fr)));
   phase2 = -(180/pi)*w*T;    
   subplot(212)
   semilogx(w,phase1,'b',w,phase2,'r--')
   
   % Adjust y scale and set title
   if n ~= 0
      ylim = get(gca,'ylim');
      set(gca,'ylim',[max(ylim(1),2*min(phase1)), ylim(2)])
   end
   xlabel('Frequency (rad/s)')
   ylabel('Phase (degree)')
   title('Phase response comparison')
   
elseif no<=2,
   % Return NUM and DEN
   aout = a;
   
elseif no==3,
   % Return Z,P,K
   c = a(1)/b(1);
   aout = roots(a);
   b = roots(b);
   
else
   % Return A,B,C,D
   [aout,b,c,d] = compreal(a,b);
end
