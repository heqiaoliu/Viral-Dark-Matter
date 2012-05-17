function onVisualResized(this, ~)
%ONVISUALRESIZED 

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/01/25 22:47:17 $

% If the screen message is visible, update it.
if this.screenMsg
    this.screenMsg(true);
end

% [EOF]
