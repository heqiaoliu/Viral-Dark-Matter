function M = indexasgn(M,indices,rhs)
%INDEXASGN  Modifies subsystem or model array slice.


%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2010/04/11 20:35:59 $
% Harmonize LHS and RHS classes and attributes
if ~isequal(rhs,[])
   if isequal(M,[])
      % LHS created by assignment
      M = createLHS(rhs);
   end
   rhs = localDynamicCast(rhs,M);
end

% Sizes
sizes = size(M);
rsizes = size(rhs);
DelFlag = isequal(rhs,[]);

% Check and format indices
indices = ltipack.formatSubs(indices,sizes,DelFlag);
for j=1:2,
   if ischar(indices{j}) && ~strcmp(indices{j},':')
      ctrlMsgUtils.error('Control:ltiobject:NoStringIndexing',class(M)) 
   end
end
indices = ltipack.checkAsgnIndices(indices,sizes,DelFlag);
nind = length(indices);
indrow = indices{1};
indcol = indices{2};
iscolon = strcmp(indices,':');

if DelFlag,
   % M(indices) = []
   % RE: For M(:,:,:)=[], only delete outputs to mimic a(:,:,:)=[] for matrices
   M = indexdel_(M,indices);
   
   % Update I/O size
   if all(iscolon) || ~iscolon(1)
      % Output deletion
      ikeep = 1:sizes(1);   ikeep(indrow) = [];
      M.IOSize_(1) = length(ikeep);
   elseif ~iscolon(2)
      % Input deletion
      ikeep = 1:sizes(2);    ikeep(indcol) = [];
      M.IOSize_(2) = length(ikeep);
   end
   
else
   % M(i1,...,ik) = rhs
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
   M = indexasgn_(M,indices,rhs,ioSize,ArrayMask);
      
   % Update metadata
   M.IOSize_ = ioSize;
end



function M = localDynamicCast(M,refsys)
% Attempts to cast SYS to class of REFSYS
initClass = class(M);
refClass = class(refsys);
if ~strcmp(initClass,refClass)
   try %#ok<TRYNC>
      M = feval(refClass,M);
   end
   if ~strcmp(class(M),refClass)
      ctrlMsgUtils.error('Control:ltiobject:subsasgn3',initClass,refClass)
   end
end
