function [a,b,c,d] = feedback(a1,b1,c1,d1,a2,b2,c2,d2,e,f)
%FEEDBACK  Feedback connection of two input/output systems. 
%
%   M = FEEDBACK(M1,M2) computes a closed-loop model M for the feedback loop: 
%
%          u --->O---->[ M1 ]----+---> y
%                |               |           y = M * u
%                +-----[ M2 ]<---+
%
%   Negative feedback is assumed and the model M maps u to y. To apply 
%   positive feedback, use the syntax M = FEEDBACK(M1,M2,+1).
%
%   M = FEEDBACK(M1,M2,FEEDIN,FEEDOUT,SIGN) builds the more general feedback 
%   interconnection:
%
%                      +------+
%          v --------->|      |--------> z
%                      |  M1  |
%          u --->O---->|      |----+---> y
%                |     +------+    |
%                |                 |
%                +-----[  M2  ]<---+
%
%   The vector FEEDIN contains indices into the input vector of M1 and
%   specifies which inputs u are involved in the feedback loop. Similarly, 
%   FEEDOUT specifies which outputs y of M1 are used for feedback. If SIGN=1 
%   then positive feedback is used. If SIGN=-1 or SIGN is omitted, then 
%   negative feedback is used. In all cases, the resulting model M has the 
%   same inputs and outputs as M1 (with their order preserved).
%
%   If M1 and M2 are arrays of models, FEEDBACK returns a model array M of 
%   the same dimensions where 
%      M(:,:,k) = FEEDBACK(M1(:,:,k),M2(:,:,k)) .
%
%   For dynamic systems SYS1 and SYS2, 
%      SYS = FEEDBACK(SYS1,SYS2,'name') 
%   connects SYS1 and SYS2 by matching their I/O names. The I/O names of 
%   SYS1 and SYS2 must be fully defined.
%
%   See also LFT, PARALLEL, SERIES, CONNECT, INPUTOUTPUTMODEL, DYNAMICSYSTEM.

% Old help
%warning(['This calling syntax for ' mfilename ' will not be supported in the future.'])
%FEEDBACK Feedback connection of two systems. 
%              u-->O-->[System1]---+--->y
%                  |               |
%                  +---[System2]<--+
%   [A,B,C,D] = FEEDBACK(A1,B1,C1,D1,A2,B2,C2,D2,SIGN) produces an 
%       aggregate state-space system consisting of the feedback connection
%   of the two systems 1 and 2.  Typically, system 1 is a plant and 
%   system 2 is a compensator.   If SIGN=1 then positive feedback is
%   used. If SIGN=-1 then negative feedback is used.  In all cases, 
%   the resulting system has the same inputs and outputs as system 1.
%
%   [A,B,C,D] = FEEDBACK(A1,B1,C1,D1,A2,B2,C2,D2,INPUTS1,OUTPUTS1) 
%   produces the feedback system formed by feeding all the outputs of
%   system 2 into the inputs of system 1 specified by INPUTS1 and by 
%   feeding the outputs of system 1 specified by OUTPUTS1 into all the
%   inputs of system 2.  Positive feedback is assumed.  To connect 
%   with negative feedback, use negative values in the vector INPUTS1.
%
%   [NUM,DEN] = FEEDBACK(NUM1,DEN1,NUM2,DEN2,SIGN) produces the SISO
%   closed loop system in transfer function form obtained by 
%   connecting the two SISO transfer function systems in feedback 
%   with the sign SIGN.  
%   See also: CLOOP, PARALLEL, SERIES, and CONNECT.

%   Clay M. Thompson 6-26-90
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2010/03/31 18:13:21 $

error(nargchk(4,10,nargin));

% --- Determine which syntax is being used ---
if (nargin == 4)  % T.F. w/o sign -- Assume negative feedback
  [num1,den1] = tfchk(a1,b1); [num2,den2] = tfchk(c1,d1); sgn = -1;
end
if (nargin == 5)  % Transfer function form with sign
  [num1,den1] = tfchk(a1,b1); [num2,den2] = tfchk(c1,d1); sgn = sign(a2);
end

% --- Form Feedback connection of T.F. system ---
if (nargin==4)|(nargin==5)
    a = conv(num1,den2);
    b = conv(den1,den2) - sgn*conv(num1,num2);

elseif (nargin==6) | (nargin==7)
  error('Wrong number of input arguments.');

elseif (nargin >= 8)  % State space systems
  [msg,a1,b1,c1,d1]=abcdchk(a1,b1,c1,d1); error(msg);
  [msg,a2,b2,c2,d2]=abcdchk(a2,b2,c2,d2); error(msg);
  [ny1,nu1] = size(d1);
  [ny2,nu2] = size(d2);
  if (nargin == 8) % systems w/o sign -- assume negative feedback
    inputs1 = -[1:nu1];     outputs1 = [1:ny1];
    inputs2 =  [1:nu2]+nu1; outputs2 = [1:ny2]+ny1; 
  end
  if (nargin == 9) % State space systems with sign
    inputs1 = [1:nu1]*sign(e); outputs1 = [1:ny1];
    inputs2 = [1:nu2]+nu1;     outputs2 = [1:ny2]+ny1;
  end
  if (nargin == 10) % State space systems w/selection vectors
    inputs1 = e;            outputs1 = f;
    inputs2 = [1:nu2]+nu1;  outputs2 = [1:ny2]+ny1;
  end

  % Check sizes
  if (length(outputs1)~=length(inputs2)) | (length(outputs2)~=length(inputs1))
    error('Feedback connection sizes don''t match.'); end

  % --- Form Closed-Loop Feedback System ---
  [a,b,c,d] = append(a1,b1,c1,d1,a2,b2,c2,d2);
  [a,b,c,d] = cloop(a,b,c,d,[outputs1,outputs2],[inputs2,inputs1]); % close loops
  [a,b,c,d] = ssselect(a,b,c,d,[1:nu1],[1:ny1]);
end
