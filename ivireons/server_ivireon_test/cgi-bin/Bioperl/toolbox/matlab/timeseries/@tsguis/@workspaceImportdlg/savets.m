function flag=savets(h)
% SAVETS imports the selected time and data into tstool

% this method is used to create one or more timeseries objects based on the
% user selections in the data import dialog.  If the time vector is in
% absolute date/time format, it will be automatically converted into proper
% MATLAB-supported date/time format.

% Author: Rong Chen 
%  Copyright 2005-2010 The MathWorks, Inc.
%  $Revision: 1.1.6.11 $ $Date: 2010/04/21 21:33:59 $

% -------------------------------------------------------------------------
% pre-save check
% -------------------------------------------------------------------------
if isempty(h.IOData.SelectedRows) || isempty(h.IOData.SelectedColumns)
    errordlg('No data block has been selected.  To select data, go back to Step 2.',...
        'Time Series Tools','modal');
    flag=false;
    return;
end
ButtonSameName=[];
if ~isempty(h.IOData.SelectedVariableInfo)
    dataOriginal=evalin('base',h.IOData.SelectedVariableInfo.varname);
else
    flag=false;
    return;
end
if get(h.Parent.Handles.PNLoption,'SelectedObject')==h.Parent.Handles.RADIOsingleNEW
    % create a new timeseries object
    % get the timeseries object name from the edit box
    UserInputName=strtrim(get(h.Parent.Handles.EDTsingleNEW,'String'));
%     if ~isvarname(UserInputName)
%         errordlg('This is not a valid MATLAB variable name.',...
%             'Time Series Tools','modal');
%         flag=false;
%         return
%     end
    set(h.Parent.Handles.EDTsingleNEW,'String',UserInputName);
    % check if there exists a time series object with the same name
    tsgui = tstool;
    G = tsgui.TSnode.getChildren;
    alltsobjects = {};
    for k = 1:length(G)
        if strcmp(class(G(k)),'tsguis.tsnode')
            alltsobjects{end+1} = G(k).Timeseries; %#ok<AGROW>
        end
    end
    %alltsobjects = get(tsgui.Tsnode.getChildren,{'Timeseries'});
    if ~isempty(alltsobjects)
        for i=1:length(alltsobjects)
            if strcmp({alltsobjects{i}.Name},UserInputName)
                ButtonSameName = questdlg('A time series object with the same name already exists in tstool.  Do you want to replace its contents with the current selection?', ...
                    'Time Series Tools', 'Replace', 'Abort', 'Replace');
                drawnow;
                ButtonSameName = xlate(ButtonSameName);
                switch ButtonSameName
                    case xlate('Replace')
                        % delete the old time series object in tstool
                    case xlate('Abort')                    
                        flag=false;
                        return;
                end
            end                            
        end
    end
elseif get(h.Parent.Handles.PNLoption,'SelectedObject')==h.Parent.Handles.RADIOsingleINSERT
    % import into an existing timeseries object with name given
    % in the combo box
    % get the name
    str=get(h.Parent.Handles.COMBsingleINSERT,'String');
    UserInputName=str{get(h.Parent.Handles.COMBsingleINSERT,'Value')};
    if isempty(UserInputName)
        errordlg('No existing time series is selected','Time Series Tools','modal');
        flag=false;
        return
    end
else
    if get(h.Parent.Handles.COMBmultipleNEW,'Value')==1
        % use strings in a row or column as timeseries names
        try
            UserInputName=str2double(strtrim(get(h.Parent.Handles.EDTmultipleNEW,'String')));
        catch me %#ok<NASGU>
            errordlg('The row index for the row containing variable names should be an integer.',...
                'Time Series Tools','modal');
            flag=false;
            return
        end
    else
        % use the given name + suffix as timeseries names
        UserInputName=strtrim(get(h.Parent.Handles.EDTmultipleNEW,'String'));
%         if ~isvarname(UserInputName)
%             errordlg('The common part of the variable name should be a valid MATLAB variable name.',...
%                 'Time Series Tools','modal');
%             flag=false;
%             return
%         end
    end
end
EnumTimeUnits={'weeks', 'days', 'hours', 'minutes','seconds', 'milliseconds', 'microseconds', 'nanoseconds'};

