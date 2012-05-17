function fs = getmaxfs(this)
%GETMAXFS   Method to get the Fs from the spectrum object.

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:29:35 $

if isempty(this.Spectrum),
    fs = [];
else
    fs = getfs(this.Spectrum);
end

% [EOF]
