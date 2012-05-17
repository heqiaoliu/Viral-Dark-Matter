function [a,b,c,d] = series(a1,b1,c1,d1,a2,b2,c2,d2,e,f)
%SERIES  Series connection of two input/output models.
%
%                                  +------+
%                           v2 --->|      |
%                  +------+        |  M2  |-----> y2
%                  |      |------->|      |
%         u1 ----->|      |y1   u2 +------+
%                  |  M1  |
%                  |      |---> z1
%                  +------+
%
%   M = SERIES(M1,M2,OUTPUTS1,INPUTS2) connects the input/ouput models 
%   M1 and M2 in series. The vectors of indices OUTPUTS1 and INPUTS2 
%   specify which outputs of M1 and which inputs of M2 are connected 
%   together. The resulting model M maps u1 to y2.
%
%   If OUTPUTS1 and INPUTS2 are omitted, SERIES connects M1 and M2
%   in cascade and returns M = M2 * M1.
%
%   If M1 and M2 are arrays of models, SERIES returns a model array M of 
%   the same size where 
%      M(:,:,k) = SERIES(M1(:,:,k),M2(:,:,k),OUTPUTS1,INPUTS2) .
%
%   For dynamic systems SYS1 and SYS2, 
%      SYS = SERIES(SYS1,SYS2,'name')
%   connects SYS1 and SYS2 by matching their I/O names. The output names 
%   of SYS1 and input names of SYS2 should be fully defined.
%
%   See also APPEND, PARALLEL, FEEDBACK, INPUTOUTPUTMODEL, DYNAMICSYSTEM.

% Old help
%SERIES Series connection of two systems.  
%
%       u --->[System1]--->[System2]----> y
%
%   [A,B,C,D] = SERIES(A1,B1,C1,D1,A2,B2,C2,D2) produces an aggregate
%   state-space system consisting of the series connection of systems
%   1 and 2 that connects all the outputs of system 1 connected to 
%   all the inputs of system 2, u2 = y1.  The resulting system has 
%   the inputs of system 1 and the outputs of system 2.
%
%   [A,B,C,D] = SERIES(A1,B1,C1,D1,A2,B2,C2,D2,OUTPUTS1,INPUTS2) 
%   connects the two system in series such that the outputs of system
%   1 specified by OUTPUTS1 are connected to the inputs of system 2 
%   specified by INPUTS2.  The vectors OUTPUTS1 and INPUTS2 contain 
%   indexes into the output and inputs of system 1 and system 2 
%   respectively.
% 
%   [NUM,DEN] = SERIES(NUM1,DEN1,NUM2,DEN2) produces the SISO system
%   in transfer function form obtained by connecting the two SISO 
%   transfer function systems in series.
%
%   See also: APPEND,PARALLEL,FEEDBACK and CLOOP.

%   Clay M. Thompson 6-29-90
%   Revised: Pascal 4-29-97
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2010/03/31 18:13:33 $


switch nargin

case 4,   
  % Form Series connection of T.F. system
  [num1,den1] = tfchk(a1,b1); 
  [num2,den2] = tfchk(c1,d1);
  a = conv(num1,num2);
  b = conv(den1,den2);

case {8 , 10}  
  % State space systems 
  [msg,a1,b1,c1,d1]=abcdchk(a1,b1,c1,d1); error(msg);
  nx1 = size(a1,1);
  [ny1,nu1] = size(d1);

  [msg,a2,b2,c2,d2]=abcdchk(a2,b2,c2,d2); error(msg);
  nx2 = size(a2,1);
  [ny2,nu2] = size(d2);

  % Default values for range selectors E and F
  if nargin==8,
     e = 1:ny1;   f = 1:nu2;
  end

  % Check sizes
  if length(e)~=length(f)
     error('Series connection sizes don''t match.')
  end

  % Form state-space matrices of resulting system
  a = [a2 , b2(:,f) * c1(e,:) ; zeros(nx1,nx2) , a1];
  b = [b2(:,f) * d1(e,:) ; b1];
  c = [c2 , d2(:,f) * c1(e,:)];
  d = d2(:,f) * d1(e,:);

otherwise
  error('Wrong number of input arguments for obsolete matrix-based syntax.')

end

  
% end series
