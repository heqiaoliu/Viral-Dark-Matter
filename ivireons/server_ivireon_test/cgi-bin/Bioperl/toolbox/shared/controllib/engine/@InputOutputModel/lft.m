function [M1,varargout] = lft(M1,M2,varargin)
%LFT  Generalized feedback interconnection of input/output models.
%
%   M = LFT(M1,M2,NU,NY) forms the following feedback interconnection 
%   of the input/output models M1 and M2:
%		
%                        +-------+
%            w1 -------->|       |-------> z1
%                        |   M1  |
%                  +---->|       |-----+
%                  |     +-------+     |
%                u |                   | y
%                  |     +-------+     |
%                  +-----|       |<----+
%                        |   M2  |
%           z2 <---------|       |-------- w2
%                        +-------+
%
%   The feedback loop connects the first NU outputs of M2 to the last 
%   NU inputs of M1 (signals u), and the last NY outputs of M1 to the 
%   first NY inputs of M2 (signals y). The resulting system M maps the
%   input vector [w1;w2] to the output vector [z1;z2]. This operation is 
%   referred to as a linear fractional transformation or LFT.
%
%   M = LFT(M1,M2) returns
%     * the lower LFT of M1 and M2 if M2 has fewer inputs and outputs 
%       than M1. This amounts to deleting w2,z2 in the above diagram.
%     * the upper LFT of M1 and M2 if M1 has fewer inputs and outputs 
%       than M2. This amounts to deleting w1,z1 above.
%
%   If M1 and M2 are arrays of models, LFT returns a model array M of the 
%   same size where 
%      M(:,:,k) = LFT(M1(:,:,k),M2(:,:,k),NU,NY) .
%
%   For dynamic systems SYS1 and SYS2, 
%      SYS = LFT(SYS1,SYS2,'name') 
%   connects SYS1 and SYS2 by matching their I/O names. The output of SYS1 
%   are connected to the inputs of SYS2 with the same names, and similarly 
%   for the inputs of SYS1 and outputs of SYS2.
%
%   See also FEEDBACK, CONNECT, INPUTOUTPUTMODEL, DYNAMICSYSTEM.

%   Author(s): P. Gahinet, 5-10-95.
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/31 18:37:28 $
ni = nargin;
no = nargout-1;
error(nargchk(2,4,ni))
try
   if ltipack.hasMatchingType('lft',M1,M2)
      % All operands are of the same type
      
      % Determine indexes for v/u and z/y
      sizes1 = iosize(M1);
      sizes2 = iosize(M2);
      ny1 = sizes1(1);  nu1 = sizes1(2);
      ny2 = sizes2(1);  nu2 = sizes2(2);
      
      % Parse inputs
      switch ni
         case 2
            if nu1>=ny2
               indu1 = nu1-ny2+1:nu1;  indy2 = 1:ny2;
            else
               indu1 = 1:nu1; indy2 = 1:nu1;
            end
            if ny1>=nu2,
               indy1 = ny1-nu2+1:ny1;  indu2 = 1:nu2;
            else
               indy1 = 1:ny1;  indu2 = 1:ny1;
            end
         case 3
            % Named-based interconnection
            try
               [InputName1,OutputName1] = getIOName(M1);
               [InputName2,OutputName2] = getIOName(M2);
            catch ME
               ctrlMsgUtils.error('Control:lftmodel:nameIC','lft')
            end
            [indy1,indu2] = InputOutputModel.matchChannelNames(OutputName1,InputName2);
            [indy2,indu1] = InputOutputModel.matchChannelNames(OutputName2,InputName1);
         case 4
            % NU,NY specified
            nu = varargin{1};
            ny = varargin{2};
            indu1 = nu1-nu+1:nu1;  indy1 = ny1-ny+1:ny1;
            indu2 = 1:ny;  indy2 = 1:nu;
      end
      
      % I/O size compatibility
      if length(indu1)>ny2 || length(indy2)>nu1
         ctrlMsgUtils.error('Control:combination:lft1')
      elseif length(indy1)>nu2 || length(indu2)>ny1,
         ctrlMsgUtils.error('Control:combination:lft2')
      end
      
      % Combine data and metadata
      % Note: lft_ can be overloaded by subclasses since SYS1 and SYS2 are of the same type
      [M1,SingularFlag] = lft_(M1,M2,indu1,indy1,indu2,indy2);
      M1 = lftMetaData(M1,M2,indu1,indy1,indu2,indy2);
      M1.IOSize_ = M1.IOSize_ + M2.IOSize_ - (length(indu1)+length(indy1));
      
      % Diagnostics
      if SingularFlag && no==0
         ctrlMsgUtils.warning('Control:combination:SingularAlgebraicLoop')
      end
      if no>0
         varargout = {SingularFlag};
      end
   else
      % Harmonize types and try again
      [M1,M2] = ltipack.matchType('lft',M1,M2);
      [M1,varargout{1:no}] = lft(M1,M2,varargin{:});
   end
catch ME
   throw(ME)
end
