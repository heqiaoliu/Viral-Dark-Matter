function x = sfhelp(arg1,arg2)
%SFHELP brings up online help and documentation for Stateflow.
%
%       See also STATEFLOW, SFSAVE, SFPRINT, SFEXIT, SFNEW, SFEXPLR.

% Fred Smith
%   Copyright 1995-2010 The MathWorks, Inc.
%   $Revision: 1.34.4.16 $  $Date: 2010/05/20 03:35:25 $

% Internal Documentation:
% SFHELP(UDD)
%     - load the help page for the properties of that udd object
% SFHELP(TOPIC)
%     - load the help page for the relevant TOPIC
% SFHELP(UDD,TOPIC)
%     - load the help for the TOPIC but remap topic based on UDD_OBJ
%     Stateflow objects go to Stateflow help
%     Embedded MATLAB objects go to Embedded MATLAB help
%
% SFHELP
%   When called from a callback (gcbo ~= []) in the Stateflow UI dispatch
%   to the appropriate topic.
%   If called from the command-line open up the default Stateflow help
%   page.
% 
% SFHELP('helpdesk')
%   Open the main MATLAB help
%
% SFHELP('cycle_error')
%   Open a model demonstrating how to avoid this error.
%
% SFHELP('backup_warning_error')
%   Open a model demonstrating how to avoid this error.
%
% SFHELP('-topics')
%   Return a list of possible topics.
%
%
% Issues found:
%   1. Help for truth table and eM functions brings up function help.
%   2. Box help brings up State help?
%   3. Help for truth table block dialog brings up CHART_DIALOG help.
% 
%
topic = '';
obj = [];

check_doc_installed;

if nargin==0
    topic = topic_from_context;
else
    if ischar(arg1)
        topic = arg1;
    else
        obj = arg1;
    end
    
    if nargin==2
        if ischar(arg2)
            topic = arg2;
        else
            error('Stateflow:UnexpectedError','The second argument to SFHELP must be a string.');
        end
    end
end

if ~isempty(obj)
    
    if iscell(obj)
        obj = obj{1};
    end
    
    if isempty(topic)
        topic = topic_from_obj(obj);
    else
        topic = remap_topic_based_on_obj(obj,topic);
    end
end
    
result = execute_topic(topic);

if nargout == 1
  x = result;
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function check_doc_installed
docRootDir = docroot;
% Show error if help docs not found
if (isempty(docRootDir))
    htmlFile = fullfile(matlabroot,'toolbox','local','helperr.html');
    if (exist(htmlFile,'file') ~=2)
        error('Stateflow:UnexpectedError','Could not locate help system home page.\nPlease make sure the help system files are installed.');
    end
    display_file(htmlFile);
end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function topic = topic_from_obj(obj)

cls = classhandle(obj);

if (isequal(get(get(cls, 'Package'), 'Name'), 'Stateflow'))
    % We've got a stateflow object
    cname = get(cls, 'Name');
    topic = ['udd_' cname];
else
    topic = '';
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function topic = remap_topic_based_on_obj(h,topic)
% Someday add code to remap eML help buttons to eML help instead of
% Stateflow help.

switch lower(topic)
    case 'state_dialog',
        topic = remap_state_dialog(h,topic);
    case 'chart_dialog',
        if is_eml_based_chart(h.Id)
            topic = 'eml_chart_dialog';
        end
    case 'data_dialog',
        if is_eml_parented_data(h.Id)
            topic = 'eml_data_dialog';
        end
    case 'event_dialog',
        if is_eml_parented_event(h.Id)
            if isa(h,'Stateflow.Trigger')
                topic = 'eml_trigger_dialog';
            elseif isa(h,'Stateflow.FunctionCall')
                % This case is here for future use and to document the
                % intent. 
                topic = 'eml_event_dialog';
            else
                % This case should be unreachable.
                topic = 'eml_event_dialog';
            end
        end
    otherwise,
        %Do nothing.
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function topic = remap_state_dialog(h,topic)
 
switch h.class
    case 'Stateflow.TruthTable'
        topic = 'truth_table_dialog';
    case 'Stateflow.EMFunction'
        topic = 'eml_function_dialog';
    case 'Stateflow.Function'
        topic = 'function_dialog';
    case {'Stateflow.Note','Stateflow.Annotation'}
        topic = 'note_props_dlg';
    otherwise
        %topic is left to be state_dialog
end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function topic = topic_from_context
topic = '';
obj = gcbo;

if ~isempty(obj)
    fig = get_parent_figure(obj);
    if ~isempty(fig)
        tag = get(fig,'Tag');
        if ~isempty(tag)
            topic = tag_to_topic(obj,tag);
        end
    end
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function topic = tag_to_topic(obj,tag)
%
% This code appears to be dead.  It is a remnant from when dialogs were
% implemented in HG.  That hasn't been the case for a very long time.
%

