function pb = iptGetPointerBehavior(h)
%iptGetPointerBehavior Retrieve pointer behavior from HG object.
%   pointerBehavior = iptGetPointerBehavior(h) returns the "pointer behavior"
%   associated with the Handle Graphics object h.  A pointer behavior is a
%   structure of function handles that interact with a figure's pointer
%   manager (see iptPointerManager) to control what happens when the figure's
%   mouse pointer moves over and then exits the object.  See
%   iptSetPointerBehavior for details.
%
%   If h is empty, the returned value for pb is also empty.
%
%   See also iptPointerManager, iptSetPointerBehavior.

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/12/22 23:50:42 $

% Preconditions (all checked):
%     One input argument
%         Images:iptGetPointerBehavior:tooFewInputs
%         MATLAB:TooManyInputs
%
%     HG handle is valid
%         Images:iptGetPointerBehavior:invalidHandle
%
% Information hiding:
%     This routine (together with iptSetPointerBehavior) hides the specific
%     mechanism used to store and retrieve the pointer behavior.

% Assert that there is one input argument.
iptchecknargin(1, 1, nargin, mfilename);

if isempty(h)
    % Return [] for an empty input.
    pb = [];
else
    % Assert that the input argument is a valid HG handle.
    if ~isscalar(h) || ~ishghandle(h)
        error('Images:iptGetPointerBehavior:invalidHandle', ...
              'H must be a valid Handle Graphics handle.');
    end

    % getappdata returns [] if no such appdata value has been saved in the 
    % object.
    pb = getappdata(h, 'iptPointerBehavior');
end

