function action = getaction(h, key)
%GETACTION   get action at KEY (ie: 'FILE_NEW').

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 19:59:38 $

if(isempty(h.actions))
	return;
end
action = h.actions.get(key);
action = handle(action);

% [EOF]