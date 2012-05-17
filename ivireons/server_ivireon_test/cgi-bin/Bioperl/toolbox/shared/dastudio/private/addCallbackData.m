%
% Add some instance properties to action to manage view manage
% actions.
%
function action = addCallbackData(action, data)

%   Copyright 2009 The MathWorks, Inc.

schema.prop(action, 'callbackData', 'mxArray');
action.callbackData = data;