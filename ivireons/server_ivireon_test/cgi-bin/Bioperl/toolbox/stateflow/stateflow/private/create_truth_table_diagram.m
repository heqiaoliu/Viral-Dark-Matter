function errorCount = create_truth_table_diagram(fcnId)
%   Copyright 1995-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.13 $  $Date: 2010/01/25 23:23:46 $

    chartId = sf('get', fcnId, 'state.chart');

    % ted the editor. fixes 144039
    sf('LoseFocusFcn', chartId);

    chartIced = sf('get', chartId, 'chart.iced');
    if(chartIced)
        sf('set', chartId, 'chart.iced', 0);
    end

    % We need the chart to be open, otherwise it is not possible to create
    % the Junctions/Transitions of the truth-table
    % If we don't do this now it is done implicitly and we get graphics glitches
    sf('DrawLater', chartId);
    viewedObjectId = sf('get', chartId, '.viewObj'); 
    originalWindowPos = open_hidden_chart(chartId);
    
    function do_cleanup(fcnId, chartId, originalWindowPos, viewedObjectId, chartIced)
        % Restores critical drawing and window'ing state
        if(chartIced)
            sf('set', chartId, 'chart.iced', 1);
        end
        if ~is_truth_table_fcn(viewedObjectId)
            % G516712. Do not "open" a previously viewed truth table.
            sf('Open', viewedObjectId);
        end
        restore_hidden_chart(chartId, originalWindowPos);
        sf('DrawNow', chartId, fcnId);
    end

    % Critical section: try to generate the truth table
    try
        construct_tt_error('reset');
        try    
            try_create_truth_table_diagram(fcnId);
        catch InnerMatlabException
            construct_tt_error('add', fcnId, InnerMatlabException.message, 0); % this means we hit an unexpected error
        end 
        errorCount = construct_tt_error('get');        
    catch MatlabException
        do_cleanup(fcnId, chartId, originalWindowPos, viewedObjectId, chartIced);
        rethrow(MatlabException)
    end
    do_cleanup(fcnId, chartId, originalWindowPos, viewedObjectId, chartIced);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function originalWindowPos = open_hidden_chart(chartId)
    if(sf('get', chartId, '.visible'))
        originalWindowPos = 0;
    else
        originalWindowPos = sf('get', chartId, '.windowPosition');       
        newWindowPos = [-100000, -100000, 10, 10];
        figureHandle = sf('get', chartId, '.hg.figure');
 
        % Move window off-screen to ensure no one can see our
        % evil deeds (i.e.: generation of junctions/transitions)
        if(figureHandle ~= 0 && ishghandle(figureHandle))
            set(figureHandle, 'position', newWindowPos);
        else
            % Chart was never before opened... g501131   
            sf('set', chartId, '.windowPosition', newWindowPos);  
        end
    end
    sf('Open', chartId); 
end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function restore_hidden_chart(chartId, originalWindowPos)
    if(originalWindowPos ~= 0) 
        % Close the window, then restore the window position
        sf('set', chartId, '.visible', 0); 
        figureHandle = sf('get', chartId, '.hg.figure');
        if(figureHandle ~= 0)
            set(figureHandle, 'position', originalWindowPos);
            sf('set', chartId, '.windowPosition', originalWindowPos);     
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function try_create_truth_table_diagram(fcnId)

    [errorCount, table] = process_and_error_check_truth_table(fcnId);

    % Early return if there have been earlier errors
    if errorCount > 0
        return;
    end

    % Create truth table diagram
    clean_up_truth_table_content(fcnId);
    gen_truth_table_diagram(table);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function gen_temp_bool_vars(fcnObject, table)

    numP = size(table.predHeader, 1);

    for i = 1:numP    
        tmpData = Stateflow.Data(fcnObject);
        tmpData.Name = table.predVar{i};
        tmpData.Props.Type.Primitive = 'boolean';
        tmpData.Props.InitialValue = '0';
        tmpData.Scope = 'TEMPORARY_DATA';
        tmpData.Description = table.predHeader{i, table.idxPredDesp};

        autogenMap = create_autogen_map('condition',i);
        sf('set', tmpData.Id, ...
           'data.autogen.isAutoCreated', 1, ...
           'data.autogen.source', table.id, ...
           'data.autogen.mapping', autogenMap);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function gen_temp_flag_var(fcnObject, table)
