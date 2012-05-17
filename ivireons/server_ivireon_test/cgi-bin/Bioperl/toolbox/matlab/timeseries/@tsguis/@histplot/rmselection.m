function rmselection(h)

% Copyright 2004-2006 The MathWorks, Inc.

%% Deletes selected points and resets the selected status of deleted points
if length(h.Waves)==0 || ~strcmp(h.State,'IntervalSelect')
    return;
end

%% Create transaction
T = tsguis.transaction;
recorder = tsguis.recorder;

%% Find selected data and call tsreset to remove it
deletedTimes = cell(length(h.Waves),1);
for k=1:length(h.Waves)
    if h.Waves(k).isvisible
        data = h.Waves(k).DataSrc.Timeseries.Data;
        t = h.Waves(k).DataSrc.Timeseries.Time;

        % Collect indices in any selected Y interval
        I = false(size(data,1),1);
        for j=1:size(h.Waves(k).View.SelectedInterval,1)
            J = data>=min(h.Waves(k).View.SelectedInterval(j,:)) & ...
               data<=max(h.Waves(k).View.SelectedInterval(j,:));
            if size(J,2)>1
                J = any(J')';
            end
            I = I | J;
        end
        % Update data
        if ~isempty(I) && all(I)
            errordlg('Creating an empty time series by removing all rows is not allowed. For time series with >1 column this may have occurred because all the rows have at least one sample in the selected intervals(s)',...
                'Time Series Tools','modal')
            return
        elseif ~isempty(I) && any(I)
            deletedTimes{k} = t(I);
            %h.Waves(k).DataSrc.Timeseries.init(data(~I,:),t(~I));
        else
            return
        end

        T.ObjectsCell = {T.ObjectsCell{:}, h.Waves(k).DataSrc.Timeseries};
        %% If macro recorder is on write the code
        if strcmp(recorder.Recording,'on')
            T.addbuffer(['I = false([size(' h.Waves(k).DataSrc.Timeseries.Name '.Data,1),1]);']);
            for j=1:size(h.Waves(k).View.SelectedInterval,1)
               T.addbuffer(['J =  ' h.Waves(k).DataSrc.Timeseries.Name '.Data>=' ...
                   sprintf('%f',min(h.Waves(k).View.SelectedInterval(j,:))) ' & ' ...
                   h.Waves(k).DataSrc.Timeseries.Name '.Data<=' ...
                   sprintf('%f',max(h.Waves(k).View.SelectedInterval(j,:))) ';']);
               T.addbuffer('if size(J,2)>=2');
               T.addbuffer('   I = (I | any(J'')'');');
               T.addbuffer('else');
               T.addbuffer('   I = (I | J);');
               T.addbuffer('end');
            end
            T.addbuffer([h.Waves(k).DataSrc.Timeseries.Name ' = delsample(' h.Waves(k).DataSrc.Timeseries.Name ',''value'',' ...
                   h.Waves(k).DataSrc.Timeseries.Name '.Time(I));'],h.Waves(k).DataSrc.Timeseries);
        end

        % Clear current selection
        h.Waves(k).View.SelectedInterval = [];  
    end
end

%% Perform the deletion using delsample with the value option. This will
%% prevent data being removed twice if more than of the affected timeseries
%% is a child of a tscollection
for k=1:length(h.Waves)
    if h.Waves(k).isvisible && ~isempty(deletedTimes{k})
        h.Waves(k).DataSrc.Timeseries.delsample('value',deletedTimes{k});
    end
end

%% Clear existing selections and reset limits
drawnow % Flush the event queue before activating
h.draw

%% Store transaction
T.commit;
recorder.pushundo(T);