if strcmp(computer,'GLNXA64') || strcmp(computer,'GLNX86')
    h.Handles.bar=waitbar(10/100,xlate('Importing Time Series Object(s), Please Wait...'));
else
    h.Handles.bar=waitbar(10/100,xlate('Importing Time Series Object(s), Please Wait...'),'WindowStyle','modal');
end
% -------------------------------------------------------------------------
% get time vector and remove blank points
% -------------------------------------------------------------------------
ind=get(h.Handles.COMBtimeSource,'Value');
if ind==1
    % from the same workspace variable
    % default
    SelectedRows=h.IOData.SelectedRows; %#ok<NASGU>
    SelectedColumns=h.IOData.SelectedColumns; %#ok<NASGU>
    % check blank time points, remove them if required, and get 'time' and
    % 'timeFormat'
    if get(h.Handles.COMBdataSample,'Value')==1
        % time vector is stored as a column
        tmpColStr=get(h.Handles.COMBtimeIndex,'String');
        ColStrValue=str2double(tmpColStr{get(h.Handles.COMBtimeIndex,'Value')});
        timeValue=dataOriginal(h.IOData.SelectedRows,ColStrValue);
        [SelectedIndex,flag]=h.checkBlankTimePoint(timeValue,'column');
        if ~flag
            delete(h.Handles.bar);
            return;
        end
        SelectedRows=h.IOData.SelectedRows(SelectedIndex);
        SelectedColumns=h.IOData.SelectedColumns(h.IOData.SelectedColumns~=get(h.Handles.COMBtimeIndex,'Value'));            
        time=timeValue(SelectedIndex); %#ok<NASGU>
        h.checkTimeFormat(h.IOData.SelectedVariableInfo.varname,'column',tmpColStr{get(h.Handles.COMBtimeIndex,'Value')});
        % replace the stored time format with the selected time format
        % timeFormat=h.IOData.formatcell.columnIsAbsTime
        [time, timeFormat]=getTimeColumn(h,SelectedRows);
        if timeFormat>=0
            timeFormat=h.IOData.formatcell.matlabFormatIndex(get(h.Handles.COMBtimeSheetFormat,'Value'));
            %time=datestr(time,timeFormat);
            %time=mat2cell(time,ones(1,size(time,1)),size(time,2));
        end
    else
        % time vector is stored as a row
        tmpRowStr=get(h.Handles.COMBtimeIndex,'String');
        RowStrValue=str2double(tmpRowStr{get(h.Handles.COMBtimeIndex,'Value')});
        timeValue=dataOriginal(RowStrValue,h.IOData.SelectedColumns);
        [SelectedIndex,flag]=h.checkBlankTimePoint(timeValue,'row');
        if ~flag
            delete(h.Handles.bar);
            return;
        end
        SelectedColumns=h.IOData.SelectedColumns(SelectedIndex);
        SelectedRows=h.IOData.SelectedRows(h.IOData.SelectedRows~=get(h.Handles.COMBtimeIndex,'Value'));            
        time=timeValue(SelectedIndex); %#ok<NASGU>
        h.checkTimeFormat(h.IOData.SelectedVariableInfo.varname,'row',tmpRowStr{get(h.Handles.COMBtimeIndex,'Value')});
        % replace the stored time format with the selected time format
        % timeFormat=h.IOData.formatcell.rowIsAbsTime;
        [time,timeFormat]=h.getTimeRow(h.IOData.SelectedColumns);
        if timeFormat>=0
            timeFormat=h.IOData.formatcell.matlabFormatIndex(get(h.Handles.COMBtimeSheetFormat,'Value'));
            % time=datestr(time,timeFormat);
            % time=mat2cell(time,ones(1,size(time,1)),size(time,2));
        end
    end
    if isempty(time)
        % errordlg('Invalid time point(s) exist in your current selection.  To reselect it, go back to Step 2.','Time Series Tools');
        flag=false;
        delete(h.Handles.bar);
        return;
    end
    % time pretreatment
