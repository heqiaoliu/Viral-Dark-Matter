function sys = indexasgn(sys,indices,rhs)
%INDEXASGN  Modifies subsystem or model array slice.


%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2010/04/11 20:35:51 $
% Harmonize LHS and RHS classes and attributes
if ~isequal(rhs,[])
   if isequal(sys,[])
      % LHS created by assignment
      sys = createLHS(rhs);
   end
   rhs = localDynamicCast(rhs,sys);
   [sys,rhs] = matchAttributes(sys,rhs);
end

% Sizes
sizes = size(sys);
rsizes = size(rhs);
DelFlag = isequal(rhs,[]);

% Format and validate indices
indices = ltipack.formatSubs(indices,sizes,DelFlag);
for j=1:2,
   indices{j} = name2index(sys,indices{j},j);
end
indices = ltipack.checkAsgnIndices(indices,sizes,DelFlag);
nind = length(indices);
indrow = indices{1};
indcol = indices{2};
iscolon = strcmp(indices,':');

if DelFlag,
   % sys(indices) = []
   % RE: For sys(:,:,:)=[], only delete outputs to mimic a(:,:,:)=[] for matrices
   % Update data
   sys = indexdel_(sys,indices);
   
   % Update metadata
   if all(iscolon) || ~iscolon(1)
      % Output deletion
      ikeep = 1:sizes(1);   ikeep(indrow) = [];
      if isempty(ikeep)
         sys.OutputName_ = [];   sys.OutputUnit_ = [];
      else
         if ~isempty(sys.OutputName_)
            sys.OutputName_(indrow,:) = [];
         end
         if ~isempty(sys.OutputUnit_)
            sys.OutputUnit_(indrow,:) = [];
         end
      end
      sys.OutputGroup_ = groupref(sys.OutputGroup_,ikeep);
      sys.IOSize_(1) = length(ikeep);
   elseif ~iscolon(2)
      % Input deletion
      ikeep = 1:sizes(2);    ikeep(indcol) = [];
      if isempty(ikeep)
         sys.InputName_ = [];   sys.InputUnit_ = [];
      else
         if ~isempty(sys.InputName_)
            sys.InputName_(indcol,:) = [];
         end
         if ~isempty(sys.InputUnit_)
            sys.InputUnit_(indcol,:) = [];
         end
      end
      sys.InputGroup_ = groupref(sys.InputGroup_,ikeep);
      sys.IOSize_(2) = length(ikeep);
   end
   
