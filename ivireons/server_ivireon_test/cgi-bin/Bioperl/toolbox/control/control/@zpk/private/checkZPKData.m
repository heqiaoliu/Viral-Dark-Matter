function A = checkZPKData(A,zpkstr)
% Enforces proper formatting of user-specified Z,P,K data.

%   Author: P. Gahinet, 5-1-96
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2010/02/08 22:29:39 $
if strcmp(zpkstr,'k')
   % Gain K
   if ~isnumeric(A)
      ctrlMsgUtils.error('Control:ltiobject:zpkProperties1')
   else
      A = double(full(A));
   end
else
   % Z,P data
   if iscell(A)
      for ct=1:numel(A)
         A{ct} = localCheckZP(A{ct});
      end
   else
      % Z or P specified as vector
      A = {localCheckZP(A)};
   end
end

function zp = localCheckZP(zp)
% Check zero or pole data
if ~isnumeric(zp) || (~isempty(zp) && ~isvector(zp)) || ~all(isfinite(zp))
    ctrlMsgUtils.error('Control:ltiobject:zpkProperties2')
else
   if size(zp,2)~=1
      zp = zp(:);
   end
   zp = double(full(zp));
end

