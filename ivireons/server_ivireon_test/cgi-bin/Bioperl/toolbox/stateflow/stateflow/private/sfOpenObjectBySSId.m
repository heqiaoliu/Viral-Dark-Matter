function result = sfOpenObjectBySSId(SSId)

result = '';

% Ensure that truth-tables are updated 
% does it have performance impact ?
blockPath = traceabilityManager('parseSSId', SSId);
if isempty(blockPath)
    return;
end
try
    % get handle to the chart
    blockH = get_param(blockPath,'handle');
    chartId = block2chart(blockH);
    update_truth_tables(chartId);
catch err
end

% get handle to the object
[handle,auxInfo,blockH] = ssIdToHandle(SSId);

if isempty(handle)
    error('Stateflow:TraceabilityError', 'Handle not found');
end

% get the object id
objectId = handle.Id;

chartId = getChartOf(objectId);
if chartId == 0
    error('Stateflow:TraceabilityError', 'Chart not found');
end


% The following ensures that the correct library instance is opened
% so that the title bar shows the correct path
if(is_an_sflink(blockH))
    sf('set',chartId,'.activeInstance',blockH);
else
    sf('set',chartId,'.activeInstance',0.0);
end

% handle eml function
if (is_eml_based_chart(objectId) || is_eml_based_fcn(objectId)) && ~isempty(auxInfo)
    
    % get start position
    startPos = str2double(auxInfo);
    if isnan(startPos)
        startPos = 1;
    end
    
    if is_eml_truth_table_fcn(objectId)
        sf('Open', objectId, startPos);
    else
        % open eml editor
        sf('Open', objectId);
    
        % highlight the line; endPos is -2 to indicate we want to highlight the
        % line corresponding to the auxInfo
        eml_man('highlight', objectId, startPos - 1, -2);
    end
    
    return;
end

% open and highlight the object
sf('Open', objectId);
sf('Select', chartId, []);
sf('Highlight', chartId, []);
if(highlightable(objectId))
    sf('Highlight', chartId, objectId);
end


% returns true if the object is highlightable;
% ignore for data and event
function result = highlightable(objectId)

STATE_ISA = sf('get', 'default', 'state.isa' );
TRANSITION_ISA = sf('get', 'default', 'transition.isa' );
JUNCTION_ISA = sf('get', 'default', 'junction.isa' );

objectIsA = sf('get', objectId, '.isa');
switch objectIsA
    case {STATE_ISA, TRANSITION_ISA, JUNCTION_ISA}
        result = true;
    otherwise
        result = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function isLink = is_an_sflink(blockH)
%
% Determine if a block is a link
%
if isempty(get_param(blockH, 'ReferenceBlock')),
    isLink = 0;
else
    isLink = 1;
end;

