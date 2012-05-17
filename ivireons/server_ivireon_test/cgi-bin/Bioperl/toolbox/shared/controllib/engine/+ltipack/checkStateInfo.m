function sn = checkStateInfo(sn,PropName)
% Validates state names or state units.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:46:33 $
if isempty(sn) || all(strcmp(sn,''))
   sn = [];
elseif ischar(sn) && ndims(sn)==2,
   % A is a 2D array of padded strings
   sn = cellstr(sn);
elseif iscellstr(sn) && ndims(sn)==2 && min(size(sn))==1 && ...
      all(cellfun(@(s) isempty(s) || (ndims(s)==2 && size(s,1)==1),sn))
   % A is a vector of single-line or empty strings
   sn = sn(:);
else
   switch PropName
      case 'StateName'
         ctrlMsgUtils.error('Control:ltiobject:setLTI3','StateName')
      case 'StateUnit'
         ctrlMsgUtils.error('Control:ltiobject:setLTI6','StateUnit')
   end
end