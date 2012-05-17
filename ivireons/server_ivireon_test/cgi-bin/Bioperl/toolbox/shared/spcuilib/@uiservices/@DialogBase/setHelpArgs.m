function setHelpArgs(this, helpArgs)
%SETHELPARGS Set the HelpArgs

%   Author(s): J. Schickler
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/11/18 02:15:13 $

if ~ischar(helpArgs) && length(helpArgs) > 1
    this.HelpMethod = helpArgs{1};
    helpArgs(1) = [];
end
this.helpArgs = helpArgs;    

% [EOF]
