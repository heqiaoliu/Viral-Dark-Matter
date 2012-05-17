function select(h,arg1,arg2)

% Copyright 2004-2006 The MathWorks, Inc.

%% Select the points on the specified time series or axes. In the case where
%% arg1 is a time series arg2 is a logical array of the same size as the 
%% ordinate data which defined which points are selected. If arg 1 is an 
%% axes then arg 2 is an ordered pair defining the extent of the selected
%% rectangle
recorder = tsguis.recorder;

if isa(arg1,'tsdata.timeseries')
    
    % Parse args
    I = arg2;
    ts = arg1;
    
    %% Find the Wave for the specified time series
    idx = [];
    tsList = h.getTimeSeries;
    for k=1:length(tsList)
        if tsList{k} == ts
            idx = k;
            break
        end
    end

    %% Set the selected points in each view to the specified logical array
    if ~isempty(idx) && ~h.Waves(idx).Data.Exception
        L = h.Waves(idx).View.Curves; 
        h.Waves(idx).View.selectedpoints = ...
            I(h.Waves(idx).data.Reference:h.Waves(idx).data.Reference+length(h.Waves(idx).data.Time)-1,:);
        if h.Waves(idx).data.Reference+length(h.Waves(idx).data.Time)<size(I,1) && ...
                any(any(I(h.Waves(idx).data.Reference+length(h.Waves(idx).data.Time):end,:)))
            warndlg('Caching of large datasets limits selection only to the data in the display.',...
                'Time Series Tools','modal')
        end    
    end
elseif isa(handle(arg1),'axes')
    % parse args
    selected_rect = arg2;
    ax = arg1;
    % Allow sequential selection
    set(h.axesgrid,'NextPlot','add');

    % Find the enclosed data
    for k=1:length(h.Waves)
        if ~h.Waves(k).Data.Exception
            L = [];
            for j=1:length(h.Waves(k).View.Curves)
                if isequal(ancestor(h.Waves(k).View.Curves(j),'Axes'),double(ax))
                    L = [L;h.Waves(k).View.Curves(j)];
                end
            end
            for j=1:length(L)
                xdata = get(L(j),'xdata');
                ydata = get(L(j),'ydata');
                if ~isequal(h.Waves(k).Data.Ts,0) && strcmpi(h.Waves(k).View.Style,'stairs')
                   xdata = xdata(1:2:end);
                   ydata = ydata(1:2:end);
                end
                xdata = xdata(:);
                ydata = ydata(:); 
                miny = min(selected_rect(:,2));
                maxy = max(selected_rect(:,2));
                minx = min(selected_rect(:,1));
                maxx = max(selected_rect(:,1));

                I = (xdata>=minx & xdata<=maxx & ydata>=miny & ydata<=maxy);
                % The jth value is not necessarily the jth curve in the view
                % since the curves may be spread over different axes
                idx = find(L(j)==h.Waves(k).View.Curves);

                % If this selection stacks previous selections 'or' it with
                % those
                newslection = isempty(h.Waves(k).View.selectedpoints) ;
                if ~newslection
                    h.Waves(k).View.selectedpoints(:,idx) = ...
                        h.Waves(k).View.selectedpoints(:,idx) | I;                
                else
                     s1 =  [size(h.Waves(k).Data.Amplitude,1), ...
                                length(h.Waves(k).View.Curves)];
                    h.Waves(k).View.selectedpoints = false(s1);
                    h.Waves(k).View.selectedpoints(:,idx) = I;
                end

                if strcmp(recorder.Recording,'on')
                    if newslection || isempty(h.SelectionStruct.History)
                        h.SelectionStruct.History = [h.SelectionStruct.History; ...
                            {tsParseBufferStr(h.Waves(k).DataSrc.Timeseries.Name,'I# = false(size(#.Data));')}];
                    end
                    h.SelectionStruct.History = [h.SelectionStruct.History; ...
                            {tsParseBufferStr(h.Waves(k).DataSrc.Timeseries.Name,'ind = (#.Time>=',minx,');');...
                            tsParseBufferStr(h.Waves(k).DataSrc.Timeseries.Name,'ind = ind & (#.Time<=',maxx,');');...
                            tsParseBufferStr(h.Waves(k).DataSrc.Timeseries.Name,'ind = ind  & (#.Data(:,',idx,')>=',miny,');');...
                            tsParseBufferStr(h.Waves(k).DataSrc.Timeseries.Name,'ind = ind & (#.Data(:,',idx,')<=',maxy,');');...
                            tsParseBufferStr(h.Waves(k).DataSrc.Timeseries.Name,'I#(:,',idx,') = (I#(:,',idx, ') | ind);')}];                                         
                end
            end
        end
    end
end

%% Refresh
S = warning('off','all'); % Disable "Some data is missing @resppack warn..."
h.AxesGrid.LimitManager='off';
h.draw;
h.AxesGrid.LimitManager='on';
warning(S);
 