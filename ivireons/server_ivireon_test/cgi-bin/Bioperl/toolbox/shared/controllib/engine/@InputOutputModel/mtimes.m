function M1 = mtimes(M1,M2)
%MTIMES  Multiplies two input/output models together.
%
%   M = MTIMES(M1,M2) performs the multiplication M = M1 * M2. For dynamic
%   systems, this is equivalent to connecting M1 and M2 in series as follows:
%
%      u ----> M2 ----> M1 ----> y
%
%   If M1 and M2 are arrays of models, their product is a model array of 
%   the same size where the k-th system is obtained by
%      M(:,:,k) = M1(:,:,k) * M2(:,:,k) .
%
%   See also SERIES, INPUTOUTPUTMODEL/MLDIVIDE, INPUTOUTPUTMODEL/MRDIVIDE, 
%   INPUTOUTPUTMODEL/INV, INPUTOUTPUTMODEL.

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/31 18:37:30 $
try
   if isnumeric(M1) && ~M2.isCombinable('mtimes')
      % Bypass for DOUBLE * M2 with M2 atomic (e.g., 3 * @pid)
      M1 = M2.leftMultiplyByNumeric(M1);
      
   elseif isnumeric(M2) && ~M1.isCombinable('mtimes')
      % Bypass for M1 * DOUBLE with M1 atomic
      M1 = M1.rightMultiplyByNumeric(M2);
      
   elseif ltipack.hasMatchingType('mtimes',M1,M2)
      % All operands are of the same type
      % Check I/O dimensions and handle scalar multiplication
      sizes1 = M1.IOSize_;
      sizes2 = M2.IOSize_;
      ScalarFlags = false(1,2);
      if all(sizes1(1:2)==1) && sizes2(1)~=1,
         % M1 is SISO (scalar multiplication)
         if any(sizes2==0),
            % Scalar * Empty = Empty
            M1 = M2;   return
         elseif sizes2(1)<=sizes2(2),
            % Evaluate as (M1 * eye(ny2)) * M2
            ScalarFlags(1) = true;
         else
            % Evaluate as M2 * (M1 * eye(nu2))
            tmp = M2;  M2 = M1;  M1 = tmp;
            ScalarFlags(2) = true;
         end
      elseif all(sizes2(1:2)==1) && sizes1(2)~=1,
         % M2 is SISO (scalar multiplication)
         if any(sizes1==0),
            % Scalar * Empty = Empty
            return
         elseif sizes1(1)>=sizes1(2),
            % Evaluate as M1 * (M2 * eye(nu1))
            ScalarFlags(2) = true;
         else
            % Evaluate as (M2 * eye(ny1)) * M1
            tmp = M1;  M1 = M2;  M2 = tmp;
            ScalarFlags(1) = true;
         end
      elseif ~any(ScalarFlags) && sizes1(2)~=sizes2(1),
         ctrlMsgUtils.error('Control:combination:IncompatibleIODims')
      end
      
      % Combine data and metadata
      M1 = mtimes_(M1,M2,ScalarFlags);% overloadable since M1,M2 are of the same class
      M1 = mtimesMetaData(M1,M2,ScalarFlags);      
      if ScalarFlags(1)
         M1.IOSize_ = M2.IOSize_;
      elseif ~ScalarFlags(2)
         M1.IOSize_ = [M1.IOSize_(1) M2.IOSize_(2)];
      end
   else
      % Harmonize types and try again
      [M1,M2] = ltipack.matchType('mtimes',M1,M2);
      M1 = mtimes(M1,M2);
   end
catch E
   throw(E)
end

