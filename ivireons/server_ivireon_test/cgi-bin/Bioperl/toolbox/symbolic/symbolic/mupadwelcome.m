function mupadwelcome
%MUPADWELCOME Welcome screen for MuPAD
%   MUPADWELCOME shows the Welcome dialog box if the Welcome screen wasn't
%   disabled.
%
%   See also: mupad
    
%   Copyright 2008-2009 The MathWorks, Inc.
    
% call mupad with no command string and in the background
    symengine('call','-show-welcome &');
