function sys1 = times(sys1,sys2)
%TIMES  Multiplies two dynamic systems I/O-pairwise.
%
%   SYS = TIMES(SYS1,SYS2) performs SYS = SYS1 .* SYS2. This operation
%   amounts to an element-by-element multiplication of the transfer
%   functions of the dynamic systems SYS1 and SYS2.
%
%   If SYS1 and SYS2 are arrays of dynamic systems, their .* product is a
%   system array SYS with the same number of models where the k-th system
%   is obtained by
%      SYS(:,:,k) = SYS1(:,:,k) .* SYS2(:,:,k)
%
%   See also DYNAMICSYSTEM/MTIMES, SERIES, DYNAMICSYSTEM.

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/03/31 18:37:11 $
try
   if ltipack.hasMatchingType('times',sys1,sys2)
      % All operands are of the same type      
      % Check I/O dimensions and handle scalar multiplication
      sizes1 = sys1.IOSize_;
      sizes2 = sys2.IOSize_;
      ScalarFlags = false(1,2);
      if all(sizes1(1:2)==1) && any(sizes2(1:2)~=1),
         % SYS1 is scalar
         if any(sizes2==0),
            % Scalar * Empty = Empty
            sys1 = sys2;   return
         else
            ScalarFlags(1) = true;
         end
      elseif all(sizes2(1:2)==1) && any(sizes1(1:2)~=1),
         % SYS2 is scalar
         if any(sizes1==0),
            % Scalar * Empty = Empty
            return
         else
            ScalarFlags(2) = true;
         end
      elseif ~any(ScalarFlags) && (sizes1(1)~=sizes2(1) || sizes1(2)~=sizes2(2))
         ctrlMsgUtils.error('Control:combination:IncompatibleIODims')
      end
      
      % Combine data
      sys1 = times_(sys1,sys2,ScalarFlags);% overloadable since sys1,sys2 are of the same class
      
      % Combine metadata
      if any(ScalarFlags)
         % Scalar multiplication: keep SYS2's metadata if SYS is scalar
         if ScalarFlags(1)
            sys1 = copyMetaData(sys2,sys1);
            sys1.IOSize_ = sys2.IOSize_;
         end
      else
         sys1.TimeUnit_ = DynamicSystem.resolveTimeUnit(sys1.TimeUnit_,sys2.TimeUnit_);
         sys1 = plusInput(sys1,sys2);
         sys1 = plusOutput(sys1,sys2);
         sys1.Name_ = [];  sys1.Notes_ = [];  sys1.UserData = [];
      end
   else
      % Harmonize types and try again
      [sys1,sys2] = ltipack.matchType('times',sys1,sys2);
      sys1 = times(sys1,sys2);
   end
catch E
   throw(E)
end

