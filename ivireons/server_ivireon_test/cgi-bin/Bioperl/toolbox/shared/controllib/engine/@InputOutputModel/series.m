function M1 = series(M1,M2,varargin)
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
%   M = SERIES(M1,M2,OUTPUTS1,INPUTS2) connects the input/output models 
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

%	 Clay M. Thompson, Pascal Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%	 $Revision: 1.1.8.2 $  $Date: 2010/04/11 20:36:00 $
ni = nargin;
error(nargchk(2,4,ni));
try
   % Parse inputs
   if ni==2,
      M1 = M2 * M1;  return
   elseif ni==3
      % Named-based IC
      try 
         [~,OutputName1] = getIOName(M1);
         InputName2 = getIOName(M2);
      catch ME
         ctrlMsgUtils.error('Control:lftmodel:nameIC','series')
      end
      [outputs1,inputs2] = InputOutputModel.matchChannelNames(OutputName1,InputName2);
   else
      outputs1 = varargin{1};
      inputs2 = varargin{2};
   end
      
   % Validate indices
   sizes1 = iosize(M1);
   sizes2 = iosize(M2);
   lo = length(outputs1);
   li = length(inputs2);
   if li~=lo,
      ctrlMsgUtils.error('Control:combination:VectorsSameLength','series(M1,M2,OUTPUTS1,INPUTS2)','OUTPUTS1','INPUTS2')
   elseif li>sizes2(2),
      ctrlMsgUtils.error('Control:combination:series1')
   elseif lo>sizes1(1),
      ctrlMsgUtils.error('Control:combination:series2')
   elseif any(inputs2<=0) || any(inputs2>sizes2(2)),
      ctrlMsgUtils.error('Control:general:IndexOutOfRange','series(M1,M2,OUTPUTS1,INPUTS2)','INPUTS2')
   elseif any(outputs1<=0) || any(outputs1>sizes1(1)),
      ctrlMsgUtils.error('Control:general:IndexOutOfRange','series(M1,M2,OUTPUTS1,INPUTS2)','OUTPUTS1')
   end
   
   % Build series interconnection
   M1 = subparen(M2,{':' inputs2}) * subparen(M1,{outputs1 ':'});
catch ME
   throw(ME)
end