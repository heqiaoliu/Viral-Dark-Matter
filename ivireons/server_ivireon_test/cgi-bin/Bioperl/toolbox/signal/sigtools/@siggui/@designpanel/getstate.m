function s = getstate(this)
%GETSTATE Return the information necessary to recreate the design panel

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.4 $  $Date: 2004/12/26 22:20:58 $

s = siggui_getstate(this);

% Make sure that we have all of the components so that the state is complete.
if isempty(this.CurrentDesignMethod)
    listeners(this, [], 'usermodifiedspecs_listener');
end

h = find(allchild(this), '-not', 'Name', 'Design Method', '-and', ...
    '-not', 'Name', 'Response Type', '-depth', 0);
for indx = 1:length(h),
    s.Components{indx} = getstate(h(indx));
end

% [EOF]
