function tstable_timevectorupdate(h,varargin)
%Callback that updates the time info in the Simulink "Container" panels,
%such as simulinkTsParentNode's viewer panel.

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2008/12/29 02:11:18 $

if isempty(h.Handles) || isempty(h.Handles.PNLTsOuter) || ...
        ~ishghandle(h.Handles.PNLTsOuter) || nargin<3 || ~isfield(h.Handles,'SimTable')
    return % No panel
end

Label = varargin{1}; %Model's name that the affected timeseries belongs to.
Ts = varargin{2}; %Timeseries whose data was changed.

tinfo = Ts.TimeInfo;
if isnan(tinfo.Increment)
    samplingBehav = 'non-uniform';
else
    samplingBehav = 'uniform';
end
time_str = sprintf('%0.3g - %0.3g %s (%s)',tinfo.Start, tinfo.End,...
    tinfo.Units, xlate(samplingBehav));

Hn = h.Handles;
M = Hn.SimTable;


%update the model table
for ii = 1:Hn.ModelTables(1).getRowCount
    thispath = Hn.ModelTables(1).getModel.getValueAt(ii-1,2);
    blkpathstr = h.getBlockPathString(Ts.BlockPath);
    if strcmp(thispath,blkpathstr)
        %row was located
        awtinvoke(Hn.ModelTables(1).getModel,...
            'setValueAt(Ljava/lang/Object;II)',...
            java.lang.String(time_str),ii-1,1);
        return;
    end
end

