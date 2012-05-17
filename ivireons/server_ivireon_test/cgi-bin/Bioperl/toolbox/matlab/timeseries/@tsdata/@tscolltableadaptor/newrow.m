function newrow(h,newrow,row)
%NEWROW adds new data row to the timeseries when the table entries for a
%new row are completed. This is a callback triggered by the (java) table. 

%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $ $Date: 2006/06/27 23:09:35 $

%% Callback from java TableModel at completion of editing a new table row
%% Note that this method is an enhanced version of tsguis.ArrayEditorNewRow
%% which records data changes and implements undo/redo
%% Get new time
time = [];
if h.TableModel.getCache.getAbsTimeFlag
    try
        if ~isempty(h.Timeseries.TimeInfo.Format)
            time = (datenum(newrow{1},h.Timeseries.TimeInfo.Format)-...
                datenum(h.Timeseries.TimeInfo.StartDate))*...
                tsunitconv(h.Timeseries.TimeInfo.Units,'days');
        else
            time = (datenum(newrow{1})-...
                datenum(h.Timeseries.TimeInfo.StartDate))*...
                tsunitconv(h.Timeseries.TimeInfo.Units,'days');
        end
    end
else
    time = real(eval(newrow{1},'[]'));
end
if isempty(time) || ~isscalar(time) || ~isfinite(time)
    h.TableModel.resetEdit;
    h.Timeseries.send('datachange')
    return
end

try
    M = h.Timeseries.gettimeseriesnames;
    h.TableModel.resetEdit;
    % Now add sample for time = "time", assuming quality values for
    % timeseries members would bet assigned to new time sample
    % automatically.
    h.Timeseries.addsampletocollection('Time', time, 'OverwriteFlag', true);
    h.Timeseries.send('datachange');

    if ~isempty(M)
        drawnow
        msg = sprintf('NaN(s) have been inserted in the data rows of all time series members at time = %s.',...
            num2str(time));
        msgbox(msg,'Time Series Tools','modal')
    end
catch
    h.TableModel.resetEdit;
end