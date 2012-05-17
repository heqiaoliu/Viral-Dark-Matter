function addMenu(h,info)

% Copyright 2004-2008 The MathWorks, Inc.

% Assign callback for event removal menu
for k=1:numel(h.Points)
   cmenu = findobj(get(h.Points(k),'Uicontextmenu'),'Tag','RemoveEvent');
   set(cmenu,'Callback',{@localRemove h info.Data info.Carrier.DataSrc.Timeseries});
end

% Add event removal menu to data tips
for k=1:length(h.PointTips)
    if ~isempty(h.PointTips{k}) && ishghandle(h.PointTips{k})
        contextmenu = get(h.PointTips{k},'Uicontextmenu');
        if isempty(findobj(contextmenu,'Tag','TipRemoveEvent'))
            uimenu('Parent',get(h.PointTips{k},'Uicontextmenu'),'Label','Remove event',...
               'Callback',{@localRemove h info.Data info.Carrier.DataSrc.Timeseries},...
               'Tag','TipRemoveEvent');
        end
    end
end

function localRemove(es,ed,h,cdata,ts)


for k=1:length(ts.Events)
    if strcmp(cdata.EventName,ts.Events(k).Name) 
        % Create transaction
        T = tsguis.transaction;
        T.ObjectsCell = {ts};
        recorder = tsguis.recorder;

        if strcmp(recorder.Recording,'on')
             ev = ts.Events(k);
             T.addbuffer(xlate('%% Remove event'));
             T.addbuffer([ts.Name ' = delevent(', ts.Name ',''' ev.Name ''');'],ts); 
        end
        
        % Remove event
        ts.Events(k) = [];
        

        % Store transaction
        T.commit;
        recorder.pushundo(T);
        
        ts.send('datachange');
        
        return
    end
end