function [sys,SingularFlag] = connect(varargin)
%CONNECT  Block-diagram interconnections of dynamic systems.
%
%   CONNECT computes an aggregate model for a block diagram interconnection 
%   of dynamic systems. You can specify the block diagram connectivity in 
%   two ways:
%
%   Name-based interconnection
%     In this approach, you name the input and output signals of all blocks 
%     SYS1, SYS2,... in the block diagram, including the summation blocks. 
%     The aggregate model SYS is then built by 
%        SYS = CONNECT(SYS1,SYS2,...,INPUTS,OUTPUTS) 
%     where INPUTS and OUTPUTS are the names of the block diagram external 
%     I/Os (specified as strings or string vectors). For MIMO systems, use 
%     STRSEQ to quickly generate numbered channel names like {'e1';'e2';'e3'}.
%
%     Example 1: Given SISO LTI models C and G, you can construct the
%     closed-loop transfer T from r to y using
%
%                   e       u
%           r --->O-->[ C ]---[ G ]-+---> y
%               - |                 |       
%                 +<----------------+
%         
%        C.InputName = 'e';  C.OutputName = 'u';
%        G.InputName = 'u';  G.OutputName = 'y';
%        Sum = sumblk('e','r','y','+-');
%        T = connect(G,C,Sum,'r','y')
%
%     Example 2: If C and G above are two-input, two-output models instead, 
%     you can form the MIMO transfer T from r to y using
%         
%        C.InputName = {'e1','e2'};   C.OutputName = {'u1','u2'};
%        G.InputName = C.OutputName;  G.OutputName = {'y1','y2'};
%        r = {'r1','r2'};
%        Sum = sumblk(C.InputName,r,G.OutputName,'+-');
%        T = connect(G,C,Sum,r,G.OutputName)   
%
%   Index-based interconnection
%     In this approach, first combine all system blocks into an aggregate, 
%     unconnected model BLKSYS using APPEND. Then construct a matrix Q
%     where each row specifies one of the connections or summing junctions 
%     in terms of the input vector U and output vector Y of BLKSYS. For 
%     example, the row [3 2 0 0] indicates that Y(2) feeds into U(3), while 
%     the row [7 2 -15 6] indicates that Y(2) - Y(15) + Y(6) feeds into U(7).  
%     The aggregate model SYS is then obtained by 
%        SYS = CONNECT(BLKSYS,Q,INPUTS,OUTPUTS) 
%     where INPUTS and OUTPUTS are index vectors into U and Y selecting the   
%     block diagram external I/Os.
%
%     Example: You can construct the closed-loop model T for the block 
%     diagram above as follows:
%        BLKSYS = append(C,G);   
%        % U = inputs to C,G.  Y = outputs of C,G
%        % Here Y(1) feeds into U(2) and -Y(2) feeds into U(1)
%        Q = [2 1; 1 -2]; 
%        % External I/Os: r drives U(1) and y is Y(2)
%        T = connect(BLKSYS,Q,1,2)
%
%   Note: Blocks and states that are not connected to INPUTS or OUTPUTS are
%   automatically discarded.
%
%   See also SUMBLK, STRSEQ, APPEND, SERIES, PARALLEL, FEEDBACK, LFT,
%   DYNAMICSYSTEM.

%   Author(s): J.N. Little, P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2010/05/10 17:36:49 $

% Acknowledgment: Thanks to Christophe Lauwerys for his helpful suggestions.
ni = nargin;
if ni<2
    ctrlMsgUtils.error('Control:general:TwoOrMoreInputsRequired','connect','connect')
else
   IndexBased = isa(varargin{2},'double');
end

