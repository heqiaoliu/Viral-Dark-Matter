function varargout = margin(a,b,c,d)
%MARGIN  Gain and phase margins and crossover frequencies.
%
%   [Gm,Pm,Wcg,Wcp] = MARGIN(SYS) computes the gain margin Gm, the phase 
%   margin Pm, and the associated frequencies Wcg and Wcp, for the SISO 
%   open-loop model SYS (continuous or discrete). The gain margin Gm is 
%   defined as 1/G where G is the gain at the -180 phase crossing. The 
%   phase margin Pm is in degrees.  
%
%   The gain margin in dB is derived by 
%      Gm_dB = 20*log10(Gm)
%   The loop gain at Wcg can increase or decrease by this many dBs before 
%   losing stability, and Gm_dB<0 (Gm<1) means that stability is most 
%   sensitive to loop gain reduction.  If there are several crossover 
%   points, MARGIN returns the smallest margins (gain margin nearest to 
%   0dB and phase margin nearest to 0 degrees).
%
%   For a S1-by...-by-Sp array of linear systems, MARGIN returns 
%   arrays of size [S1 ... Sp] such that
%      [Gm(j1,...,jp),Pm(j1,...,jp)] = MARGIN(SYS(:,:,j1,...,jp)) .  
%
%   [Gm,Pm,Wcg,Wcp] = MARGIN(MAG,PHASE,W) derives the gain and phase
%   margins from the Bode magnitude, phase, and frequency vectors 
%   MAG, PHASE, and W produced by BODE. Interpolation is performed 
%   between the frequency points to estimate the values. 
%
%   MARGIN(SYS), by itself, plot the open-loop Bode plot with 
%   the gain and phase margins marked with a vertical line. 
%
%   See also ALLMARGIN, BODEPLOT, BODE, LTIVIEW, DYNAMICSYSTEM.

%Old help
%MARGIN Gain margin, phase margin, and crossover frequencies.
%   [Gm,Pm,Wcg,Wcp] = MARGIN(A,B,C,D) returns gain margin Gm,
%   phase margin Pm, and associated frequencies Wcg and Wcp, given
%   the continuous state-space system (A,B,C,D).
%
%   [Gm,Pm,Wcg,Wcp] = MARGIN(NUM,DEN) returns the gain and phase
%   margins for a system in s-domain transfer function form (NUM,DEN).
%
%   [Gm,Pm,Wcg,Wcp] = MARGIN(MAG,PHASE,W)  returns the gain and phase
%       margins given the Bode magnitude, phase, and frequency vectors 
%   MAG, PHASE, and W from a system.  In this case interpolation is 
%   performed between frequency points to find the values. This works
%   for both continuous and discrete systems.
%
%   When invoked without left hand arguments, MARGIN(A,B,C,D) plots
%   the Bode plot with the gain and phase margins marked with a 
%   vertical line. The gain margin, Gm, is defined as 1/G where G 
%   is the gain at the -180 phase frequency. 
%   20*log10(Gm) gives the gain margin in dB.  
%
%   See also, IMARGIN.

%   Note: if there is more than one crossover point, margin will
%   return the worst case gain and phase margins. 

%   Andrew Grace 12-5-91
%   Revised ACWG 6-21-92
%   Revised A.Potvin 6-1-94
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.17.4.3 $  $Date: 2010/02/08 22:25:00 $

ni = nargin;
no = nargout;
if ni==0,
   eval('exresp(''margin'')')
   return
end
error(nargchk(2,4,ni));

% Validation for MARGIN(MAG,PHASE,W)
if ni==3
   nf = numel(c);  % w
   c = c(:);
   if ~(isnumeric(a) && isnumeric(b) && isnumeric(c)) || ...
         numel(a)~=nf || numel(b)~=nf
      ctrlMsgUtils.error('Control:analysis:margin2','margin');
   elseif ~isreal(c) || any(c<0) || any(diff(c)<=0)
      ctrlMsgUtils.error('Control:analysis:margin3','margin');
   end
end

try
   if no==0,
      switch ni
         case 2
            margin(tf(a,b));
         case 3
            % This code path is NOT obsolete
            imargin(a(:),b(:),c(:));
         case 4
            margin(ss(a,b,c,d));
      end
   else
      switch ni
         case 2
            [varargout{1:no}] = margin(tf(a,b));
         case 3
            % This code path is NOT obsolete
            [varargout{1:no}] = imargin(a(:),b(:),c(:));
         case 4
            [varargout{1:no}] = margin(ss(a,b,c,d));
      end
   end
catch E
   throw(E)
end
