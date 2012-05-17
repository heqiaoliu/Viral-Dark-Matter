function rmselection(h,varargin)

% Copyright 2004-2005 The MathWorks, Inc.

%% Removes (keeps) observations where any data is selected

if length(h.Waves)==0
    return
end

complementSelection = (nargin>=2 && strcmp(varargin{1},'complement'));

%% Create transaction and get the handle to the event recorder
T = tsguis.transaction;
recorder = tsguis.recorder;

%% Find selected data and call tsreset to remove it
S = warning('off','all');
deletedTimes = cell(length(h.Waves),1);
for k=1:length(h.Waves)
    if h.Waves(k).isvisible
        data = h.Waves(k).DataSrc.Timeseries.Data;
        t = h.Waves(k).DataSrc.Timeseries.Time;
        I = [];
        if strcmp(h.State,'DataSelect') &&  ...
                ~isempty(h.Waves(k).View.SelectedPoints)
            if size(data,2)>1
                I = any(h.Waves(k).View.SelectedPoints')';
                if strcmp(recorder.Recording,'on')              
                    h.SelectionStruct.History = [h.SelectionStruct.History;...
                        {tsParseBufferStr(h.Waves(k).DataSrc.Timeseries.Name,'I# = any(I#'')'';')}];

                end
            else
                I = h.Waves(k).View.SelectedPoints;
            end

            % Clear selected for deleted points
            h.Waves(k).View.SelectedPoints = [];
        elseif strcmp(h.State,'TimeSelect')
            I = false(size(h.Waves(k).Data.Time));
            if strcmp(recorder.Recording,'on')
                h.SelectionStruct.History = {...
                tsParseBufferStr(h.Waves(k).DataSrc.Timeseries.Name,'I# = false(',size(h.Waves(k).Data.Time),');')};
            end
            for j=1:size(h.Waves(k).View.SelectedTimes,1)
                I = I | (h.Waves(k).Data.Time>=min(h.Waves(k).View.SelectedTimes(j,:)) & ...
                    h.Waves(k).Data.Time<max(h.Waves(k).View.SelectedTimes(j,:)));       
                if strcmp(recorder.Recording,'on')
                     h.SelectionStruct.History = [h.SelectionStruct.History; ...
                     {tsParseBufferStr(h.Waves(k).DataSrc.Timeseries.Name,...
                        'I# = I# | (#.Time>',min(h.Waves(k).View.SelectedTimes(j,:)),...
                         ' & #.Time<',max(h.Waves(k).View.SelectedTimes(j,:)),');')}];
                end
            end
            % Clear selection
            h.Waves(k).View.selectedtimes = [];
        end
        if ~isempty(I) && ((all(I) && ~complementSelection) || ...
                (all(~I) && complementSelection)) 
            errordlg('Removing all data will create an empty time series.',...
                'Time Series Tools','modal')
            return
        elseif ~isempty(I) && ((any(I) && ~complementSelection) || ...
                (any(~I) && complementSelection))
            if complementSelection
                ind = true(1,length(t));
                ind(find(I)+h.Waves(k).Data.Reference-1) = false;                   
                deletedTimes{k} = t(ind);           
            else
                deletedTimes{k} = t(find(I)+h.Waves(k).Data.Reference-1);
            end

            % If the recorder is on cache the M code in the transaction buffer
            if strcmp(recorder.Recording,'on')
                T.addbuffer(xlate('%% Selecting data for removal'));
                for row=1:length(h.SelectionStruct.History)
                    T.addbuffer(h.SelectionStruct.History{row});
                end
                if complementSelection
                   T.addbuffer(tsParseBufferStr(h.Waves(k).DataSrc.Timeseries.Name,...
                       '# = delsample(#,''index'',find(~I#));'),...
                       h.Waves(k).DataSrc.Timeseries);
                else
                   T.addbuffer(tsParseBufferStr(h.Waves(k).DataSrc.Timeseries.Name,...
                       '# = delsample(#,''index'',find(I#));'),...
                       h.Waves(k).DataSrc.Timeseries);
                end
            end

            % Add the timeseries to the transaction object
            T.ObjectsCell = {T.ObjectsCell{:},h.Waves(k).DataSrc.Timeseries}; 
        else
            % In this case there is a no-op, but a SourceChange must be fired
            % to force the clear of the selection to refresh (otherwise the
            % view will be out of sync with the selection)
            h.Waves(k).DataSrc.send('SourceChange');
        end
    end
end
warning(S);

%% Perform the deletion using delsample with the value option. This will
%% prevent data being removed twice if more than of the affected timeseries
%% is a child of a tscollection
for k=1:length(h.Waves)
    if ~isempty(deletedTimes{k}) && h.Waves(k).isvisible 
        h.Waves(k).DataSrc.Timeseries.delsample('value',deletedTimes{k});
    end
end
    
drawnow % Flush the event queue before activating

%% Store transaction
T.commit;
recorder.pushundo(T);