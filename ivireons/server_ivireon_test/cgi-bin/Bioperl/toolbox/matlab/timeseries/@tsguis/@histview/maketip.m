function str = maketip(this,tip,info)
%MAKETIP  Build data tips for @histview curves.
%
%   INFO is a structure built dynamically by the data tip interface
%   and passed to MAKETIP to facilitate construction of the tip text.

%   Author(s):  
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2005/06/27 22:58:03 $

r = info.Carrier;
AxGrid = info.View.AxesGrid;

% Clear all data tips on this line
dcm = datacursormode(ancestor(AxGrid.Parent,'figure'));
dc = dcm.DataCursors;
hosts = get(dc,{'Host'});
for j=1:length(hosts)
    if dc(j)~=tip
        dcm.removeDataCursor(dc(j));
    end
end

% Ensure zstackminimum is set to at least 10 in case this tip was created 
% with hg
set(tip,'zstackminimum',11,'EnableZStacking',true);

% Create tip text
if length(r.RowIndex)>1
    str{1,1} = sprintf('Time series: %s Column: %d',r.Name,info.Row);
else
    str{1,1} = sprintf('Time series: %s',r.Name);
end

str{end+1,1} = sprintf('Count: %0.3g',tip.Position(2));
[junk,I] = min(abs(tip.Position(1)-info.Data.XData));
if I==1
    width = (info.Data.XData(2)-info.Data.XData(1))/2;
else
    width = (info.Data.XData(I)-info.Data.XData(I-1))/2;
end
str{end+1,1} = sprintf('Range: %0.3g to %0.3g',info.Data.XData(I)-width, ...
    info.Data.XData(I)+width);