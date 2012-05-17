function indices = checkAsgnIndices(indices,sizes,DelFlag)
% Checks and format indices for SUBSASGN
%
%   IND = CHECKASGNINDICES(IND,SIZES,DELFLAG) performs the following tasks:
%     * Check compatibility of SUBSASGN indices IND and dimensions
%       SIZES of the LHS for deletion assignments (RHS=[], DELFLAG=1)
%     * Replace all logical by integer-valued subscripts.


%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2010/02/08 22:46:31 $
% Turn logical references into integer subscripts
nd = length(sizes);
nind = length(indices);
for j=1:nind
   if islogical(indices{j})
      indices{j} = find(indices{j});
   end
end

% Handle case SYS(i1,...,ik) = [].
% Note: All error checking for  SYS(i1,...,ik) = non-empty RHS
% is deferred to the built-in code for ND array assignments
if DelFlag,
   % Get positions of non-colon indexes
   iscolon = strcmp(indices,':');
   nci = find(~iscolon);
   if length(nci)>1,
      % All indices but one should be colons
      ctrlMsgUtils.error('Control:ltiobject:subsasgn1')
   elseif length(nci)==1,
      ncindex = indices{nci};
      if nind<nd && nci==nind,
         % Absolute array indexing
         snci = prod(sizes(nci:end));
      elseif nci>nd
         snci = 1;
      else
         snci = sizes(nci);
      end
      if any(ncindex<=0 | ncindex>snci)
         ctrlMsgUtils.error('Control:ltiobject:subsasgn2')
      end
   end
   % Pad INDICES with colons if NIND<NLD and last index is a colon
   if nind<nd && iscolon(nind),
      indices(nind+1:nd) = {':'};
   end
end