%     if timeFormat>=0
%         if timeFormat==13 || timeFormat==14 || timeFormat==15 || timeFormat==16
%             [year,month,day,hour,minute,second]=datevec(time);
%             time=hour*3600+minute*60+second;
%         end
%     end
elseif ind==2
    % manual time vector
    SelectedRows=h.IOData.SelectedRows;
    SelectedColumns=h.IOData.SelectedColumns;
    if get(h.Handles.COMBuseFormat,'Value')==1
        % absolute date/time format
        % check start time
        try
            MatlabFormat=h.IOData.formatcell.matlabFormatString{get(h.Handles.COMBtimeManualFormat,'Value')};
            startTime=datestr(datenum(get(h.Handles.EDTtimeManualStart,'String')),MatlabFormat);
        catch me %#ok<NASGU>
            errordlg('The start time must be a date string.  Go back to Step 2 to change the start time.',...
                'Time Series Tools','modal');
            flag=false;
            delete(h.Handles.bar);
            return
        end
        % check interval
        try
            interval=eval(get(h.Handles.EDTtimeManualInterval,'String'));
        catch me %#ok<NASGU>
            errordlg('The time interval must be a numeric value. Go back to Step 2 to change the time interval.',...
                'Time Series Tools','modal');
            delete(h.Handles.bar);
            flag=false;
            return
        end
        if isnan(interval)
            errordlg('The time interval must be a numeric value. Go back to Step 2 to change the time interval.',...
                'Time Series Tools','modal');
            flag=false;
            delete(h.Handles.bar);
            return
        end
        % check number of sample
        samples=str2double(get(h.Handles.EDTtimeManualEnd,'String'));
        if samples==0 || isnan(samples)
            errordlg('The length of time series is zero. Go back to Step 2 to select the desired data block.',...
                'Time Series Tools','modal');
            flag=false;
            delete(h.Handles.bar);
            return
        end
        time=localGetAbsTimeArray(h,startTime,interval,samples,MatlabFormat);
        timeFormat=h.IOData.formatcell.matlabFormatIndex(get(h.Handles.COMBtimeManualFormat,'Value'));
    else
        % relative time
        % check start time
        startTime=str2double(get(h.Handles.EDTtimeManualStart,'String'));
        if isnan(startTime)
            errordlg('The start time must be a numeric value.  Go back to Step 2 to change the Start Time.',...
                'Time Series Tools','modal');
            flag=false;
            delete(h.Handles.bar);
            return
        end
        % check interval
        try
            interval=eval(get(h.Handles.EDTtimeManualInterval,'String'));
        catch me %#ok<NASGU>
            errordlg('The time interval must be a numeric value. Go back to Step 2 to change the time interval.',...
                'Time Series Tools','modal');
            delete(h.Handles.bar);
            flag=false;
            return
        end
        if isnan(interval)
            errordlg('The time interval must be a double value.  Go back to Step 2 to change the Interval field.',...
                'Time Series Tools','modal');
            flag=false;
            delete(h.Handles.bar);
            return
        end
        % check number of sample
        samples=str2double(get(h.Handles.EDTtimeManualEnd,'String'));
        if samples==0 || isnan(samples)
            errordlg('The length of time series is zero. Go back to Step 2 to select the desired data block.',...
                'Time Series Tools','modal');
            flag=false;
            delete(h.Handles.bar);
            return
        end
        time=(startTime:interval:startTime+interval*(samples-1));
        timeFormat=-1;
    end
