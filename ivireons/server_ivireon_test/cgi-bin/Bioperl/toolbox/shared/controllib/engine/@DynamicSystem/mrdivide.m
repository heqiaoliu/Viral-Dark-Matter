function sys1 = mrdivide(sys1,sys2)
%MRDIVIDE  Right division for dynamic systems.
%
%   SYS = MRDIVIDE(SYS1,SYS2) is invoked by SYS=SYS1/SYS2.
%   and is equivalent to SYS = SYS1*INV(SYS2).
%
%   See also DYNAMICSYSTEM/MLDIVIDE, DYNAMICSYSTEM/INV, DYNAMICSYSTEM/MTIMES.

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/03/31 18:36:49 $
try
   if isnumeric(sys2) && ~sys1.isCombinable('mtimes')
      % Bypass for SYS1/DOUBLE with SYS1 atomic (e.g., @pid/5)
      sys1 = sys1.rightMultiplyByNumeric(inv(sys2));
      
   elseif ltipack.hasMatchingType('mtimes',sys1,sys2)
      % All operands are of the same type
      % Size checking
      ios1 = sys1.IOSize_;
      ios2 = sys2.IOSize_;
      ScalarFlags = [all(ios1==1) all(ios2==1)];
      if ios2(1)~=ios2(2)
         ctrlMsgUtils.error('Control:combination:divide2','SYS1/SYS2','SYS2')
      elseif ios1(2)~=ios2(1) && ~any(ScalarFlags)
         ctrlMsgUtils.error('Control:combination:IncompatibleIODims')
      end
      
      if (ScalarFlags(1) && ios2(1)~=1) || (ScalarFlags(2) && ios1(2)~=1)
         % Scalar expansion needed: handle through MTIMES
         sys1 = sys1*inv(sys2); %#ok<*MINV>
      else
         % Combine data
         sys1 = mrdivide_(sys1,sys2);
         % Combine metadata
         sys1.TimeUnit_ = DynamicSystem.resolveTimeUnit(sys1.TimeUnit_,sys2.TimeUnit_);
         sys1.InputName_ = sys2.OutputName_;
         sys1.InputUnit_ = sys2.OutputUnit_;
         sys1.InputGroup_ = sys2.OutputGroup_;
         sys1.IOSize_ = [ios1(1) ios2(2)];
         sys1.Name_ = [];  sys1.Notes_ = [];  sys1.UserData = [];
      end
      
   else
      % Harmonize types and try again
      if isnumeric(sys2) || ~hasSimpleInverse_(sys2)
         [sys1,sys2] = ltipack.matchType('mtimes',sys1,sys2);
         sys1 = mrdivide(sys1,sys2);
      else
         % If SYS2 has a simple inverse (e.g., SISO transfer function), compute
         % it before matching types. This avoids unnecessary descriptor forms 
         % in, e.g., ss(1,2,3,4)/(s+1) or realp('a',1)/(s+1) (s=tf('s'))
         [sys1,isys2] = ltipack.matchType('mtimes',sys1,inv(sys2));
         sys1 = mtimes(sys1,isys2);
      end
   end
catch E
   throw(E)
end
