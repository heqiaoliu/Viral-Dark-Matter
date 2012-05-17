function sanityCheckSSIds(chartId)
% This is a function to sanity-check SSIDs.
% fill in details---

if(nargin<1)
    if(gcbh==-1) 
        return;
    end
    chartId = block2chart(gcbh);
end

% print out the ssIds of all objects belonging to the chart
chartHandle = find(sfroot, 'Id', chartId);
handles = find(chartHandle);
disp('Id    ssId');
disp('-------------------------------------');
for i = 1 : length(handles)
    if handles(i).Id ~= chartId
        disp([num2str(handles(i).Id) '    ' handleToSSId(handles(i))]);
    end
end

states = sf('get',chartId,'chart.states');
transitions = sf('get',chartId,'chart.transitions');
junctions = sf('get',chartId,'chart.junctions');
data = sf('DataIn',chartId);
events = sf('EventsIn',chartId);

stateSSIDNumbers = sf('get',states,'.ssIdNumber');
transitionSSIDNumbers = sf('get',transitions,'.ssIdNumber');
junctionSSIDNumbers = sf('get',junctions,'.ssIdNumber');
dataSSIDNumbers = sf('get',data,'.ssIdNumber');
eventSSIDNumbers = sf('get',events,'.ssIdNumber');

ssIdNumbers = [stateSSIDNumbers; transitionSSIDNumbers; junctionSSIDNumbers; dataSSIDNumbers; eventSSIDNumbers];

ssIdHWM = sf('get',chartId,'chart.ssIdHighWaterMark');

if(~isempty(ssIdNumbers))
    assert(max(ssIdNumbers)<=ssIdHWM, 'Max SS Id Number not under high watermark');
    assert(length(ssIdNumbers)==length(unique(ssIdNumbers)),'Repetitions in SSIDs');
    assert(min(ssIdNumbers)>0, 'Uninitialized SS Id Numbers');
end

