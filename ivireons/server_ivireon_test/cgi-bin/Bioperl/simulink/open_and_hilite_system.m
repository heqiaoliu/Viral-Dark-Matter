function open_and_hilite_system(sys,hilite,varargin)
%OPEN_AND_HILITE_SYSTEM Highlight a Simulink object.
%   OPEN_AND_HILITE_SYSTEM(SYS) highlights a Simulink object by first opening the system
%   window that contains the object and then highlighting the object using the
%   HiliteAncestors property.
%
%   You can specify the highlighting options as additional right hand side
%   arguments to OPEN_AND_HILITE_SYSTEM.  Options include:
%
%     default     highlight with the 'default' highlight scheme
%     none        turn off highlighting
%     find        highlight with the 'find' highlight scheme
%     unique      highlight with the 'unique' highlight scheme
%     different   highlight with the 'different' highlight scheme
%     user1       highlight with the 'user1' highlight scheme
%     user2       highlight with the 'user2' highlight scheme
%     user3       highlight with the 'user3' highlight scheme
%     user4       highlight with the 'user4' highlight scheme
%     user5       highlight with the 'user5' highlight scheme
%
%   To alter the colors of a highlighting scheme, use the following command:
%
%     set_param(0, 'HiliteAncestorsData', HILITEDATA)
%
%   where HILITEDATA is a MATLAB structure array with the following fields:
%
%     HiliteType       one of the highlighting schemes listed above
%     ForegroundColor  a color string (listed below)
%     BackgroundColor  a color string (listed below)
%
%   Available colors to set are 'black', 'white', 'red', 'green', 'blue',
%   'yellow', 'magenta', 'cyan', 'gray', 'orange', 'lightBlue', and
%   'darkGreen'.
%  
%   Examples:
%
%       % highlight the subsystem 'f14/Controller/Stick Prefilter'
%       open_and_hilite_system('f14/Controller/Stick Prefilter')
%
%   See also HILITE_SYSTEM, OPEN_SYSTEM

%   Copyright 1990-2010 The MathWorks, Inc.

% Verify the parent system is open before attempting to hilite it
if (ischar(sys))
    
  % Remove everything after the first slash in sys to get the parent
  parentSys = regexprep(sys, '/.*', '');
  open_system(parentSys);
  
end

if (nargin > 1)
    hilite_system(sys,hilite,varargin{:});
else
    hilite_system(sys);
end