else
   % sys(i1,...,ik) = rhs
   % Determine new I/O size (rely on assignment code for size checking)
   ioMask = zeros(sizes(1:2));
   % Perform assignment along I/O dimensions
   % RE: Throws error if I/O sizes are incompatible
   ioMask(indices{1:2}) = zeros(rsizes(1:2));
   ioSize = size(ioMask);

   % Determine new array size and which portion of the model array
   % is being (re)assigned
   if nind>2,
      ArrayMask = zeros(sizes(3:end));  % initial model array
      % Perform assignment along model array dimensions. In resulting
      % ASGNMASK, J>0 means J-th model in RHS array.
      % RE: Keep track of RHS model associated with each modified LHS model
      % (necessary because indices are not always monotonic, see g147948)
      rArraySize = [rsizes(3:end) 1 1];
      ArrayMask(indices{3:end}) = reshape(1:prod(rArraySize),rArraySize);
   else
      ArrayMask = 1;
   end

   % Update data
   % NOTE: The input and output delays for new channels and models are
   % initialized to NaN and inherited from RHS so that
   %    sys = ss(rand(2),'inputd',[1 2],'outputd',[3 4]);
   %    sys(3,3) = ss(1,'inputd',5)
   % does not turn 5 into an I/O or internal delay.
   sys = indexasgn_(sys,indices,rhs,ioSize,ArrayMask);
      
   % Update metadata
   sys.TimeUnit_ = DynamicSystem.resolveTimeUnit(sys.TimeUnit_,rhs.TimeUnit_);
   sys.IOSize_ = ioSize;
   
   % Ignore rhs in scalar assignments
   if isequal(rsizes(1:2),size(ioMask(indrow,indcol)))
      % Update Input metadata
      IgnoreClash = all(iscolon([1 3:end]));
      sys.InputName_ = localStringAssign(sys.InputName_,ioSize(2),rhs.InputName_,...
         indcol,IgnoreClash,'InputName');
      sys.InputUnit_ = localStringAssign(sys.InputUnit_,ioSize(2),rhs.InputUnit_,...
         indcol,IgnoreClash,'InputUnit');
      if IgnoreClash
         % Subset of columns are fully reassigned (SYS(:,j,:,...,:) = RHS)
         sys.InputGroup_ = groupasgn(sys.InputGroup_,indcol,rhs.InputGroup_);
      else
         % Columns are only partially reassigned
         % Compare input groups. Overwrite only if original was empty
         if islogical(indcol)
            indcol = find(indcol);
         end
         Glhs = groupref(sys.InputGroup_,indcol);
         [Grhs,clash] = mrggroup(Glhs,rhs.InputGroup_);
         if clash,
            ctrlMsgUtils.warning('Control:ltiobject:InputGroupClash')
         else
            if iscolon(2)
               indcol = 1:ioSize(2);
            end
            sys.InputGroup_ = groupasgn(sys.InputGroup_,indcol,Grhs);
         end
      end
      
      % Update Output metadata
      IgnoreClash = all(iscolon(2:end));
      sys.OutputName_ = localStringAssign(sys.OutputName_,ioSize(1),rhs.OutputName_,...
         indrow,IgnoreClash,'OutputName');
      sys.OutputUnit_ = localStringAssign(sys.OutputUnit_,ioSize(1),rhs.OutputUnit_,...
         indrow,IgnoreClash,'OutputUnit');
      if IgnoreClash
         sys.OutputGroup_ = groupasgn(sys.OutputGroup_,indrow,rhs.OutputGroup_);
      else
         % Compare output groups. Overwrite only if original was empty
         if islogical(indrow)
            indrow = find(indrow);
         end
         Glhs = groupref(sys.OutputGroup_,indrow);
         [Grhs,clash] = mrggroup(Glhs,rhs.OutputGroup_);
         if clash,
            ctrlMsgUtils.warning('Control:ltiobject:OutputGroupClash')
         else
            if iscolon(1)
               indrow = 1:ioSize(1);
            end
            sys.OutputGroup_ = groupasgn(sys.OutputGroup_,indrow,Grhs);
         end
      end
   end
   
end


%------------------------------------
function S = localStringAssign(S,nS,R,ind,IgnoreClash,PropName)
% Handles S(ind) = R for string vectors.
% NS is the length of S after assignment
EmptyS = isempty(S);
EmptyR = isempty(R) || all(cellfun(@isempty,R));
if ~(EmptyS && EmptyR)
   % Note: Watch for possible I/O growth
   S = [S ; repmat({''},[nS-length(S) 1])];
   if ~EmptyR
      if EmptyS || IgnoreClash
         % Empty S or full row/column reassignment
         S(ind,:) = R;
      else
         % Check for clashes
         [S(ind,:),clash] = ltipack.mrgname(S(ind,:),R);
         if clash,
            ctrlMsgUtils.warning(sprintf('Control:ltiobject:%sClash',PropName))
         end
      end
   end
end


function sys = localDynamicCast(sys,refsys)
% Attempts to cast SYS to class of REFSYS
initClass = class(sys);
refClass = class(refsys);
if ~strcmp(initClass,refClass)
   try %#ok<TRYNC>
      if isa(refsys,'FRDModel')
         sys = FRDModel.cast(refClass,sys,refsys);
      else
         sys = feval(refClass,sys);
      end
   end
   if ~strcmp(class(sys),refClass)
      ctrlMsgUtils.error('Control:ltiobject:subsasgn3',initClass,refClass)
   end
end
