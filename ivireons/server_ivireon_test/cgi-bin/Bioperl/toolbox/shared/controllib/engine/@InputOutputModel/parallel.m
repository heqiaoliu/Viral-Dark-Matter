function M1 = parallel(M1,M2,inp1,inp2,out1,out2)
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

%	 Clay M. Thompson 6-27-90, Pascal Gahinet, 4-15-96
%   Copyright 1986-2010 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2010/03/31 18:37:31 $
ni = nargin;
error(nargchk(2,6,ni));
try
   % Parse inputs
   if ni==2,
      M1 = M1 + M2;  return
   elseif ni==3
      % Named-based IC
      try 
         [InputName1,OutputName1] = getIOName(M1);
         [InputName2,OutputName2] = getIOName(M2);
      catch ME
         ctrlMsgUtils.error('Control:lftmodel:nameIC','parallel')
      end
      [inp1,inp2] = InputOutputModel.matchChannelNames(InputName1,InputName2);
      [out1,out2] = InputOutputModel.matchChannelNames(OutputName1,OutputName2);
      % Sort index vectors so that inp1 and out1 are monotonic
      % (keep SYS1 ordering for matching names)
      [inp1,is] = sort(inp1);  inp2 = inp2(is);
      [out1,is] = sort(out1);  out2 = out2(is);
   elseif ni~=6
      ctrlMsgUtils.error('Control:combination:parallel1')
   end
   
   % Validate indices
   [p1,m1] = iosize(M1);
   [p2,m2] = iosize(M2);
   li1 = length(inp1); inp1 = reshape(inp1,1,li1);
   li2 = length(inp2); inp2 = reshape(inp2,1,li2);
   lo1 = length(out1); out1 = reshape(out1,1,lo1);
   lo2 = length(out2); out2 = reshape(out2,1,lo2);
   if li1~=li2,
      ctrlMsgUtils.error('Control:combination:VectorsSameLength','parallel(M1,M2,IN1,IN2,OUT1,OUT2)','IN1','IN2')
   elseif lo1~=lo2,
      ctrlMsgUtils.error('Control:combination:VectorsSameLength','parallel(M1,M2,IN1,IN2,OUT1,OUT2)','OUT1','OUT2')
   elseif any(inp1<=0) || any(inp1>m1),
      ctrlMsgUtils.error('Control:general:IndexOutOfRange','parallel(M1,M2,IN1,IN2,OUT1,OUT2)','IN1')
   elseif any(inp2<=0) || any(inp2>m2),
      ctrlMsgUtils.error('Control:general:IndexOutOfRange','parallel(M1,M2,IN1,IN2,OUT1,OUT2)','IN2')
   elseif any(out1<=0) || any(out1>p1),
      ctrlMsgUtils.error('Control:general:IndexOutOfRange','parallel(M1,M2,IN1,IN2,OUT1,OUT2)','OUT1')
   elseif any(out2<=0) || any(out2>p2),
      ctrlMsgUtils.error('Control:general:IndexOutOfRange','parallel(M1,M2,IN1,IN2,OUT1,OUT2)','OUT2')
   end
   
   % Build parallel interconnection
   iv1 = 1:m1;   iv1(inp1) = [];
   iz1 = 1:p1;   iz1(out1) = [];
   iv2 = 1:m2;   iv2(inp2) = [];
   iz2 = 1:p2;   iz2(out2) = [];
   M1 = subparen(M1,{[iz1,out1],[iv1,inp1]});
   M2 = subparen(M2,{[out2,iz2],[inp2,iv2]});
   % Reevaluate sizes in case of repeated indices
   [p1,m1] = iosize(M1);
   [p2,m2] = iosize(M2);
   M1 = append(M1,zeros(p2-lo2,m2-li2)) + append(zeros(p1-lo1,m1-li1),M2);
catch ME
   throw(ME)
end