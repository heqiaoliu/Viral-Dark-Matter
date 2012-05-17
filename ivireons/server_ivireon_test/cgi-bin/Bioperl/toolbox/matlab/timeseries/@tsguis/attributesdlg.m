function varargout = attributesdlg(h,action)

% Copyright 2006 The MathWorks, Inc.

import javax.swing.*; 
import com.mathworks.mwswing.*;
import com.mathworks.toolbox.timeseries.*;
import java.util.*;

attributesDlg = AttributesDialog.getInstance;
switch action 
    case 'ok'
        if isa(h,'timeseries')
            h = struct('Timeseries',h);
            varargout{1} = localOK(h,attributesDlg);
        else
            localOK(h,attributesDlg);
        end
    case 'help'
        tsDispatchHelp('d_data_attributes','modal',attributesDlg);
    case 'open'
        if ~ischar(h) && isa(h,'timeseries')
            outVec = localSetQualData(h);    
        else
            outVec = localSetQualData(h.Timeseries);
            attributesDlg.fNode = h;
            % Make sure table shows new quality codes before showing.
            % Modal-ness of this dialog may prevent the new outVec
            % updating the table
            attributesDlg.setQualityData(outVec);
            awtinvoke(attributesDlg,'setVisible(Z)',true)
        end
        varargout{1} = outVec;
end


function thisTs = localOK(h,attributesDlg)

import com.mathworks.mwswing.*;

%% OK button callback

%% Write the contents of the data quality table to the QualityInfo property
%% of the time series object

%% No-op on empty timeseries
if isempty(h.Timeseries)
    errordlg(xlate('Cannot modify the attributes of an empty time series'),...
        'Time Series Tools','modal')
    return
end

%% Get table data and remove empty rows
codes = double(attributesDlg.getCodes);
descr = cell(attributesDlg.getDescriptions);
I = find(codes<-128 | codes>127);
if ~isempty(I)
    % Throw an error, the exception will be caught in java
    error(sprintf('Invalid code in row %d. All codes must be integers between -128 and 127',I(1)));
end

%% Check for unique codes
if length(unique(codes))<length(codes) || length(unique(descr))<length(descr) 
    % Throw an error, the exception will be caught in java
    error(xlate('Specify unique quality codes and descriptions.'));
end
    
%% Create transaction
if ishandle(h.Timeseries)
    T = tsguis.transaction;
    T.ObjectsCell = {h.Timeseries};
    recorder = tsguis.recorder;

    % Update the time series
    h.Tslistener.Enabled = 'off'; % Make sure datachange event is activated only once
end
h.Timeseries.QualityInfo.Code = codes;
h.Timeseries.QualityInfo.Description = descr;
h.Timeseries.DataInfo.Units = char(attributesDlg.fTextUnits.getText);
if ishandle(h.Timeseries) && strcmp(recorder.Recording,'on')
    T.addbuffer('%% Metadata changes');
    if length(codes)>=1
        codeStr = '[';
        codeDescr = '{';
        for k=1:length(codes)-1
            codeStr = [codeStr,sprintf('%d;',codes(k))];
            codeDescr = [codeDescr,'''', descr{k},''';'];
        end
        codeStr = [codeStr,sprintf('%d];',codes(end))];  
        codeDescr = [codeDescr,'''',descr{end},'''};'];
        T.addbuffer([h.Timeseries.Name '.QualityInfo.Code = ' codeStr],[]);
        T.addbuffer([h.Timeseries.Name '.QualityInfo.Description = ' codeDescr],[]);
    end
    T.addbuffer([h.Timeseries.Name '.DataInfo.Units = ''' ...
        char(attributesDlg.fTextUnits.getText), ''';'],h.Timeseries);
end
if isempty(h.Timeseries.Quality) && ...
        length(h.Timeseries.QualityInfo.Code)>0 % Set default
    h.Timeseries.Quality = h.Timeseries.QualityInfo.Code(1)*...
        ones([h.Timeseries.TimeInfo.Length 1]);
    if ishandle(h.Timeseries) && strcmp(recorder.Recording,'on')
        T.addbuffer([h.Timeseries.Name '.Quality = ' ...
            h.Timeseries.Name  '.QualityInfo.Code(1)*ones([' ...
            h.Timeseries.Name '.TimeInfo.Length 1]);'],h.Timeseries);
    end
elseif ~isempty(h.Timeseries.Quality) && isempty(h.Timeseries.QualityInfo.Code) 
    if ishandle(h.Timeseries) && strcmp(recorder.Recording,'on')
        T.addbuffer([h.Timeseries.Name '.Quality = [];'],h.Timeseries);
    end
    h.Timeseries.Quality = [];
elseif ~isempty(h.Timeseries.Quality) && length(h.Timeseries.QualityInfo.Code)>0 % Reset deleted codes to the first code
    h.Timeseries.Quality(~ismember(h.Timeseries.Quality,h.Timeseries.QualityInfo.Code)) = ...
        h.Timeseries.QualityInfo.Code(1);
    if ishandle(h.Timeseries) && strcmp(recorder.Recording,'on')
        T.addbuffer([h.Timeseries.Name '.Quality(~ismember(' h.Timeseries.Name '.Quality,' ...
            h.Timeseries.Name '.QualityInfo.Code)) = ' ...
            h.Timeseries.Name '.QualityInfo.Code(1);'],h.Timeseries);
    end
end
if ishandle(h.Timeseries)
    h.Tslistener.Enabled = 'on';
    h.Timeseries.send('datachange')
end

%% Update the interpolation method
interpInd = attributesDlg.fCombInterp.getSelectedIndex+1;
interpMethods = {'linear','zoh'};
interpMethod = interpMethods{interpInd};
h.Timeseries.DataInfo.Interpolation = tsdata.interpolation(interpMethod);

%% Store transaction
if ishandle(h.Timeseries)
    if strcmp(recorder.Recording,'on')
            T.addbuffer([h.Timeseries.Name '.DataInfo.Interpolation = tsdata.interpolation(''' ...
        interpMethod ''');'],h.Timeseries);
    end
    T.commit;
    recorder.pushundo(T);
    % Update the GUI
    h.Timeseries.send('datachange')
end

thisTs = h.Timeseries;

function outVec = localSetQualData(ts)

import java.util.*;

outVec = Vector;
for k=1:length(ts.QualityInfo.Code)
    rowVec = Vector;
    rowVec.addElement(java.lang.Integer(ts.QualityInfo.Code(k)));
    rowVec.addElement(java.lang.String(ts.QualityInfo.Description{k}));
    outVec.addElement(rowVec);
end