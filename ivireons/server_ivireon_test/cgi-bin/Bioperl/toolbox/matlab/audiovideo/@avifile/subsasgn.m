function obj=subsasgn(obj,subscript,value)
%SUBSASGN subsasgn for an avifile object

%   Copyright 1984-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2007/07/26 19:29:39 $

if length(subscript) > 1
  error('MATLAB:avisubsasgn:invalidSubscriptLength','AVIFILE objects only support one level of subscripting.');
end

switch subscript.type
 case '.'
  param = subscript.subs;
  obj = set(obj,param,value);
 otherwise
  error('MATLAB:avisubsasgn:invalidSubscriptType','AVIFILE objects only support structure subscripting.')
end