elseif ind==3
    % time vector from a workspace variable
    if ~isempty(h.IOData.timeFromWorkspace)
        timeValue=h.IOData.timeFromWorkspace;
        timeFormat=h.IOData.timeFormatFromWorkspace;
        time=timeValue; %#ok<NASGU>
        SelectedRows=h.IOData.SelectedRows;
        SelectedColumns=h.IOData.SelectedColumns;
        if get(h.Handles.COMBdataSample,'Value')==1
            if length(timeValue)~=length(h.IOData.SelectedRows)
                % a sample is a row
                errordlg('The length of data block is not compatible with the length of the time vector.',...
                    'Time Series Tools','modal');
                flag=false;
                delete(h.Handles.bar);
                return
            end
            [SelectedIndex,flag]=h.checkBlankTimePoint(timeValue,'column');
            if ~flag
                delete(h.Handles.bar);
                return;
            end
            SelectedRows=h.IOData.SelectedRows(SelectedIndex);
            time=timeValue(SelectedIndex);
            % SelectedColumns=h.IOData.SelectedColumns(find(h.IOData.SelectedColumns~=get(h.Handles.COMBtimeIndex,'Value')));            
        else
            if length(timeValue)~=length(h.IOData.SelectedColumns)
                % a sample is a row
                errordlg('The length of data block is not compatible with the length of the time vector.',...
                    'Time Series Tools','modal');
                flag=false;
                delete(h.Handles.bar);
                return
            end
            [SelectedIndex,flag]=h.checkBlankTimePoint(timeValue,'row');
            if ~flag
                delete(h.Handles.bar);
                return;
            end
            SelectedColumns=h.IOData.SelectedColumns(SelectedIndex);
            time=timeValue(SelectedIndex);
            % SelectedRows=h.IOData.SelectedRows(find(h.IOData.SelectedRows~=get(h.Handles.COMBtimeIndex,'Value')));            
        end            
        if isempty(time)
            errordlg('Invalid times selected.  To select again, go back to Step 2.',...
                'Time Series Tools','modal');
            flag=false;
            delete(h.Handles.bar);
            return;
        end
        % time pretreatment
        if timeFormat>=0
            if timeFormat==13 || timeFormat==14 || timeFormat==15 || timeFormat==16
                [~,~,~,hour,minute,second]=datevec(time);
                time=hour*3600+minute*60+second;
            end
        end
    else
        flag=false;
        delete(h.Handles.bar);
        return;
    end
end
if ishandle(h.Handles.bar)      
   waitbar(40/100,h.Handles.bar);
end
% -------------------------------------------------------------------------
% get data block
% -------------------------------------------------------------------------
if iscell(dataOriginal)
    try
        data=cell2mat(dataOriginal(SelectedRows,SelectedColumns));
    catch me %#ok<NASGU>
        errordlg('Data must contain numeric values only.','Time Series Tools',...
            'modal');
        flag=false;
        delete(h.Handles.bar);
        return
    end
    if ~isnumeric(data) && ~islogical(data)
        errordlg('Data must contain numeric values only.','Time Series Tools','modal');
        flag=false;
        delete(h.Handles.bar);
        return
    end
elseif isnumeric(dataOriginal) || islogical(dataOriginal)
    data=dataOriginal(SelectedRows,SelectedColumns);
else
    errordlg('Data must contain numeric values only.','Time Series Tools','modal');
    flag=false;
    delete(h.Handles.bar);
    return
end
if isempty(data)
    errordlg('Selected data block is empty.  To reselect it, go back to Step 2.',...
        'Time Series Tools','modal');
    flag=false;
    delete(h.Handles.bar);
    return
end
if ishandle(h.Handles.bar)      
   waitbar(70/100,h.Handles.bar);
end
% -------------------------------------------------------------------------
% sort based on time if it is relative time
% -------------------------------------------------------------------------
if isvector(time) && size(time,2)>1
    time = time';
end
if ~iscell(time)
    [time sortindex]=sort(time);
    if get(h.Handles.COMBdataSample,'Value')==1
        % in the excel sheet, a sample is a row
        data=data(sortindex,:);
    else
        % in the excel sheet, a sample is a column
        data=data(:,sortindex);
    end
else
    try
    % get abs time in [year mon day hour min sec] format and sort them
        [~, sortindex] = sortrows(round(datevec(time,timeFormat)));
    catch me %#ok<NASGU>
        errordlg(xlate('Variable contains time strings with an invalid format. Specify a different variable as the time vector or define it manually.'),...
            'Time Series Tools','modal');
        flag = false;
        delete(h.Handles.bar);
        return
    end
    if get(h.Handles.COMBdataSample,'Value')==1
        % in the excel sheet, a sample is a row
        time=time(sortindex,:);
        data=data(sortindex,:);
    else
        % in the excel sheet, a sample is a column
        time=time(sortindex,:);
        data=data(:,sortindex);
    end
end

