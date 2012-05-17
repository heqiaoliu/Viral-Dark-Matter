function indices = utRefCheck(sys,indices,sizes)
% Check and format indices for SUBSREF
%
%   IND = UTREFCHECK(SYS,IND,SIZES) checks the SUBSREF indices IND
%   against the model SIZES and the I/O names/groups of SYS,
%   and turns all logical and name-based references into integer-valued 
%   subscripts.

%   Author(s): P. Gahinet
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2007/12/14 14:23:30 $

% Format subscripts and resolve name-based subscripts
indices = formatsubs(indices,sizes);

% Turn name references into regular indices (first 2 dimensions only)
for j=1:2, 
   indices{j} = utNameRef(sys,indices{j},j); 
end

% Make SIZES the same length as INDICES
%  * if NIND<ND (absolute reference into LTI array), fold the dimensions 
%    NIND through ND into a single dimension
%  * if NIND>ND, pad SIZES with unit sizes
nd = length(sizes); 
nind = length(indices);
sizes = [sizes(1:min(nind-1,nd)) prod(sizes(nind:nd)) ones(1,nind-nd)];

% Check compatibility of indices with sizes
% RE: at this point, LENGTH(SIZES) = LENGTH(INDICES)
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

