function filt(h,ts,colinds,T)
%FEVAL

% Copyright 2004-2008 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2008/07/18 18:44:13 $

%% Initialize recorder
recorder = tsguis.recorder;

%% No-op for vacuous time series
if ts.TimeInfo.length<2
    return
end

%% Filtering
% TO DO: What if the first or last point contains a NaN?
% Discrte transfer fcn
if strcmp(h.Filter,'transfer')
    ts.filter(h.Bcoeffs,h.Acoeffs,colinds);
    if strcmp(recorder.Recording,'on')
        T.addbuffer(xlate('%% Filtering time series'));
        T.addbuffer([ts.Name ' = filter(' ts.Name ',[' num2str(h.Bcoeffs) '],[' ...
             num2str(h.Acoeffs) '],[' num2str(colinds) ']);'],ts);
    end
% Ideal continuous
elseif strcmp(h.Filter,'ideal')
    unitfactor = tsunitconv(ts.TimeInfo.Units,h.ViewNode.getPlotTimeProp('TimeUnits'));
    ts.idealfilter(unitfactor*h.range,h.Band,colinds);
    if strcmp(recorder.Recording,'on')
        T.addbuffer(xlate('%% Filtering time series'));
        T.addbuffer([ts.Name '= idealfilter(' ts.Name ',[' ...
                num2str(h.Range*unitfactor) '],''' h.Band ''',[' num2str(colinds) ']);'],ts);
    end 
% First order
elseif strcmp(h.Filter,'firstord')
    unitfactor = tsunitconv(ts.TimeInfo.Units,h.ViewNode.getPlotTimeProp('TimeUnits'));
    % Non-uniformly sampled
    if isnan(ts.TimeInfo.Increment)
           Ts = (ts.TimeInfo.End-ts.TimeInfo.Start)/ts.TimeInfo.length;
           ts.resample(linspace(ts.TimeInfo.Start,ts.TimeInfo.End,ts.TimeInfo.length));
           ts.filter(Ts/(h.Timeconst*unitfactor+Ts),...
               [1 -h.Timeconst*unitfactor/(h.Timeconst*unitfactor+Ts)],colinds);
           if strcmp(recorder.Recording,'on')
               T.addbuffer(['Ts = (' ts.Name '.TimeInfo.End-' ts.Name '.TimeInfo.Start)/' ...
                   ts.Name '.TimeInfo.length;'],ts);
               T.addbuffer([ts.Name ' = resample(' ts.Name ',linspace(' ts.Name '.TimeInfo.Start,' ...
                   ts.Name '.TimeInfo.End,' ts.Name '.TimeInfo.length));']);
               T.addbuffer([ts.Name ' = filter(' ts.Name ',Ts/('  num2str(h.Timeconst*unitfactor) '+Ts),[1 -' ...
                   num2str(h.Timeconst*unitfactor) '/(' num2str(h.TimeConst*unitfactor) '+Ts)],[' ...
                   num2str(colinds) ']);']);
           end   
    % Uniformly sampled
    else 
        try
            ts.filter(ts.TimeInfo.Increment/(h.Timeconst*unitfactor+ts.TimeInfo.Increment),...
               [1 -h.Timeconst*unitfactor/(h.Timeconst*unitfactor+ts.TimeInfo.Increment)],colinds);
        catch me
            err1 = me.message;
            if strcmp(err1.identifier,'timeseries:filter:allnans')  
                msg = 'Filtering operation failed because one of the selected time series contains NaN(s) at the beginning or end.';
            else
                msg = sprintf('Filtering operation failed. Error from filter methods was %s', err1.message);
            end
            errordlg(xlate(msg),'Time Series Tools','modal')
            return
        end
        if strcmp(recorder.Recording,'on')
            T.addbuffer([ts.Name ' = filter(' ts.Name ',' ts.Name ...
                '.TimeInfo.Increment/(' num2str(h.Timeconst*unitfactor) ...
                '+' ts.Name '.TimeInfo.Increment),[1 -' num2str(h.Timeconst*unitfactor) ...
                '/(' num2str(h.Timeconst*unitfactor) ...
                '+' ts.Name '.TimeInfo.Increment)],[' num2str(colinds) ']);'],ts);
        end
    end
end
    