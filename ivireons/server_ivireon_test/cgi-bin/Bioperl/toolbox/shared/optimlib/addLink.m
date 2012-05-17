function taggedString = addLink(linkedText,linkDestination)
%ADDLINK add a hyperlink to a string for display in the MATLAB Command
%Window.
% addLink takes an input string (linkedText) and wraps it in html tags that
% execute a MATLAB command to open the documentation browser to a specified
% location (linkDestination). 
% The result (taggedString) can be inserted in any text printed to the
% MATLAB Command Window (e.g. error, MException, warning, fprintf).

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/09/23 14:04:38 $

if feature('hotlinks') && ~isdeployed;
    % Create explicit char array so as to avoid translation
    openTag = sprintf('<a href = "matlab: helpview([docroot ''/toolbox/optim/helptargets.map''],''%s'');">',linkDestination);
    closeTag = '</a>';
    taggedString = [openTag linkedText closeTag];
else
    taggedString = linkedText;
end