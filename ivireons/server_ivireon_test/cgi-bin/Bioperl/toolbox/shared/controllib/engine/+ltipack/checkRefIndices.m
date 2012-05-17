function indices = checkRefIndices(indices,sizes)
% Check and format indices for SUBSREF
%
%   IND = CHECKREFINDICES(IND,SIZES) checks the SUBSREF indices IND against 
%   the model sizes and converts all logical references into integer-valued 
%   subscripts.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:46:32 $

% Make SIZES the same length as INDICES
%  * if NIND<ND (absolute reference into LTI array), fold the dimensions
%    NIND through ND into a single dimension
%  * if NIND>ND, pad SIZES with unit sizes
nd = length(sizes);
nind = length(indices);
if nind>2
   sizes = [sizes(1:min(nind-1,nd)) prod(sizes(nind:nd)) ones(1,nind-nd)];
end

% Check compatibility of indices with sizes
% RE: at this point, LENGTH(SIZES) >= LENGTH(INDICES)
nci = find(~strcmp(indices,':'));  % locate non-colon indices
for j=nci,
   indj = indices{j};
   if islogical(indj);
      indj = find(indj);
   end
   if isnumeric(indj)
      if any(indj<1 | indj>sizes(j))
         ctrlMsgUtils.error('Control:ltiobject:subsref2',j)
      end
   else
      ctrlMsgUtils.error('Control:ltiobject:subsref1',j')
   end
   indices{j} = indj;
end