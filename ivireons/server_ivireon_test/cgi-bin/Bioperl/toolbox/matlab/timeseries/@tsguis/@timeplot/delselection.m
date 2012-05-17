function delselection(h)

% Copyright 2004-2006 The MathWorks, Inc.
%  $Revision: 1.1.6.6 $ $Date: 2006/06/27 23:11:22 $

%% Deletes selected points and resets the selected status of deleted points


%% Create transaction and get the handle to the event recorder
recorder = tsguis.recorder;
T = tsguis.transaction;

%% Delete selected data
for k=1:length(h.Waves)
    if h.Waves(k).isvisible  
        data = h.Waves(k).DataSrc.Timeseries.Data;
        time = h.Waves(k).DataSrc.Timeseries.Time;
        wavedata = h.Waves(k).Data.Amplitude;
        wavetime = h.Waves(k).Data.Time;
        I = [];
        if strcmp(h.State,'DataSelect') && ...
                all(size(h.Waves(k).View.SelectedPoints)==size(wavedata))
            I = false(size(data));

            % Map data selection on the wave frame of reference to the
            % potentially wider time series frame of reference
            I(h.Waves(k).Data.Reference:(size(wavedata,1)+h.Waves(k).Data.Reference-1),:) = ...
                h.Waves(k).View.SelectedPoints;
            h.Waves(k).View.SelectedPoints = [];
        elseif strcmp(h.State,'TimeSelect')
            I1 = false(size(wavedata,1),1);
            if strcmp(recorder.Recording,'on')
                h.SelectionStruct.History = ...
                    tsParseBufferStr(h.Waves(k).DataSrc.Timeseries.Name,'I# = false(size(#.Time));');
            end
            for j=1:size(h.Waves(k).View.SelectedTimes,1)
                I1 = I1 | (wavetime>=min(h.Waves(k).View.SelectedTimes(j,:)) & ...
                    wavetime<max(h.Waves(k).View.SelectedTimes(j,:)));
                if strcmp(recorder.Recording,'on')
                    L = min(h.Waves(k).View.SelectedTimes(j,:));
                    U = max(h.Waves(k).View.SelectedTimes(j,:));
                    h.SelectionStruct.History = [h.SelectionStruct.History; ...
                       {tsParseBufferStr(h.Waves(k).DataSrc.Timeseries.Name,...
                       'I# = I# | (#.Time>=',L,' & #.Time< ',U,');')}];
                end
            end
            I1 = logical(double(I1)*ones([1 size(wavedata,2)]));
            if strcmp(recorder.Recording,'on')           
                h.SelectionStruct.History = [h.SelectionStruct.History; ...
                    {tsParseBufferStr(h.Waves(k).DataSrc.Timeseries.Name,...
                    'I# = logical(I#*ones(1,size(#.Data,2)));')}];
            end

            % Map data selection on the wave frame of reference to the
            % potentially wider time series frame of reference
            I = false(size(data));
            I(h.Waves(k).Data.Reference:(size(wavedata,1)+h.Waves(k).Data.Reference-1),:) = I1;

             % Clear selection
            h.Waves(k).View.selectedtimes = [];
        end

        if ~isempty(I) && any(any(I))
            data(I) = NaN;
            T.ObjectsCell = {T.ObjectsCell{:}, h.Waves(k).DataSrc.Timeseries};
            h.Waves(k).DataSrc.Timeseries.Data = data;
            drawnow % Flush the event queue before activating

            % If the recorder is on, cache the M code in the transaction buffer
            if strcmp(recorder.Recording,'on')
                T.addbuffer(xlate('%% Replacing data with NaNs'));
                for row=1:length(h.SelectionStruct.History)
                    T.addbuffer(h.SelectionStruct.History{row});
                end
                T.addbuffer(sprintf('%s.Data(I%s) = NaN;',h.Waves(k).DataSrc.Timeseries.Name,...
                    h.Waves(k).DataSrc.Timeseries.Name),h.Waves(k).DataSrc.Timeseries);
                h.SelectionStruct.History = {};
            end
        end
    end
end

%% Store transaction
T.commit;
recorder.pushundo(T);


