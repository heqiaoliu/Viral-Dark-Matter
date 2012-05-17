function M1 = plus(M1,M2)
%PLUS  Adds two input/output models together.
%
%   M = PLUS(M1,M2) performs M = M1 + M2. For dynamic systems, this is 
%   equivalent to connecting M1 and M2 in parallel.
%
%   If M1 and M2 are arrays of models, M is a model array of the same size
%   where the k-th model is the sum of the k-th models in M1 and M2:
%      M(:,:,k) = M1(:,:,k) + M2(:,:,k) .
%
%   See also PARALLEL, INPUTOUTPUTMODEL.

%   Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/31 18:37:32 $
try
   if isnumeric(M1) && ~M2.isCombinable('plus')
      % Bypass for DOUBLE + M2 with M2 atomic (e.g., 2 + @pid)
      M1 = M2.addNumeric(M1);
      
   elseif isnumeric(M2) && ~M1.isCombinable('plus')
      % Bypass for M1 + DOUBLE with M1 atomic
      M1 = M1.addNumeric(M2);
      
   elseif ltipack.hasMatchingType('plus',M1,M2)
      % All operands are of the same type
      % Check I/O sizes and detect scalar addition M1 + M2
      % (interpreted as M1 + M2*ones(M1) )
      sizes1 = M1.IOSize_;
      sizes2 = M2.IOSize_;
      if all(sizes1(1:2)==1) && any(sizes2(1:2)~=1),
         % M1 is SISO (scalar addition)
         if any(sizes2==0),
            % Scalar + Empty = Empty
            M1 = M2;   return
         else
            % Perform scalar expansion
            M1 = iorep(M1,sizes2(1:2));
         end
      elseif all(sizes2(1:2)==1) && any(sizes1(1:2)~=1),
         % M2 is SISO
         if any(sizes1==0),
            % Scalar + Empty = Empty
            return
         else
            M2 = iorep(M2,sizes1(1:2));
         end
      elseif any(sizes1(1:2)~=sizes2(1:2)),
         ctrlMsgUtils.error('Control:combination:IncompatibleIODims')
      end
      
      % Combine data and metadata
      M1 = plus_(M1,M2);% overloadable since M1,M2 are of the same class
      M1 = plusMetaData(M1,M2);
   else
      % Harmonize types and try again
      [M1,M2] = ltipack.matchType('plus',M1,M2);
      M1 = plus(M1,M2);
   end
catch E
   throw(E)
end

