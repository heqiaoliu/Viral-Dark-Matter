function [a,b,c,d] = parallel(a1,b1,c1,d1,a2,b2,c2,d2,e,f,g,h)
%PARALLEL  Parallel connection of two input/output models.
%
%                          +------+
%            v1 ---------->|      |----------> z1
%                          |  M1  |
%                   u1 +-->|      |---+ y1
%                      |   +------+   |
%             u ------>+              O------> y
%                      |   +------+   |
%                   u2 +-->|      |---+ y2
%                          |  M2  |
%            v2 ---------->|      |----------> z2
%                          +------+
%
%   M = PARALLEL(M1,M2,IN1,IN2,OUT1,OUT2) connects the input/output models  
%   M1 and M2 in parallel. The inputs specified by IN1 and IN2 are connected 
%   and the outputs specified by OUT1 and OUT2 are summed. The resulting 
%   model M maps [v1;u;v2] to [z1;y;z2]. The vectors IN1 and IN2 contain 
%   indices into the input vectors of M1 and M2, respectively, and define 
%   the input channels u1 and u2 in the diagram. Similarly, the vectors 
%   OUT1 and OUT2 contain indexes into the outputs of M1 and M2. 
%
%   If IN1,IN2,OUT1,OUT2 are jointly omitted, PARALLEL forms the standard 
%   parallel interconnection of M1 and M2 and returns M = M1 + M2.
%
%   If M1 and M2 are arrays of models, PARALLEL returns a model array M of
%   the same size where 
%      M(:,:,k) = PARALLEL(M1(:,:,k),M2(:,:,k),IN1,...) .
%
%   For dynamic systems SYS1 and SYS2, 
%      SYS = PARALLEL(SYS1,SYS2,'name') 
%   connects SYS1 and SYS2 by matching their I/O names. All I/O names of  
%   SYS1 and SYS2 must be defined and the matching names appear in SYS in  
%   the same order as in SYS1.  
%
%   See also APPEND, SERIES, FEEDBACK, INPUTOUTPUTMODEL, DYNAMICSYSTEM.

% Old help
%PARALLEL  Parallel connection of two systems.  
%                +-->[System1]--+
%            u-->+              O--->y
%                +-->[System2]--+
%	[A,B,C,D] = PARALLEL(A1,B1,C1,D1,A2,B2,C2,D2)  produces a state-
%	space system consisting of the parallel connection of systems 1 
%	and 2 that connects all the inputs together and sums all the 
%	outputs of the two systems,  Y = Y1 + Y2.
%
%	[A,B,C,D] = PARALLEL(A1,B1,C1,D1,A2,B2,C2,D2,IN1,IN2,OUT1,OUT2) 
%	connects the two systems in parallel such that the inputs 
%	specified by IN1 and IN2 are connected and the outputs specified
%	by OUT1 and OUT2 are summed. The vectors IN1 and IN2 contain 
%	indexes into the input vectors of system 1 and system 2, 
%	respectively.  Similarly, the vectors OUT1 and OUT2 contain 
%	indexes into the outputs of the systems.  The parallel connection
%	is performed by appending the two systems, summing the specified
%	inputs and outputs, and removing the, now redundant, inputs and 
%	outputs of system 2.
%
%	[NUM,DEN] = PARALLEL(NUM1,DEN1,NUM2,DEN2) produces a parallel 
%	connection of the two transfer function systems.
%	See also: CLOOP, FEEDBACK, and SERIES. 

%	Clay M. Thompson 6-27-90
%   Copyright 1986-2009 The MathWorks, Inc.
%	$Revision: 1.1.8.5 $  $Date: 2010/03/31 18:13:30 $

ni = nargin;

switch ni

case 4 
  [num1,den1] = tfchk(a1,b1); [num2,den2] = tfchk(c1,d1);
  [nn,mn] = size(num1);
  for k=1:nn
    a(k,:) = conv(num1(k,:),den2) + conv(num2(k,:),den1);
    b = conv(den1,den2);
  end

case {8 , 12}
  % State space systems 
  [msg,a1,b1,c1,d1]=abcdchk(a1,b1,c1,d1); error(msg);
  [msg,a2,b2,c2,d2]=abcdchk(a2,b2,c2,d2); error(msg);
  [ny1,nu1] = size(d1);
  [ny2,nu2] = size(d2);
  if (ni== 8) 
    % State space systems w/o selection vectors
    inputs1 = [1:nu1];     outputs1 = [1:ny1];
    inputs2 = [1:nu2]+nu1; outputs2 = [1:ny2]+ny1; 
  else
    % State space systems with selection vectors
    inputs1 = e;      outputs1 = g;
    inputs2 = f+nu1;  outputs2 = h+ny1;
  end
  
  % Check sizes
  if (length(inputs1)~=length(inputs2))
     error('Input sizes don''t match.')
  elseif (length(outputs1)~=length(outputs2))
     error('Output sizes don''t match.')
  end

  % --- Parallel Connection ---
  [a,b,c,d] = append(a1,b1,c1,d1,a2,b2,c2,d2);

  % Connect inputs
  if ~isempty(b), b(:,inputs1)=b(:,inputs1)+b(:,inputs2); end
  if ~isempty(d), d(:,inputs1)=d(:,inputs1)+d(:,inputs2); end
 
  % Connect outputs
  if ~isempty(c), c(outputs1,:)=c(outputs1,:)+c(outputs2,:); end
  if ~isempty(d), d(outputs1,:)=d(outputs1,:)+d(outputs2,:); end

  % Delete redundant inputs and outputs
  b(:,inputs2) = [];     d(:,inputs2) =  [];
  c(outputs2,:) = [];    d(outputs2,:) = [];    


otherwise
  error('Wrong number of input arguments for obsolete matrix-based syntax.')

end


% end parallel.m
