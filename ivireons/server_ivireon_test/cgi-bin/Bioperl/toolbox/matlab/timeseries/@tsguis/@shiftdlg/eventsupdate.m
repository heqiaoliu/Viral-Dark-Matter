function eventsupdate(h,varargin)

% Copyright 2004-2005 The MathWorks, Inc.

%% Method used to refresh the events in the shift dialog table
%% Additional argument restricts the update to a specfied time series
if ~isempty(h.ViewNode.Plot)
    tsList = h.ViewNode.Plot.getTimeSeries;   
    for k=1:length(tsList)
        % Add event array for this time series to the table
        if (nargin==1 || ~isa(varargin{1},'tsdata.timeseries')) || ...
                varargin{1} == tsList{k}
            if ~isempty(tsList{k}.Events) 
                eventnames = get(tsList{k}.Events(:),{'Name'});
                cached_name = char(h.Handles.tsTable.getValueAt(k-1,3));

                if strcmp(h.ViewNode.Plot.Absolutetime,'on')
                    h.Handles.tsTable.addEventArray(k-1,[{'[None]'};eventnames],...
                        [{h.ViewNode.Plot.StartDate};getTimeStr(tsList{k}.Events(:))]);
                else
                    h.Handles.tsTable.addEventArray(k-1,[{'[None]'};eventnames],...
                        [{'0.0'};getTimeStr(tsList{k}.Events(:),...
                        h.ViewNode.Plot.TimeUnits)]);
                end

                % If the previosly selected event is in the new list, restore
                % the selection
                if any(strcmp(cached_name,eventnames))
                    awtinvoke(h.Handles.tsTable,'setValueAt(Ljava/lang/Object;II)',...
                        java.lang.String(cached_name),k-1,3);
                end
            else
                if strcmp(h.ViewNode.Plot.Absolutetime,'on')
                    h.Handles.tsTable.addEventArray(k-1,{'[None]'},...
                        {h.ViewNode.Plot.StartDate});
                else
                    h.Handles.tsTable.addEventArray(k-1,{'[None]'},{'0.0'});
                end
            end    
                
        end
    end
end