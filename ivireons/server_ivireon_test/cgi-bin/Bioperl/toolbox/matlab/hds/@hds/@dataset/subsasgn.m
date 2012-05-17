function this = subsasgn(this,Struct,rhs)
% Subscripted assignment for data set objects.

%   Author(s): P. Gahinet
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/12/22 18:14:47 $

% RE: Needed for D.x(2,2)=1 when D.x is empty (need to 
%     initialize array)
StructL = length(Struct);

% Peel off first layer of subassignment
try
   switch Struct(1).type
      case '.'
         % Assignment of the form D.fieldname(...)=rhs
         FieldName = Struct(1).subs;
         if StructL==1
            % Direct assignment
            this.(FieldName) = rhs;
         else
            % Get current value
            FieldValue = this.(FieldName);
            if isempty(FieldValue)
               % Need to initialize LHS
               GridSize = getGridSize(this);
               if StructL>2 || ~strcmp(Struct(2).type,'()') || any(GridSize==0)
                  error('Invalid assignment into uninitialized variable %s',FieldName);
               end
               % D.var(ind) = rhs assignment
               FieldValue = hdsNewArray(rhs,GridSize);
            end
            % Perform assignment on field value and write back
            this.(FieldName) = subsasgn(FieldValue,Struct(2:end),rhs);
         end
      case '()'
         % Assignment D(i).fieldname = rhs
         if StructL<2 || ~strcmp(Struct(2).type,'.')
            error('Invalid assignment syntax into data set object.')
         else
            % D(ind).a = 1
            D = subsref(this,Struct(1));  % Extract subarray D(ind)
            if numel(D)~=1
               error('Cannot modify multiple data sets at once.')
            else
               subsasgn(D,Struct(2:end),rhs);
            end
         end
      case '{}'
         error('Invalid assignment syntax into data set object.')
   end
catch
   rethrow(lasterror)
end
