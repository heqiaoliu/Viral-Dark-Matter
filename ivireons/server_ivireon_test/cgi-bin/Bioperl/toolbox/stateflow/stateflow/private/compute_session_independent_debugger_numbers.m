function compute_session_independent_debugger_numbers(machineId,debug)

%   Copyright 2007-2009 The MathWorks, Inc.

% This function uses a DFS scheme to compute and set .number property for
% all data, states, transitions, junctions

if(nargin<2)
    debug = false;
end
if(ischar(machineId))
    machineId = sf('find','all','machine.name',machineId);
end

% by default, this property is read-only, change it so it is writable
sf('flag','state.number','write');
sf('flag','transition.number','write');
sf('flag','junction.number','write');
sf('flag','data.number','write');

compute_numbers_for_machine(machineId,debug);

% linkMachines = sfprivate('get_link_machine_list',machineId, 'sfun');
% for i = 1:length(linkMachines)
%     linkMachine = sf('find',sf('MachinesOf'),'machine.name',linkMachines{i});
%     compute_numbers_for_machine(linkMachine,debug);
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function compute_numbers_for_machine(machineId,debug)

allData = sf('DataOf',machineId);
sf('set',allData,'.number',[0:length(allData)-1]'); %#ok<NBRAK>

% G502209: renumber events as well
allEvents = sf('EventsOf',machineId);
sf('set',allEvents,'.number',[0:length(allEvents)-1]');  %#ok<NBRAK>

charts = sf('get',machineId,'machine.charts');

for i=1:length(charts)
    compute_numbers_for_chart(charts(i),debug,length(allData));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function compute_numbers_for_chart(chart,debug,machineDataCount)

% all data in a chart are numbered contiguously from 0 with an offset
% provided by machineDataCount
allData = sf('DataIn',chart);
assign_numbers(allData,machineDataCount);

% G502209: all events in a chart are numbered contiguously from 0 without an offset
% as the offset will have to be computed during codegen time and 
% added later. 
allEvents = sf('EventsIn',chart);
assign_numbers(allEvents,0);

% this returns an array of state/graphical-fcn/box Ids
% DFS order + within every level, based on alphabetical order
allStates = sf('AllSubstatesIn',chart);

% the following are flat lists of all transitions and junctions 
% the order is completely random. chart_real_transitions function
% will only return the simple and super transitions and skip the
% sub-transitions
allTransitions = chart_real_transitions(chart);
danglingTransitions = sf('find',allTransitions,'.dst.id',0);
connectedTransitions = sf('find',allTransitions,'~.dst.id',0);
assert((length(danglingTransitions)+length(connectedTransitions))==length(allTransitions));

allJunctions = sf('get',chart,'chart.junctions');

newCode = true;

if(newCode)
    % make sure dangling transitions get their numbers sorted to the end
    transOffset = assign_numbers_based_on_ssids(connectedTransitions,0);
    assign_numbers_based_on_ssids(danglingTransitions,transOffset);
    
    assign_numbers_based_on_ssids(allJunctions,0);
    
    % make sure noteboxes are numbered after states.
    realStates = sf('find',allStates,'state.isNoteBox',0);
    noteboxStates = sf('find',allStates,'state.isNoteBox',1);
    assert((length(realStates)+length(noteboxStates))==length(allStates));
    
    stateOffset = assign_numbers(realStates,0);
    assign_numbers(noteboxStates,stateOffset);
end

if(debug)
    sf('flag','junction.labelString','write');
    for i=1:length(allStates)
        append_number(allStates(i));
    end
    for i=1:length(allTransitions)
        append_number(allTransitions(i));
    end
    for i=1:length(allJunctions)
        append_number(allJunctions(i));
    end
end

function offset = assign_numbers_based_on_ssids(objects,offset)

if(isempty(objects))
    return;
end

ssIds = sf('get',objects,'.ssIdNumber');
[~,indices] = sort(ssIds);

objects  = objects(indices);
offset = assign_numbers(objects,offset);


function offset = assign_numbers(objects,offset)

sIndex = offset;
eIndex = offset+length(objects)-1;
sf('set',objects,'.number',[sIndex:eIndex]'); %#ok<NBRAK>
offset = eIndex+1;


function append_number(thisObject)

[labelString,number] = sf('get',thisObject,'.labelString','.number');

[s,e] = regexp(labelString,' /\* #\d+ \*/$');
if(~isempty(s) && ~isempty(e))
    labelString(s:e) = [];
end

labelString = sprintf('%s /* #%d */',labelString,number);

sf('set',thisObject,'.labelString',labelString);
    
    
