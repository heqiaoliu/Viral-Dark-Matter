function sys1 = mldivide(sys1,sys2)
%MLDIVIDE  Left division for dynamic systems.
%
%   SYS = MLDIVIDE(SYS1,SYS2) is invoked by SYS=SYS1\SYS2
%   and is equivalent to SYS = INV(SYS1)*SYS2.
%
%   See also DYNAMICSYSTEM/MRDIVIDE, DYNAMICSYSTEM/INV, DYNAMICSYSTEM/MTIMES.

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/03/31 18:36:46 $
try
   if isnumeric(sys1) && ~sys2.isCombinable('mtimes')
      % Bypass for DOUBLE\SYS2 with SYS2 atomic (e.g., 5\@pid)
      sys1 = sys2.leftMultiplyByNumeric(inv(sys1));
      
   elseif ltipack.hasMatchingType('mtimes',sys1,sys2)
      % All operands are of the same type
      % Size checking
      ios1 = sys1.IOSize_;
      ios2 = sys2.IOSize_;
      ScalarFlags = [all(ios1==1) all(ios2==1)];
      if ios1(1)~=ios1(2)
         ctrlMsgUtils.error('Control:combination:divide2','SYS1\SYS2','SYS1')
      elseif ios1(2)~=ios2(1) && ~any(ScalarFlags)
         ctrlMsgUtils.error('Control:combination:IncompatibleIODims')
      end
      
      if (ScalarFlags(1) && ios2(1)~=1) || (ScalarFlags(2) && ios1(1)~=1)
         % Scalar expansion needed: handle through MTIMES
         sys1 = inv(sys1)*sys2; %#ok<*MINV>
      else
         % Combine data
         sys1 = mldivide_(sys1,sys2);
         % Combine metadata
         sys1.TimeUnit_ = DynamicSystem.resolveTimeUnit(sys1.TimeUnit_,sys2.TimeUnit_);
         sys1.OutputName_ = sys1.InputName_;
         sys1.OutputUnit_ = sys1.InputUnit_;
         sys1.OutputGroup_ = sys1.InputGroup_;
         sys1.InputName_ = sys2.InputName_;
         sys1.InputUnit_ = sys2.InputUnit_;
         sys1.InputGroup_ = sys2.InputGroup_;
         sys1.IOSize_ = [ios1(1) ios2(2)];
         sys1.Name_ = [];  sys1.Notes_ = [];  sys1.UserData = [];
      end
   else
      % Harmonize types and try again
      if isnumeric(sys1) || ~hasSimpleInverse_(sys1)
         [sys1,sys2] = ltipack.matchType('mtimes',sys1,sys2);
         sys1 = mldivide(sys1,sys2);
      else
         % If SYS1 has a simple inverse (e.g., SISO transfer function), compute
         % it before matching types. This avoids unnecessary descriptor forms
         % in, e.g., (s+1)\ss(1,2,3,4) for s=tf('s')
         [isys1,sys2] = ltipack.matchType('mtimes',inv(sys1),sys2);
         sys1 = mtimes(isys1,sys2);
      end
   end
catch E
   throw(E)
end
