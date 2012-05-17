function value=subsref(obj,subscript)
%SUBSREF subsref for a AVIFILE object

%   Copyright 1984-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2007/07/26 19:29:40 $

if length(subscript) > 1
  error('MATLAB:avisubsref:invalidSubscriptLength','AVIFILE objects only support one level of subscripting.');
end

switch subscript.type
 case '.'
  param = subscript.subs;    
  value = get(obj,param);
 otherwise
  error('MATLAB:avisubsref:invalidSubscriptType','AVIFILE objects only support structure subscripting.')
end