topic = tag;
switch tag
    case 'SFCHART'
        % editor specific menu pick
        if ~isempty(regexp(get(obj,'Label'),'Editor', 'once'))
            topic = 'EDITOR';
            % open the whole collection
        elseif ~isempty(regexp(get(obj,'Label'),'Topic', 'once'))
            topic = '';
        end
    case 'SFEXPLR'
        % explorer-specific menu pick
        if ~isempty(regexp(get(obj,'Label'),'Explorer', 'once'))
            topic = 'EXPLORER';
            % open the whole collection
        elseif ~isempty(regexp(get(obj,'Label'),'Topic', 'once'))
            topic = '';
        end
    case 'STATE'
        % state or box? help is same either way
        userData = get(fig,'Userdata');
        stateType = sf('get',userData.objectId,'state.type');
        switch(stateType)
            case 2,
                if(sf('get', userData.objectId,'state.truthTable.isTruthTable'))
                    topic = 'TRUTH_TABLE';
                else
                    topic = 'FUNCTION';
                end
            case 3,
                topic = 'BLOCK';
            otherwise,
                %Do nothing.
        end
    otherwise,
        %Do nothing.
end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = execute_topic(topic)

x = [];

t = lookup_local_topic(topic);

if isempty(t)
    % The topic we computed could not be found locally.
    error('Stateflow:UnexpectedError','Topic not found locally: %s',topic);
end

if isa(t{2},'function_handle')
    f = t{2};
    if nargout(f) > 0
        x = f();
    else
        f();
    end
else
    helpview(t{3},t{2});
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function t = lookup_local_topic(topic)

T = topic_map;

I = strmatch(lower(topic),T(:,1),'exact');

if isempty(I)
    t = [];    
else 
    t = T(I(1),:);    
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function t = topic_map

%This table isolates us from changes in the MAP files and makes
% it possible to automatically test that the map-files aren't changed
% without the appropriate changes in the code base.
%
% Although it is tempting to think that only one column is needed please do
% not collapse the two.

slUGTopics = {...
    'eml_chart_dialog','eml_ports_and_data_manager';
    'eml_data_dialog','eml_adding_data';
    'eml_trigger_dialog','eml_adding_input_triggers';
    'eml_event_dialog','eml_adding_function_call_outputs';
    'eml_function_dialog','eml_ports_and_data_manager';
    };
    
slTopics = {...
        'em_block_ref','em_block_ref';
        'eml_editor','eml_editor';
        };
    
