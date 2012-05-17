function addListeners(this, LoopData);
% Adds listener for changes in the open loop configuration

%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2005/11/15 00:46:50 $

% if this.Feedback
%     this.Listeners = handle.listener(this, this.findprop('LoopConfig'),...
%         'PropertyPreSet', ...
%         {@LocalComputeTunedLoop, this, LoopData});
% end