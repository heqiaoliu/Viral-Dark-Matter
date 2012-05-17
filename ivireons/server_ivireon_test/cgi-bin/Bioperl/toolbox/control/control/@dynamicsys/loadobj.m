function sys = loadobj(s)
%LOADOBJ  Load filter for @dynamicsys class.

%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2007/12/14 14:23:13 $
if isa(s,'dynamicsys')
   % Object structure is up to date.
   sys = s;
else
   % Should not happen until we modify @dynamicsys
   ctrlMsgUtil.error('Control:ltiobject:loadobj1')
end

% Note: Do not update Version here or subclasses won't have access to
% the loaded version number. Always update version last and make sure to 
% imprint loaded version number on any instance created by the LOADOBJ
% methods for parent classes (e.g., LTI/LOADOBJ creates an @lti instance
% and should therefore set its version to the loaded version so that 
% SS/LOADOBJ gets the correct loaded version).