% -------------------------------------------------------------------------
% check duplicated time points
% -------------------------------------------------------------------------
[~,~,tmp3]=unique(time);
index=diff(tmp3);
if sum(index==0)>0
    % duplicated time points exist
    ButtonDuplicated = questdlg('The time vector contains duplicated time points.  For the samples related to the same time points, you can either select the last sample or the mean of the samples to import.', ...
        'Time Series Tools', 'Select the last', 'Select the average', 'Abort', 'Select the average');
    drawnow;
    ButtonDuplicated = xlate(ButtonDuplicated);
    switch ButtonDuplicated
        case xlate('Select the last')
            time=time([true;~(index==0)]);
            if get(h.Handles.COMBdataSample,'Value')==1
                % in the excel sheet, a sample is a row
                data=data([~(index==0);true],:);
            else
                % in the excel sheet, a sample is a column
                data=data(:,[~(index==0);true]);
            end
        case xlate('Select the average')
            time=time([true;~(index==0)]);
            if get(h.Handles.COMBdataSample,'Value')==1
                % in the excel sheet, a sample is a row
                k=1;
                for i=1:length(index)
                    if index(i)==0
                        data(i+1,:)=(data(i,:)*k+data(i+1,:))/(k+1);
                        k=k+1;
                    else
                        k=1;
                    end
                end
                data=data([~(index==0);true],:);
            else
                % in the excel sheet, a sample is a column
                k=1;
                for i=1:length(index)
                    if index(i)==0
                        data(:,i+1)=(data(:,i)*k+data(:,i+1))/(k+1);
                        k=k+1;
                    else
                        k=1;
                    end
                end
                data=data(:,[~(index==0);true]);
            end
        case xlate('Abort')
            flag=false;
            delete(h.Handles.bar);
            return
    end
end
if ishandle(h.Handles.bar)      
    waitbar(80/100,h.Handles.bar);