try
   % Gather interconnection data:
   %  * FEEDIN, FEEDOUT, and K such that interconnection amounts to
   %    feedback path U(FEEDIN) = K*Y(FEEDOUT)
   %  * IU and IY for selecting external I/Os
   if IndexBased
      % SYS = CONNECT(BLKSYS,Q,INPUTS,OUTPUTS)
      sys = varargin{1};
      q = varargin{2};
      Size = size(sys);
      ny = Size(1);  nu = Size(2);
      % Build feedback matrix K such that U = K*Y + R forms
      % the desired connected system.
      k = zeros(nu,ny);
      % Go through rows of Q
      for i=1:size(q,1)
         % Remove zero elements from each row of Q
         qi = q(i,q(i,:)~=0);
         n = length(qi);
         % Put the zeros and +-ones in K
         if n>1
            iu = qi(1);
            iy = abs(qi(2:n));
            if iu<1 || iu>nu || any(iy<1 | iy>ny)
               ctrlMsgUtils.error('Control:combination:connect1',i)
            end
            k(iu,:) = 0;  % in case some iu is repeated in Q
            k(iu,iy) = sign(qi(2:n));
         end
      end
      % Construct index vector FEEDIN, FEEDOUT, IU, IY
      % RE: Discard zero feedback path to avoid absorbing external I/O delays
      feedin = find(any(k,2));  
      feedout = find(any(k,1));
      k = k(feedin,feedout);
      if ni<4
         iu = 1:nu;  iy = 1:ny;
      else
         iu = varargin{3};  iy = varargin{4};
         if ~isvector(iu) || ~isvector(iy)
             ctrlMsgUtils.error('Control:combination:connect2','connect(BLKSYS,Q,INPUTS,OUTPUTS)')
         elseif any(iu<1 | iu>nu)
             ctrlMsgUtils.error('Control:general:IndexOutOfRange','connect(BLKSYS,Q,INPUTS,OUTPUTS)','INPUTS')
         elseif any(iy<1 | iy>ny)
             ctrlMsgUtils.error('Control:general:IndexOutOfRange','connect(BLKSYS,Q,INPUTS,OUTPUTS)','OUTPUTS')
         end
      end
   else
      % Name-based IC
      % SYS = CONNECT(SYS1,SYS2,...,INPUTS,OUTPUTS)
      if ni<3
         ctrlMsgUtils.error('Control:combination:connect3')
      end
      ExternalInputs = varargin{ni-1};
      ExternalOutputs = varargin{ni};
      if ~(ischar(ExternalInputs) || iscellstr(ExternalInputs)) || ...
            ~(ischar(ExternalOutputs) || iscellstr(ExternalOutputs))
         ctrlMsgUtils.error('Control:combination:connect4')
      end
      % Append all blocks
      sys = append(varargin{1:ni-2});
      % Get I/O names
      InputNames = get(sys,'InputName');
      OutputNames = get(sys,'OutputName');
      if any(strcmp(InputNames,'')) || any(strcmp(OutputNames,''))
          ctrlMsgUtils.error('Control:combination:connect5')
      elseif length(unique(OutputNames))<length(OutputNames)
          ctrlMsgUtils.error('Control:combination:connect6')
      end
      % Signal branching gives rise to repeated input names. Reduce repeated
      % inputs to single occurrence driving a gain block ONES(nrepeat,1)
      [inames,I,J] = unique(InputNames);
      nur = length(inames);
      if nur<length(InputNames)
         InputNames = inames;
         % u = EYE * u -> u(J) = EYE(J,:) * u
         M = eye(nur);
         sysM = sys * M(J,:);
         % Apply input channel metadata of sys(:,I) to result
         if ~isempty(sys.InputName_)
            sysM.InputName_ = sys.InputName_(I,:);
         end
         if ~isempty(sys.InputUnit_)
            sysM.InputUnit_ = sys.InputUnit_(I,:);
         end
         % Note: InputGroup are somewhat arbitrary if not defined
         % consistently for all branched signals
         sysM.InputGroup_ = groupref(sys.InputGroup_,I);
         sys = sysM;
      end
      % Check if the external I/Os are defined and locate them in full I/O list
      iu = localFindIn(InputNames,ExternalInputs);
      if isempty(iu)
         ctrlMsgUtils.error('Control:combination:connect7')
      end
      iy = localFindIn(OutputNames,ExternalOutputs);
      if isempty(iy)
         ctrlMsgUtils.error('Control:combination:connect7')
      end
      % Determine feedback channels
      [~,feedin,feedout] = intersect(InputNames,OutputNames);
      k = eye(length(feedin));
   end

   % Data management
   [sys,SingularFlag] = connect_(sys,k,feedin,feedout,iu,iy);
   if nargout<2 && SingularFlag
      ctrlMsgUtils.warning('Control:combination:SingularAlgebraicLoop')
   end

   % Metadata
   sw = ctrlMsgUtils.SuspendWarnings('Control:ltiobject:DuplicatedIONames'); %#ok<NASGU>
   sys = subsysMetaData(sys,iy,iu);
   sys.IOSize_ = [length(iy) length(iu)];
   sys.Name_ = [];
   
catch E
   throw(E)
end

%---------- Local Function ------------------

function idx = localFindIn(A,B)
% Computes index s.t. B = A(IDX)
if ischar(B)
   B = {B};
end
[Bu,~,iu] = unique(B);  % B = Bu(iu)
[~,ia,ib] = intersect(A,Bu);
if length(ib)<length(Bu)
   % Not all strings in B are in A
   idx = []; return
end
[~,is] = sort(ib);  % Bu = A(ia(is))
idx = ia(is(iu));
