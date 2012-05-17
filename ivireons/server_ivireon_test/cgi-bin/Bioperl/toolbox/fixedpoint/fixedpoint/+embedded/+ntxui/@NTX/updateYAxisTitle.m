function updateYAxisTitle(ntx)
% Update the y-axis title string

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $     $Date: 2010/03/31 18:22:20 $

% 1 = Percentage
% 2 = Bin count
if ntx.HistVerticalUnits == 1
    str = 'Occurrences (%)'; %'Frequency (%)';
else
    str = 'Occurrences (Count)'; %'Count';
end
eng = ntx.BinCountVerticalUnitsStr;
if ~isempty(eng)
    str = [str ' (' eng ')'];
end
hy = get(ntx.hHistAxis,'ylabel');
set(hy,'string',str);
