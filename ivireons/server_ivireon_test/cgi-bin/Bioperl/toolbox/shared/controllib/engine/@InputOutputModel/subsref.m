function result = subsref(M,Struct)
%SUBSREF  Subscripted reference for static or dynamic models.
%
%   The following reference operations can be applied to any model M: 
%      M(rows,columns)    select subset of rows and columns
%      M.propertyName     access value of property "propertyName".
%
%   For arrays of models, indexed referencing takes the form
%      M(rows,columns,j1,...,jk)
%   where k is the number of array dimensions. Use 
%      M(:,:,j1,...,jk)
%   to access the (j1,...,jk) model in the model array.
%
%   See also DYNAMICSYSTEM/SUBSASGN, DYNAMICSYSTEM, STATICMODEL.

%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:52:00 $
ni = nargin;
if ni==1,
   result = M;  return
end

try
   % Peel off first layer of subreferencing
   switch Struct(1).type
      case '.'
         % The first subreference is of the form M.fieldname
         Struct(1).subs = ltipack.matchProperty(Struct(1).subs,...
            ltipack.allprops(M),class(M));
         result = builtin('subsref',M,Struct(1));
      case '()'
         % The first subreference is of the form M(indices)
         result = subparen(M,Struct(1).subs);
      case '{}'
         ctrlMsgUtils.error('Control:ltiobject:subsref3')
   end
   if length(Struct)>1,
      % SUBSREF for InputOutputModel objects can't be invoked again
      % inside this method so jump out to make sure that downstream
      % references to InputOutputModel properties are handled correctly,
      result = ltipack.dotref(result,Struct(2:end));
   end
catch E
   ltipack.throw(E,'subsref',class(M))
end
