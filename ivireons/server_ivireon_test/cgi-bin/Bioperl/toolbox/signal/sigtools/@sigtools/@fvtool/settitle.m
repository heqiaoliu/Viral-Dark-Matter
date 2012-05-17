function settitle(this)
%SETTITLE Set the title of the Filter Visualization Tool

%   Author(s): J. Schickler
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.10.4.2 $  $Date: 2006/06/27 23:41:08 $ 

hFVT = getcomponent(this, 'fvtool');

str  = get(hFVT.CurrentAnalysis, 'Name');

% Set the figure title.
hn = get(this, 'HostName');
if ~isempty(hn), str = sprintf('%s (%s)', str, hn); end

if ~strcmpi(get(this, 'WindowStyle'), 'docked')
    str = sprintf('Filter Visualization Tool - %s', str);
end

set(this, 'Name', str);

% [EOF]