% The V is used to indicate the strings I was actually able to reach during
% testing.
sfTopics = ...
    { ...  %internal topic, link (mapfile topic) or function handle
    '',                @open_stateflow_product_page;
    'backup_warning_error', @backup_error_help;
    'block',          'BLOCK_DIALOG';
    'chart',          'CHART_DIALOG';
    'chart_dialog',   'CHART_DIALOG'; % V
    'coderoptions',   'CODEROPTIONS_DIALOG';
    'connective_junction_dialog', 'connective_junction_dialog'; % V
    'cus_coder_options', 'CUS_CODER_OPTIONS'; % V
    'custom_target_dialog', 'custom_target_dialog'; % V
    'rtw_target_dialog', 'rtw_target_dialog'; % V
    'cycle_error',    @cycle_error_help; % V
    'data',          'DATA_DIALOG';
    'data_dialog',   'DATA_DIALOG'; % V
    'debugger',      'DEBUGGER_DIALOG';
    'doc',           @open_stateflow_product_page;
    'editor',        'EDITOR';
    'eml_functions_chapter', 'eml_functions_stateflow';
    'eml_functions_stateflow','eml_functions_stateflow';
    'event',         'EVENT_DIALOG';
    'event_dialog',  'EVENT_DIALOG'; % V
    'explorer',      'EXPLORER';
    'finder',        'FINDER_DIALOG';
    'function',       'function_dialog'; 
    'function_dialog', 'function_dialog'; % V
    'helpdesk',       @helpdesk; % V
    'history_junction_dialog', 'history_junction_dialog'; % V
    'junction',      'connective_junction_dialog'; % XXX 'JUNCTION_DIALOG';
    'machine',       'MACHINE_DIALOG';
    'machine_dialog',       'MACHINE_DIALOG';
    'note_props_dlg', 'note_props_dlg'; % v
    'obsoleted_features', @helpdesk; % XXX 'OBSOLETED_FEATURES';
    'replace',        'SEARCH_N_REPLACE_DIALOG'; % V
    'rtw_coder_options', 'RTW_CODER_OPTIONS'; % V
    'sf_debugger',    'DEBUGGER_DIALOG';
    'sf_styler',      'STYLER_DIALOG';
    'sfchart',        'CHART_DIALOG'; % XXX 'SFCHART';
    'sfexplr',        'model_explorer'; % XXX 'SFEXPLR';
    'sfrgdialogfig',  'PRINT_BOOK_DIALOG';
    'sim_coder_options', 'SIM_CODER_OPTIONS'; % V
    'simulation_target_dialog', 'simulation_target_dialog'; %V
    'state',          'STATE_DIALOG';
    'state_dialog',   'STATE_DIALOG'; % V
    'stateflow',      @open_stateflow_product_page; % V
    'styler',         'STYLER_DIALOG';
    'target',         'simulation_target_dialog'; 
    'target_options_dialog', 'TARGET_OPTIONS_DIALOG'; % V 
    'targetoptions',  'TARGETOPTIONS_DIALOG';
    'transition',     'TRANSITION_DIALOG';
    'truth_table',    'truth_tables_chapter'; 
    'truth_tables_chapter', 'truth_tables_chapter'; % V
    'truth_table_dialog', 'truth_table_dialog';
    'udd_box',        'box_properties';
    'udd_chart',      'chart_properties';
    'udd_clipboard',  'clipboard_methods';
    'udd_data',       'data_properties'; 
    'udd_editor',     'editor_properties';
    'udd_emchart',    'em_function_properties';
    'udd_emfunction', 'em_function_properties';
    'udd_event',      'event_properties';
    'udd_function',   'function_properties';
    'udd_functioncall', 'function_properties'; 
    'udd_slfunction', 'simulink_function_properties'; 
    'udd_linkchart',  'chart_properties'; % XXX WRONG
    'udd_junction',   'junction_properties';
    'udd_machine',    'machine_properties';
    'udd_note',       'note_properties'; % Shouldn't this be udd_annotation? -ddube
    'udd_annotation', 'note_properties';
    'udd_root',       'root_methods';
    'udd_state',      'state_properties';
    'udd_target',     'target_properties';
    'udd_transition', 'transition_properties';
    'udd_truthtable', 'truth_tables_chapter';  % XXX Wrong link  
    'udd_truthtablechart', 'truth_tables_chapter';  % XXX Wrong link  
    'continuoustimerestrictions', 'sfpm_semantic_restrictions';
    'sf_multioutput', 'sf_multioutput';
    'sf_abstemporal_enable', 'sf_abstemporal_enable';
    'stateflow_product_page', 'stateflow_product_page';
    'atomic_subchart_rules', 'atomic_subchart_rules';
    'atomic_subchart_conversion_restrictions', 'atomic_subchart_conversion_restrictions';
    'convert_to_and_from_atomic_subcharts', 'convert_to_and_from_atomic_subcharts';
    %'pattern_wizard', 'pattern_wizard';
    };

emlTopics = {...
    'embedded_matlab_library_bycategory','embedded_matlab_library_bycategory';
    };

sfTopics(:,3) = {sf_map};
slTopics(:,3) = {sl_map};
slUGTopics(:,3) = {sl_ug_map};
emlTopics(:,3) = {eml_map};

t = [{ '-topics',@topic_map, ''}
       sfTopics;...
       slTopics;...
       slUGTopics;...
       emlTopics;...
       ];

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s = sf_map
s = fullfile(docroot,'/mapfiles/stateflow.map');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s = sl_map
s = fullfile(docroot,'/mapfiles/simulink.map');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s = sl_ug_map
s = fullfile(docroot,'/toolbox/simulink/ug/simulink_ug.map');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s = eml_map
s = fullfile(docroot,'/toolbox/eml/eml.map');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function open_stateflow_product_page
 
helpview(fullfile(docroot,'/mapfiles/stateflow.map'), 'stateflow_product_page');
 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fig = get_parent_figure(obj)
fig = [];
if obj == 0 || ~ishandle(obj)
    return; 
end

switch lower(get(obj,'Type'))
    case 'figure'
        fig = obj;
    case 'uicontrol'
        switch lower(get(obj,'style'))
            case {'pushbutton' 'text' 'edit'}
                fig = get(obj,'Parent');
            otherwise
                error('Stateflow:UnexpectedError','unexpected object invoked sfhelp');
        end
    case 'uimenu'
        p = get(obj,'Parent');
        while isempty(findobj(p,'Type','Figure'))
            p = get(p,'Parent');
        end
        fig = p;
    otherwise
        error('Stateflow:UnexpectedError','unexpected object invoked SFHELP');
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function display_file(htmlFile)
    % Construct URL
    if (strncmp(computer,'MAC',3))
        htmlFile = ['file:///' strrep(htmlFile,filesep,'/')];
    end

    % Load the correct HTML file into the browser.
    stat = web(htmlFile);
    if (stat==2)
        error('Stateflow:UnexpectedError','Could not launch Web browser. Please make sure that\nyou have enough free memory to launch the browser.');
    elseif (stat)
        error('Stateflow:UnexpectedError','Could not load HTML file into Web browser. Please make sure that\nyou have a Web browser properly installed on your system.');
    end
end
% EOF: sfhelp.m

