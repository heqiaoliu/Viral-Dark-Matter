function dopplerpathnumber(h, pathnumberObj)
%DOPPLERPATHNUMBER  Path number edit box callback for multipath figure object.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/09/14 15:58:17 $


pn = h.UIHandles.PathNumber;

pathNumberStr = get(pn, 'String');
pathNumber = str2num(pathNumberStr);

validPathNumberValues = 1:1:length(h.CurrentChannel.PathDelays);

if ~isnumeric(pathNumber) || isempty(pathNumber) ...
        || isinf(pathNumber) || isnan(pathNumber) ...
        || ~isscalar(pathNumber) || ~isreal(pathNumber) ...
        || ~ismember(pathNumber,validPathNumberValues)
    pathNumber = 1;
    set(pn, 'String', '1'); % Reset to path 1
end

menuIdx = get(h.UIHandles.VisMenu, 'value');
selectedAxesIdx = h.AxesIdxDirectory{menuIdx};

% Multipath axes objects
axObjs = h.AxesObjects;

for n = 1:length(selectedAxesIdx)
    % Get multipath axes object.
    m = selectedAxesIdx(n);
    ax = axObjs{m};

    if ( isequal(class(ax), 'channel.mpdoppleraxes') )
        ax.PathNumberPlotted = pathNumber;
        ax.FirstPlot = 1;
    else
        error('comm:channel:multipathfig_dopplerpathnumber:WrongLocation','Shouldn''t be here');
    end
end


% Refresh snapshot if necessary.
h.refreshsnapshot;




