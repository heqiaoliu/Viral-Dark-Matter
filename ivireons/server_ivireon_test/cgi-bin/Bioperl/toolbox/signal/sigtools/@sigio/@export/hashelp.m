function b = hashelp(this)
%HASHELP   Returns true if there is a CSHelpTag.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/10/18 21:10:51 $

% We only have help if a tag was provided.
b = ~isempty(this.CSHelpTag);

% [EOF]
