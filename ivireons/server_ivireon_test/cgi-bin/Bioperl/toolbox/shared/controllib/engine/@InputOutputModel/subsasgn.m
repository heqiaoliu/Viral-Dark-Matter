function M = subsasgn(M,Struct,rhs)
%SUBSASGN  Subscripted assignment for static or dynamic models.
%
%   The following assignment operations can be applied to any model M: 
%     M(rows,columns)=RHS   reassigns a subset of the rows and columns
%     M.propertyName=RHS    modifies value of property "propertyName".
%
%   For arrays of models, indexed assignments take the form
%      M(rows,columns,j1,...,jk) = RHS
%   where k is the number of array dimensions (in addition to the 
%   output/row and input/column dimensions).
%
%   See also DYNAMICSYSTEM/SUBSREF, DYNAMICSYSTEM, STATICMODEL.

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:51:59 $
if nargin==1,
   return
elseif ~(isa(M,'InputOutputModel') || isempty(M))
   M = builtin('subsasgn',M,Struct,rhs);
   return
end

% Peel off first layer of subassignment
try
   switch Struct(1).type
      case '.'
         % Assignment of the form M.fieldname(...)=rhs
         % Resolve full property name and delegate to built-in version
         Struct(1).subs = ltipack.matchProperty(Struct(1).subs,...
            ltipack.allprops(M),class(M));
         if length(Struct)>1
            % SUBSASGN for InputOutputModel objects can't be invoked again
            % inside this method so jump out to make sure that 
            % sys.Blocks.a.Nominal = 2 is handled correctly.
            rhs = ltipack.dotasgn(ltipack.dotref(M,Struct(1)),Struct(2:end),rhs);
         end
         builtin('subsasgn',M,Struct(1),rhs);
         
      case '()'
         % Assignment of the form M(indices)...=rhs
         if length(Struct)>1
            rhs = ltipack.dotasgn(subparen(M,Struct(1).subs),Struct(2:end),rhs);
         end
         M = indexasgn(M,Struct(1).subs,rhs);
         
      case '{}'
         ctrlMsgUtils.error('Control:ltiobject:subsref3')
   end
catch E
   ltipack.throw(E,'subsasgn',class(M))
end
