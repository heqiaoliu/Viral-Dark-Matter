function h = dfiltwfs(filtobj, fs, name)
%FILTWFS Construct a filtwfs object

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2007/12/14 15:08:23 $

error(nargchk(1,3,nargin,'struct'));

if nargin < 2,
    if ispref('SignalProcessingToolbox', 'DefaultFs'),
        fs = getpref('SignalProcessingToolbox', 'DefaultFs');
    else
        fs = 1;
    end
end
if nargin < 3, name = inputname(1); end

h = dfilt.dfiltwfs;

h.Filter = filtobj;
set(h, 'Fs', fs);
set(h, 'Name', name);

% [EOF]