% Make a temporary flagword variable for the genUsingBitOps implementation

    % --- Determine the variable type
    dType = 'int32';

    % --- Create the flags variable and set attributes
    tmpData = Stateflow.Data(fcnObject);
    tmpData.Name               = table.flagVar;
    tmpData.Props.Type.Primitive      = dType;
    tmpData.Props.InitialValue = '0';
    tmpData.Scope              = 'TEMPORARY_DATA';
    tmpData.Description        = 'Condition_1->bit0, Condition_2->bit1, etc.';

    sf('set', tmpData.Id, ...
        'data.autogen.isAutoCreated', 1, ...
        'data.autogen.source', table.id);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function labelStr = construct_predicate_eval_transition_label_string(index, table)

    predDesp = table.predHeader{index, table.idxPredDesp};
    predLabel = table.predHeader{index, table.idxPredLabel};
    predCode = table.predHeader{index, table.idxPredCode};

    labelStr = '';

    if ~isempty(predDesp)
        % insert predicate description as comments
        predDesp(strfind(predDesp, 10)) = ' '; % 10 is newline
        predDesp(strfind(predDesp, 13)) = ' '; % 13 is return
        labelStr = ['/* ' predDesp ' */' 10];
    end

    % Extract out //, % style comments from predicate code
    predCode = [predCode 10];
    [s t] = regexp(predCode, '(//|%)[^\n]*\n');
    for i = 1:length(s)
        labelStr = [labelStr predCode(s(i):t(i))];
    end
    predCode = regexprep(predCode, '(//|%)[^\n]*\n', char(10));
    predCode = regexprep(predCode, '^\s*(.*?)\s*$', '$1');

    % Trim off beginning and ending "[" "]" for backward compatibility
    predCode = regexprep(predCode, '^\[\s*(.*?)\s*\]$', '$1');

    labelStr = [labelStr table.predVar{index} ' = (' predCode ');'];

    if isempty(strfind(labelStr, 10))
        labelStr = ['{ ' labelStr ' }'];
    else
        labelStr = ['{' 10 labelStr 10 '}'];
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function labelStr = construct_predicate_flagword_label_string(table)

    fName = table.flagVar;
    boolVarNames = table.predVar;

    numC = length(boolVarNames);
    flg  = '\n{\n/* Construct flagword from conditions; Condition 1 is LSB */\n';

    % --- This method uses shifts -> 2 instructions, no branches
    flg = [ flg, fName, ' = ', boolVarNames{numC}, ';\n' ];
    for k = (numC-1):(-1):1
        flg = [ flg, fName, ' = ', fName, ' << 1c;\n' ];
        flg = [ flg, fName, ' |= ', boolVarNames{k}, ';\n' ];
    end
    flg = [ flg, '}\n'];
    flg = sprintf(flg);  % process all the \n characters
    labelStr = flg;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function labelStr = construct_condition_transition_label_string(index, table)

    % --- Build logical expression from predicates to use as code or comment
    m = size(table.predBody, 1);
    boolVarNames = table.predVar;
    condStr       = '';
    logicalAndStr = ' && ';
    andLen        = length(logicalAndStr);

    for k = 1:m
        boolVal = table.predBody(k, index);
        if boolVal > 0
            condStr = [condStr, boolVarNames{k}, logicalAndStr];
        elseif boolVal == 0
            condStr = [condStr, '!', boolVarNames{k}, logicalAndStr];
        else
            continue; % dont care
        end
    end

    if ~isempty(condStr)
        condStr = condStr(1:end-andLen);
    end

    % --- Generate the conditions
    if table.useFlags
        % --- Generate using bitwise AND for predicates
        %
        %     The decision column algorithm implementation is as follows:
        %
        %     1) Using bitwise AND, mask OFF all the don't cares and unused bits of
        %        predicate flagword, and mask ON all the 1/0 values
        %
        %     2) Using == on the result, see if it matches the "care" 1/0 values
        %
        %     This implementation requires that the chart has "enable C-like bit
        %     operations" option turned ON and that there are 31 or fewer
        %     predicates to fit in a 32-bit or smaller flagword.

        flagCaresMask   = table.flagMask(index);
        flagDecisionSet = table.flagValue(index);

        flagVarName        = table.flagVar;
        flagDecisionSetStr = sprintf('%d', flagDecisionSet);
        flagCaresMaskStr   = sprintf('%d', flagCaresMask);
        labelStr = [ '[(( ', flagVarName, ' & ', flagCaresMaskStr, ' ) == ', flagDecisionSetStr, ' )'];

        if flagCaresMask == 0
            % Make the all-don't-cares default column
            labelStr = '/* Default */';
        else
            labelStr = [ labelStr, ']   /* (', condStr, ') */'];
        end

    else
        % --- Generate using logical AND for predicates
        if isempty(condStr)
            % all don't care column.
            labelStr = '/* Default */';
        else
            labelStr = [ '[', condStr, ']'];
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function labelStr = construct_action_transition_label_string(actionIdx, table)

    actionDesp = table.actions{actionIdx, table.idxActDesp};
    actionCode = table.actions{actionIdx, table.idxActCode};
    actionLabel = table.actions{actionIdx, table.idxActLabel};

    labelStr = [];

    if ~isempty(actionLabel)
        labelStr = ['/* ' '''' actionLabel '''' ':'];
    end

    if ~isempty(actionDesp)
        % insert action description as comments
        actionDesp(strfind(actionDesp, 10)) = ' '; % flatten newline
        actionDesp(strfind(actionDesp, 13)) = ' '; % flatten return

        if isempty(labelStr)
            labelStr = '/* ';
        end

        labelStr = [labelStr actionDesp];
    end

    if ~isempty(labelStr)
        labelStr = [labelStr ' */' 10];
    end

    labelStr = [labelStr actionCode];

    if isempty(strfind(labelStr, 10))
        labelStr = ['{ ' labelStr ' }'];
    else
        labelStr = ['{' 10 labelStr 10 '}'];
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function gen_truth_table_diagram(table)

    % --- magic numbers for drawing the diagram
    segmentMargin = 30; % margin between two action transitions
    x = 20; y = 25; % The start point

    [numP, numT] = size(table.predBody);

    rt = sfroot;
    containerObj = rt.idToHandle(table.id);

    gen_temp_bool_vars(containerObj, table);

    % Create the default transition
    [t, j] = add_trans_to_junc(containerObj, [x y], 6, [x y+segmentMargin], 12, table.id, []);

    % Create the INIT transition
    if table.initActIdx > 0
        labelStr = construct_action_transition_label_string(table.initActIdx, table);
        autogenMap = create_autogen_map('action',table.initActIdx);
        [t, j] = append_vertical_transition_to_junction(containerObj, j, labelStr, table.id, autogenMap);
    end

    % Add transitions to calculate predicates
    for i = 1:numP
        labelStr = construct_predicate_eval_transition_label_string(i, table);
        autogenMap = create_autogen_map('condition',i);
        [t, j] = append_vertical_transition_to_junction(containerObj, j, labelStr, table.id, autogenMap);
    end

    % Add transition to calculate predicate flag word
    if table.useFlags
        gen_temp_flag_var(containerObj, table);

        % --- Add transition to build predicates into a flag word
        labelStr = construct_predicate_flagword_label_string(table);
        [t, j] = append_vertical_transition_to_junction(containerObj, j, labelStr, table.id, []);
    end

    % Append action transitions for each action column in predicate table
    %avoidCollisionPos = j.Position.Center + [0 segmentMargin];

    % Only do this when predicate table is not empty
    if ~isempty(table.predBody)
        % Following two values are used for finalization
        endJuncs = cell(numT,1);
        rightBound = 0;

        for i = 1:numT
            % Adding the connective transition
            %[t, j] = add_trans_to_junc(containerObj, j, 6, avoidCollisionPos, 12, containerObj.Id, []);

            condStr = construct_condition_transition_label_string(i, table);
            autogenMap = create_autogen_map('decision',i);
            [t, jn, maxVBound] = append_horizontal_transition_to_junction(containerObj, j, condStr, table.id, autogenMap);

            actions = table.predAction{i};
            for k = 1:length(actions)
                actionStr = construct_action_transition_label_string(actions(k), table);
                autogenMap = create_autogen_map('action',actions(k));
                [t, jn, vBound] = append_horizontal_transition_to_junction(containerObj, jn, actionStr, table.id, autogenMap);

                if vBound > maxVBound
                    maxVBound = vBound;
                end
            end

            endJuncs{i} = jn;
            if jn.Position.Center(1) > rightBound
                rightBound = jn.Position.Center(1);
            end

            % Adding the connective transition
            if i < numT || ~table.hasDefault
                avoidCollisionPos = j.Position.Center;
                avoidCollisionPos(2) = vBound + segmentMargin;
                [t, j] = add_trans_to_junc(containerObj, j, 6, avoidCollisionPos, 12, table.id, []);
            else
                j = jn;
            end
        end

        if table.finalActIdx > 0
            % Stretch out all end junctions to the same y location, and connect them
            for i = 1:length(endJuncs)
                endJuncs{i}.Position.Center(1) = rightBound;
                if i > 1
                    connect_juncs_by_trans(containerObj, endJuncs{i-1}, 6, endJuncs{i}, 12, table.id, []);
                end
            end

            if ~table.hasDefault
                % Create the connective junction, and make the connections
                jc = Stateflow.Junction(containerObj);
                jc.Position.Center = [rightBound j.Position.Center(2)];
                jc.Position.Radius = junc_radius;
                connect_juncs_by_trans(containerObj, endJuncs{end}, 6, jc, 12, table.id, []);
                connect_juncs_by_trans(containerObj, jc, 9, j, 3, table.id, []);
            end
        end
    end

    % the FINAL transition
    if table.finalActIdx > 0    
        % Create the finalization junction
        labelStr = construct_action_transition_label_string(table.finalActIdx, table);
        autogenMap = create_autogen_map('action',table.finalActIdx);
        [t, j] = append_vertical_transition_to_junction(containerObj, j, labelStr, table.id, autogenMap);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [T, J] = append_vertical_transition_to_junction(containerObj, sourceJunc, labelString, autogenSourceId, autogenMap)

    factor = 1.86; % factor to adjust transition length based on fontsize and number of lines in label string.
    marginXTransLabel = 10; % the margin between transition line and label string.

    % Determine number of lines by searching the newline character 10
    numLines = length(strfind(labelString, 10)) + 1;

    transLength = numLines * font_size * factor;

    x = sourceJunc.Position.Center(1);
    y = sourceJunc.Position.Center(2);

    dstJuncPos = [x y + transLength];
    [T, J] = add_trans_to_junc(containerObj, sourceJunc, 6, dstJuncPos, 12, autogenSourceId, autogenMap);

    T.LabelString = labelString;
    labelPos = T.LabelPosition;
    T.LabelPosition = [x+marginXTransLabel y+(transLength-labelPos(4))/2 labelPos(3:4)];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [T, J, verticalBound] = append_horizontal_transition_to_junction(containerObj, sourceJunc, labelString, autogenSourceId, autogenMap)

    hFactor = 0.68; % factor to adjust horizontal transition length by length of label string and font size
    vFactor = 1.68;

    % Get the maximum line length by number of characters
    newLinePos = [0 find(labelString == 10 | labelString == 13) length(labelString)+1];
    maxLineLen = 0;
    for i = 2:length(newLinePos)
        thisLineLen = newLinePos(i) - newLinePos(i-1);
        if thisLineLen > maxLineLen
            maxLineLen = thisLineLen;
        end
    end

    % Determine number of lines by searching the newline character 10
    numLines = length(strfind(labelString, 10)) + 1;

    transLength = maxLineLen * font_size * hFactor;

    x = sourceJunc.Position.Center(1);
    y = sourceJunc.Position.Center(2);
    dstJuncPos = [x + transLength y];

    [T J] = add_trans_to_junc(containerObj, sourceJunc, 3, dstJuncPos, 9, containerObj.Id, autogenMap);

    T.LabelString = labelString;
    labelPos = T.LabelPosition;
    leftMargin = (transLength - labelPos(3)) / 2;
    marginYTransLabel =  3;

    % Put label string under transition
    T.LabelPosition = [x+leftMargin y+marginYTransLabel labelPos(3:4)];
    verticalBound = y + marginYTransLabel + numLines*font_size*vFactor;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function T = connect_juncs_by_trans(containerObj, sJ, sOc, dJ, dOc, autogenSourceId, autogenMap)

    T = Stateflow.Transition(containerObj);
    T.Source = sJ;
    T.SourceOClock = sOc;
    T.Destination = dJ;
    T.DestinationOClock = dOc;
    T.DrawStyle = 'smart';
    sf('set', T.Id, 'transition.autogen.isAutoCreated', 1);
    sf('set', T.Id, 'transition.autogen.source', autogenSourceId);
    sf('set', T.Id, 'transition.autogen.mapping', autogenMap);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [T, J] = add_trans_to_junc(containerObj, s, sOc, dPos, dOc, autogenSourceId, autogenMap)
% containerObj: containerObj to put in new trans and junc
% s: source, if not handle -> T is default trans with sourceEndPoint = s
% sOc: sourceOClock
% dPos: new junc (destination of new trans) position.
% dOc: destinationOClock
% T,J: return handles of newly added trans and junc

    J = Stateflow.Junction(containerObj);
    J.Position.Center = dPos;
    J.Position.Radius = junc_radius;

    T = Stateflow.Transition(containerObj);
    T.Destination = J;
    T.DestinationOClock = dOc;

    sf('set', T.Id, 'transition.autogen.isAutoCreated', 1);
    sf('set', T.Id, 'transition.autogen.source', autogenSourceId);
    sf('set', T.Id, 'transition.autogen.mapping', autogenMap);
    sf('set', J.Id, 'junction.autogen.isAutoCreated', 1);
    sf('set', J.Id, 'junction.autogen.source', autogenSourceId);
    sf('set', J.Id, 'junction.autogen.mapping', autogenMap);

    if ishandle(s)
        T.Source = s;
    else
        T.SourceEndPoint = s;
    end
    T.SourceOClock = sOc;
    T.DrawStyle = 'smart';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function autogenMap = create_autogen_map(type, index)

    switch type
    case 'condition'
        typeIdx = 0;
    case 'action'
        typeIdx = 1;
    case 'decision'
        typeIdx = 2;
    otherwise
        error('Stateflow:UnexpectedError','Unknown type');
    end

    autogenMap.type= typeIdx;
    autogenMap.index = index;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function val = junc_radius
% Radius for truthtable diagram junction radius
    val = 5;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function val = font_size
% Font size used in diagram
    val = 12;
end