end
% -------------------------------------------------------------------------
% create/update time series object(s)
% -------------------------------------------------------------------------
if get(h.Parent.Handles.PNLoption,'SelectedObject')==h.Parent.Handles.RADIOsingleNEW
    % create timeseries object
    try
        if ~strcmp(ButtonSameName,xlate('Replace'))
            if get(h.Handles.COMBdataSample,'Value')==1
                % in the excel sheet, a sample is a row
                ts=tsdata.timeseries(data,time,'Name',UserInputName,'IsTimeFirst',true);
            else
                % in the excel sheet, a sample is a column
                ts=tsdata.timeseries(data',time,'Name',UserInputName,'IsTimeFirst',true);
            end
            if timeFormat>=0
                if timeFormat~=13 && timeFormat~=14 && timeFormat~=15 && timeFormat~=16
                    ts.timeInfo.Format=h.IOData.formatcell.matlabFormatString{h.IOData.formatcell.matlabFormatIndex == timeFormat};
                else
                    ts.timeInfo.Format=h.IOData.formatcell.matlabFormatString{h.IOData.formatcell.matlabFormatIndex == 0};
                end
            elseif timeFormat==-1
                if ind == 1
                    ts.timeInfo.units=EnumTimeUnits{get(h.Handles.COMBtimeSheetFormat,'Value')};
                elseif ind ==2
                    ts.timeInfo.units=EnumTimeUnits{get(h.Handles.COMBtimeManualFormat,'Value')};
                elseif ind ==3
                    ts.timeInfo.units=EnumTimeUnits{get(h.Handles.COMBtimeWorkspaceFormat,'Value')};
                end
            end
            tstool(ts);
        else
            tsgui = tstool;
            ts = tsgui.Tsnode.getChildren('Label',UserInputName).Timeseries;
            ts.timeinfo.Startdate='';
            ts.timeinfo.Format='';
            if get(h.Handles.COMBdataSample,'Value')==1
                % in the excel sheet, a sample is a row
                ts.init(data,time,'Name',UserInputName,'IsTimeFirst',true);
            else
                % in the excel sheet, a sample is a column
                ts.init(data',time,'Name',UserInputName,'IsTimeFirst',true);
            end
            if timeFormat>=0
                if timeFormat~=13 && timeFormat~=14 && timeFormat~=15 && timeFormat~=16
                    ts.timeInfo.Format=h.IOData.formatcell.matlabFormatString{h.IOData.formatcell.matlabFormatIndex == timeFormat};
                else
                    ts.timeInfo.Format=h.IOData.formatcell.matlabFormatString{h.IOData.formatcell.matlabFormatIndex == 0};
                end
            elseif timeFormat==-1
                if ind == 1
                    ts.timeInfo.units=EnumTimeUnits{get(h.Handles.COMBtimeSheetFormat,'Value')};
                elseif ind ==2
                    ts.timeInfo.units=EnumTimeUnits{get(h.Handles.COMBtimeManualFormat,'Value')};
                elseif ind ==3
                    ts.timeInfo.units=EnumTimeUnits{get(h.Handles.COMBtimeWorkspaceFormat,'Value')};
                end
            end
        end
    catch me
        errordlg(sprintf('%s\n\n%s',xlate('Error in creating time series object in tstool :'),me.message),...
            'Time Series Tools','modal');
        flag=false;
        delete(h.Handles.bar);
        return
    end
elseif get(h.Parent.Handles.PNLoption,'SelectedObject')==h.Parent.Handles.RADIOsingleINSERT
    % get the timeseries object from the gui
    tsgui = tstool;
    ts = tsgui.Tsnode.getChildren('Label',UserInputName).Timeseries;
    % check if the two time vectors are the same: if they are the same
    % then insert data, if they are not the same size, abort the
    % operation, if they have the same size but not the same value, ask
    % user which time vector to choose
    try
        tsTime=ts.getAbsTime;
    catch %#ok<CTCH>
        tsTime=ts.time;
    end
    if length(tsTime)==length(time)
        % time vector has the same size, now compare values
        if isequal(tsTime,time)
            % same time vector
            ButtonName = 'Use the old time vector';
        else
            % two time vectors have different values
            ButtonName = questdlg('The new time vector you selected has a different length from the old time vector used in the existing timeseries object.', ...
                'Time Series Tools', 'Use the old time vector', 'Use the new time vector', 'Abort', 'Use the old time vector');
        end
    else
        % time vector has different sizes
        ButtonName = questdlg('The new time vector you selected is different from the old time vector used in the existing timeseries object.', ...
            'Time Series Tools', 'Replace', 'Abort', 'Replace');
    end
    drawnow;
    ButtonName = xlate(ButtonName);
    
    % create timeseries object
    switch ButtonName,
        case xlate('Use the old time vector')
            %
        case xlate('Use the new time vector')
            tmpdata=ts.data;
            [time tmpIndex]=sort(time);
            if get(h.Handles.COMBdataSample,'Value')==2
                data=data(:,tmpIndex);
            else
                data=data(tmpIndex,:);
            end
            ts.timeinfo.Startdate='';
            ts.timeinfo.Format='';
            ts.init(tmpdata,time);
            if timeFormat>=0
                if timeFormat~=13 && timeFormat~=14 && timeFormat~=15 && timeFormat~=16
                    ts.timeInfo.Format=h.IOData.formatcell.matlabFormatString{h.IOData.formatcell.matlabFormatIndex == timeFormat};
                else
                    ts.timeInfo.Format=h.IOData.formatcell.matlabFormatString{h.IOData.formatcell.matlabFormatIndex == 0};
                end
            elseif timeFormat==-1
                if ind == 1
                    ts.timeInfo.units=EnumTimeUnits{get(h.Handles.COMBtimeSheetFormat,'Value')};
                elseif ind ==2
                    ts.timeInfo.units=EnumTimeUnits{get(h.Handles.COMBtimeManualFormat,'Value')};
                elseif ind ==3
                    ts.timeInfo.units=EnumTimeUnits{get(h.Handles.COMBtimeWorkspaceFormat,'Value')};
                end
            end
        case xlate('Replace')
            ts.timeinfo.Startdate='';
            ts.timeinfo.Format='';
            ts.init(data,time);
            if timeFormat>=0
                if timeFormat~=13 && timeFormat~=14 && timeFormat~=15 && timeFormat~=16
                    ts.timeInfo.Format=h.IOData.formatcell.matlabFormatString{h.IOData.formatcell.matlabFormatIndex == timeFormat};
                else
                    ts.timeInfo.Format=h.IOData.formatcell.matlabFormatString{h.IOData.formatcell.matlabFormatIndex == 0};
                end
            elseif timeFormat==-1
                if ind == 1
                    ts.timeInfo.units=EnumTimeUnits{get(h.Handles.COMBtimeSheetFormat,'Value')};
                elseif ind ==2
                    ts.timeInfo.units=EnumTimeUnits{get(h.Handles.COMBtimeManualFormat,'Value')};
                elseif ind ==3
                    ts.timeInfo.units=EnumTimeUnits{get(h.Handles.COMBtimeWorkspaceFormat,'Value')};
                end
            end
            flag=true;
            delete(h.Handles.bar);
            return
        case xlate('Abort')
            flag=false;
            delete(h.Handles.bar);
            return;
    end
    if ts.IsTimeFirst
        % in the existing timeseries, a sample is a row
        if get(h.Handles.COMBdataSample,'Value')==2
            % in the excel sheet, a sample is a column
            ts.data=[ts.data data'];
        else
            % in the excel sheet, a sample is a row
            ts.data=[ts.data data];
        end
    else
        % in the existing timeseries, a sample is a column
        if get(h.Handles.COMBdataSample,'Value')==2
            % in the excel sheet, a sample is a column
            data=reshape(data,[size(data,1) 1 size(data,2)]);
            ts.data=cat(1,ts.data,data);
        else
            % in the excel sheet, a sample is a row
            data=data';
            data=reshape(data,[size(data,1) 1 size(data,2)]);
            ts.data=cat(1,ts.data,data);
        end
    end
else
    failed_count=0;
    % multiple timeseries
    if get(h.Handles.COMBdataSample,'Value')==2
        % a sample is a column
        for i=1:length(SelectedRows)
            % save timeseries
            try
                if get(h.Parent.Handles.COMBmultipleNEW,'Value')==1
                    % use a row or column as timeseries name
                    tmpName=dataOriginal(i,UserInputName);
                    if iscell(tmpName)
                        tmpName=cell2mat(tmpName);
                    end
                    if ~ischar(tmpName) %|| ~isvarname(tmpName)
                        failed_count=failed_count+1;
                        continue;
                    end
                else
                    tmpName=strcat(UserInputName,num2str(i));
                end
                if get(h.Handles.COMBdataSample,'Value')==2
                    % a sample is a column, use gridfirst=false
                    ts=tsdata.timeseries(data(i,:),time,'Name',tmpName,'IsTimeFirst',false);
                else
                    % a sample is a row, use gridfirst=true
                    ts=tsdata.timeseries(data(i,:),time,'Name',tmpName,'IsTimeFirst',true);
                end
                if timeFormat>=0
                    if timeFormat~=13 && timeFormat~=14 && timeFormat~=15 && timeFormat~=16
                        ts.timeInfo.Format=h.IOData.formatcell.matlabFormatString{h.IOData.formatcell.matlabFormatIndex == timeFormat};
                    else
                        ts.timeInfo.Format=h.IOData.formatcell.matlabFormatString{h.IOData.formatcell.matlabFormatIndex == 0};
                    end
                elseif timeFormat==-1
                    if ind == 1
                        ts.timeInfo.units=EnumTimeUnits{get(h.Handles.COMBtimeSheetFormat,'Value')};
                    elseif ind ==2
                        ts.timeInfo.units=EnumTimeUnits{get(h.Handles.COMBtimeManualFormat,'Value')};
                    elseif ind ==3
                        ts.timeInfo.units=EnumTimeUnits{get(h.Handles.COMBtimeWorkspaceFormat,'Value')};
                    end
                end
                tstool(ts);
            catch me
                errordlg(sprintf('%s\n\n%s','Error in creating time series object in tstool :',me.message),...
                    'Time Series Tools','modal');
                flag=false;
                delete(h.Handles.bar);
                return
            end
        end
    else
        % a sample is a row
        for j=1:length(SelectedColumns)
            % for each measurement
            % get data
            try
                if get(h.Parent.Handles.COMBmultipleNEW,'Value')==1
                    % use a row or column as timeseries name
                    tmpName=dataOriginal(UserInputName,j);
                    if iscell(tmpName)
                        tmpName=cell2mat(tmpName);
                    end
                    if ~ischar(tmpName) %|| ~isvarname(tmpName)
                        failed_count=failed_count+1;
                        continue;
                    end
                else
                    % use the given name + suffix as the timeseries name
                    tmpName=strcat(UserInputName,num2str(j));
                end
                if get(h.Handles.COMBdataSample,'Value')==2
                    % a sample is a column, use gridfirst=false
                    ts=tsdata.timeseries(data(:,j),time,'Name',tmpName,'IsTimeFirst',false);
                else
                    % a sample is a row, use gridfirst=true
                    ts=tsdata.timeseries(data(:,j),time,'Name',tmpName,'IsTimeFirst',true);
                end
                if timeFormat>=0
                    if timeFormat~=13 && timeFormat~=14 && timeFormat~=15 && timeFormat~=16
                        ts.timeInfo.Format=h.IOData.formatcell.matlabFormatString{h.IOData.formatcell.matlabFormatIndex == timeFormat};
                    else
                        ts.timeInfo.Format=h.IOData.formatcell.matlabFormatString{h.IOData.formatcell.matlabFormatIndex == 0};
                    end
                elseif timeFormat==-1
                    if ind == 1
                        ts.timeInfo.units=EnumTimeUnits{get(h.Handles.COMBtimeSheetFormat,'Value')};
                    elseif ind ==2
                        ts.timeInfo.units=EnumTimeUnits{get(h.Handles.COMBtimeManualFormat,'Value')};
                    elseif ind ==3
                        ts.timeInfo.units=EnumTimeUnits{get(h.Handles.COMBtimeWorkspaceFormat,'Value')};
                    end
                end
                tstool(ts);
            catch me
                errordlg(sprintf('%s\n\n%s','Error in creating time series object in tstool :',me.message),...
                    'Time Series Tools','modal');
                flag=false;
                delete(h.Handles.bar);
                return
            end
        end
    end
    if failed_count>0
        msgbox('Not all data was imported. Invalid variable names were specified.',...
            'Time Series Tools','modal');
    end
end
if ishandle(h.Handles.bar)      
   waitbar(100/100,h.Handles.bar);
end
%populate combobox with current timeseries objects in the base workspace
tsgui = tstool;
%alltsobjects = get(tsgui.Tsnode.getChildren,{'Timeseries'});
G = tsgui.TSnode.getChildren;
alltsobjects = {};
for k = 1:length(G)
    if strcmp(class(G(k)),'tsguis.tsnode')
        alltsobjects{end+1} = G(k).Timeseries; %#ok<AGROW>
    end
end
if ~isempty(alltsobjects)
    strCell={};
    for i=1:length(alltsobjects)
        strCell=[strCell;{alltsobjects{i}.Name}]; %#ok<AGROW>
    end
else
    strCell={''};
end
set(h.Parent.Handles.COMBsingleINSERT,'String',strCell,'Value',1);
flag=true;

delete(h.Handles.bar);

function array=localGetAbsTimeArray(h,startTime,interval,samples,MatlabFormat)
% format 4, 5, 6, 
startValue=datevec(startTime,MatlabFormat);
switch h.IOData.formatcell.matlabFormatIndex(get(h.Handles.COMBtimeManualFormat,'Value'))
    case {0 13 14 21} 
        %'dd-mmm-yyyy HH:MM:SS' 'HH:MM:SS' 'HH:MM:SS PM' 'mmm.dd,yyyy HH:MM:SS'
%         endValue=startValue;
%         endValue(6)=endValue(6)+min(1,interval)*(samples-1);
%         allDateNum = datenum(startValue):min(1,interval)/86400:datenum(endValue);
%         array=datestr(allDateNum);
%         array=mat2cell(array,ones(1,size(array,1)),size(array,2));
        startValue=datenum(startValue);
        endValue=startValue+max(1,interval)*(samples-1)/86400;
        array=datestr(startValue:max(1,interval)/86400:endValue);
        array=mat2cell(array,ones(1,size(array,1)),size(array,2));
    case {1 2 6 22 23}
        endValue=startValue;
        endValue(3)=endValue(3)+interval*(samples-1);
        array=datestr(datenum(startValue):interval:datenum(endValue));
        array=mat2cell(array,ones(1,size(array,1)),size(array,2));
    case {15 16}
        endValue=startValue;
        endValue(5)=endValue(5)+interval*(samples-1);
        array=datestr(datenum(startValue):interval/1440:datenum(endValue));
        array=mat2cell(array,ones(1,size(array,1)),size(array,2));
end
