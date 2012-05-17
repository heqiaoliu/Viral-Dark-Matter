function Value = get(M,Property)
%GET  Access/query property values.
%
%   VALUE = GET(M,'PropertyName') returns the value of the specified  
%   property of the input/output model M. An equivalent syntax is 
%   VALUE = M.PropertyName.
%
%   VALUES = GET(M,{'Prop1','Prop2',...}) returns the values of several 
%   properties at once in a cell array VALUES.
%   
%   GET(M) displays all properties of M and their values.  
%
%   S = GET(M) returns a structure whose field names and values are the 
%   property names and values of M.
%
%   See also SET, INPUTOUTPUTMODEL.

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/03/31 18:37:24 $
ni = nargin;
error(nargchk(1,2,ni));
if ni==2,
   % GET(M,'Property') or GET(M,{'Prop1','Prop2',...})
   CharProp = ischar(Property);
   if CharProp,
      Property = {Property};
   elseif ~iscellstr(Property)
      ctrlMsgUtils.error('Control:ltiobject:get1')
   end
   AllPublicProps = ltipack.allprops(M);
   ClassName = class(M);
   
   % Get all public properties
   Nq = numel(Property);
   Value = cell(1,Nq);
   for i=1:Nq,
      try
         Value{i} = M.(ltipack.matchProperty(Property{i},AllPublicProps,ClassName));
      catch E
         throw(E)
      end
   end
            
   % Strip cell header if PROPERTY was a string
   if CharProp,
      Value = Value{1};
   end
else
   % Construct struct of field values
   s = getPropStruct(M);
   if nargout,
      Value = s;
   else
      disp(s)
   end
end



        
   
   
