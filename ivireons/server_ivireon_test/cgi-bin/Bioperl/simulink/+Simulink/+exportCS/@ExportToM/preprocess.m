% Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.6.9.2.1 $


function preprocess(etm, noComment)

cs = etm.csCopyFrom;
totalProp = cs.getProp;
thisTarget = cs.get_param('SystemTargetFile');

etm.description = loc_string(cs.Description);
etm.name = loc_string(cs.Name);

if length(cs.Components)>8
    additionalComponentClass = cell(1, length(cs.Components)-8);
    for i=9:length(cs.Components)
        additionalComponentClass{i-8} = class(cs.Components(i));
    end
    
    etm.additionalComponentClass = additionalComponentClass;
    etm.csCopyFrom = cs;
end

isCustomTarget = ~loc_isBuildinTarget(thisTarget);
etm.isCustomTarget = isCustomTarget;

if isCustomTarget
    cs_ert = Simulink.ConfigSet;
    cs_ert.switchTarget('ert.tlc', '');

    if length(cs.Components)>8
        for i=9:length(cs.Components)
            componentCC = eval(additionalComponentClass{i-8});
            cs_ert.attachComponent(componentCC);
        end
    end

    totalProp_ert = cs_ert.getProp;
    hash_ert = containers.Map;
    for i=1:length(totalProp_ert)
        hash_ert(totalProp_ert{i}) = 1;
    end
end

propertyNames=cell(1,1);
nameIdx=1;
hash = containers.Map;
lenOfProp = length(totalProp);

if isCustomTarget
    totalPropStruct = cell(1, lenOfProp);
end

for i=1:lenOfProp
    propertyName = totalProp{i};
    propertyNames{nameIdx}=propertyName;

    if isCustomTarget
        totalPropStruct{i}.name = propertyName;    
        if ~hash_ert.isKey(propertyName)
            totalPropStruct{i}.target = thisTarget;
        else
        totalPropStruct{i}.target = 'general';
        end
    end

    nameIdx = nameIdx + 1;
    hash(propertyName) = i;
end
etm.csCopyFromParamHash = hash;


uis = slCfgPrmDlg(cs, 'Param2UI', propertyNames);

idx = hash('ObjectivePriorities');    
uis{idx}.Prompt = 'Prioritized Objectives';
uis{idx}.Type = 'combobox';
uis{idx}.Path = 'Real-Time Workshop';
uis{idx}.Visible = 1;

idx = hash('ModelDependencies');
uis{idx}.Prompt = 'Model Dependencies';
uis{idx}.Type = 'text';
uis{idx}.Path = 'Model Referencing';
uis{idx}.Visible = 1;

if hash.isKey('ReplacementTypes');
    idx = hash('ReplacementTypes');
    uis{idx}.Prompt = 'Replacement Name';
    uis{idx}.Type = 'edit';
    uis{idx}.Path = 'Real-Time Workshop/Data Type Replacement';
    uis{idx}.Visible = 1;
end

if hash.isKey('TargetUnknown');
    idx = hash('TargetUnknown');
    uis{idx}.Prompt = 'Target Unknown';
    uis{idx}.Type = 'button';
    uis{idx}.Path = 'Hardware Implementation';
    uis{idx}.Visible = 1;
end

nonUINum = 0;
nonUIExemptionHash = containers.Map; % java.util.HashMap;

quote = '''';

paramhash = etm.paramHash;
configSetPane = etm.configSetPane;
paneManager = cell(1,1);
paneManagerIdx = zeros(15, 15);
i=0;

uiNameHash = etm.uiNameHash;
while true
i=i+1;
    
if i>length(totalProp)
    break; 
end

if isCustomTarget
    curPropStruct = totalPropStruct{i};
    param = curPropStruct.name;
else
    param = totalProp{i};
end

try
    ui = uis{i};
    if ui.Visible==0
        continue;
    end
    
    value = cs.get_param(param);
    realValue = value;
    
    if isnumeric(value)                    % numeric 
        value = loc_numeric(value);
    elseif iscell(value)                   % cell
        value = loc_cellToString(value);            
    elseif isstruct(value)                 % struct
        value = loc_structToString(value);            
    elseif islogical(value)                % logical
        value = loc_logicalToString(value);
    else                                   % scalar string
        value = loc_string(value);
    end
    
    scriptItem.script = [etm.variableName, '.set_param(', quote,  param, quote, ', ', value,')'];
    scriptItem.param = param;
    scriptItem.value = value;
    scriptItem.realValue = realValue;
    
    if isCustomTarget
        scriptItem.target = curPropStruct.target;
    end
    
    id = paramhash(param);
    scriptItem.id = id;
    
    if ~noComment
        if (isempty(ui) || isempty(ui.Type) || strcmpi(ui.Type, 'NonUI')) && ...
                ~nonUIExemptionHash.isKey(param)
            
            nonUINum = nonUINum + 1;
            scriptItem.UIName = param;
            
            continue;
        end
        
        if ~isempty(ui.Prompt)
            prompt = strrep(ui.Prompt, ':', '');
            uiNameHash(deblank(prompt)) = 1;
            scriptItem.UIName = prompt;
        else
            scriptItem.UIName = '';
        end
        
        path = ui.Path;
        scriptItem.type = path;
        scriptItem.path = ui.Path;
        
        if strcmpi(path, 'Data Import/Export')
            majorPane = path;
        else
            [majorPane, subPane] = strtok(path, '/');
        end
        
        if isempty(majorPane)
            majorPane = DAStudio.message('Simulink:tools:MFileParametersWithNoUI');
            path = majorPane;
            scriptItem.path = path;
        end
        
        if ~configSetPane.isKey(majorPane)                                  % main page for each children
            if strcmpi(majorPane, path)
                totalNumOfMajorPane = configSetPane('totalNumOfMajorPane');
                totalNumOfMajorPane = totalNumOfMajorPane + 1;
                configSetPane('totalNumOfMajorPane') = totalNumOfMajorPane;
                position = num2str(totalNumOfMajorPane);
                configSetPane(majorPane) = position;
                totalNum = 1;
                configSetPane(['totalNumOf-', majorPane , '-Pane']) = totalNum;
            else
                totalProp{end+1} = totalProp{i};
                uis{end+1} = ui;
                if isCustomTarget
                    totalPropStruct{end+1} = curPropStruct;
                end
                continue;
            end
        elseif ~isempty(subPane) && ~configSetPane.isKey(path)               % subPane, grandchildern
            totalNumName = ['totalNumOf-', majorPane, '-Pane'];
            totalNumOfThisPane = configSetPane(totalNumName);
            totalNumOfThisPane = totalNumOfThisPane + 1;
            configSetPane(totalNumName) = totalNumOfThisPane;
            position = [configSetPane(majorPane), '.', num2str(totalNumOfThisPane)];
            configSetPane(path) = position;
        else
            position = configSetPane(path);
        end
        
        [pos_x pos_y] = strtok(position, '.');            
        pos_x = str2double(pos_x);
        
        if isempty(pos_y)
            pos_y = 1;
        else
            pos_y = str2double(strrep(pos_y, '.', '')) + 1;
        end
        
        paneCoordinate.x = pos_x;
        paneCoordinate.y = pos_y;
        scriptItem.paneCoordinate = paneCoordinate;
        
        paneManagerIdx(pos_x, pos_y) = paneManagerIdx(pos_x, pos_y) + 1;
        paneManager{pos_x, pos_y, paneManagerIdx(pos_x, pos_y)} = id;
    end
    scriptraw(id) = scriptItem;
catch ME
    (ME.message);
end

etm.uiNameHash = uiNameHash;
end % END of while loop

etm.scriptRaw = scriptraw;
etm.configSetPane = configSetPane;
etm.paneManager = paneManager;
etm.paneManagerIdx = paneManagerIdx;
end % END of function: preprocess(etm, noComment)

% followings are local utility functions
function string = loc_cellToString(value)
    len = length(value);
    cellVal = '{';
    for i=1:len
        if iscell(value{i})
            cellValue = loc_cellToString(value{i});
        elseif isstruct(value{i})
            cellValue = loc_structToString(value{i});
        elseif isnumeric(value{i})
            cellValue = loc_numeric(value{i});
        elseif islogical(value{i})
            cellValue = loc_logicalToString(value{i});
        else
            cellValue = loc_string(value{i});
        end
        
        tmp = [cellVal, cellValue];
        cellVal = tmp;

        if i~=len
            tmp = [cellVal, ','];
            cellVal = tmp;
        end
    end
    
    string = [cellVal, '}'];
end

function string = loc_structToString(value)
    quote = '''';
    fields = fieldnames(value);
    len = length(fields);
    structarray = '';
    
    for i=1:len
        cellVal = value.(fields{i});
        
        if iscell(cellVal)
            cellVal = ['{', loc_cellToString(cellVal), '}'];
        elseif isstruct(cellVal)
            cellVal = loc_structToString(cellVal);
        elseif isnumeric(cellVal)
            cellVal = loc_numeric(cellVal);
        elseif islogical(cellVal)
            cellVal = loc_logicalToString(cellVal);
        else
            cellVal = loc_string(cellVal);
        end

        if isempty(structarray)
            structarray = [quote, fields{i}, quote, ',', cellVal];
        else
            tmp = [structarray, ',', quote, fields{i}, quote, ',', cellVal];
            structarray = tmp;
        end
    end
    
    string = ['struct(', structarray, ')'];
end

function string = loc_string(value)
    quote = '''';
    newLinePos = strfind(value, char(10));
    value = regexprep(value, '''', '''''');
    
    if isempty(newLinePos)
        tmp = [quote, value, quote];  % single-line string
        string = tmp;
    else                              % multi-line string
        numOfMultiLines = length(newLinePos);
        
        if newLinePos(length(newLinePos)) < length(value)
            numOfMultiLines = numOfMultiLines + 1;
        end

        arg = [quote, strrep(value, char(10), ''','''), quote];
        
        command = ['sprintf(', quote];
        for k=1:numOfMultiLines
            temp = command;
            
            if k==numOfMultiLines
                command = [temp, '%s'];
            else
                command = [temp, '%s\n'];
            end
        end
        
        string = [command, quote, ',', arg, ')'];
    end
end

function string = loc_numeric(value)
    quote = '''';
    
    string = num2str(value, '%.15G');

    if isempty(value)
        string = [quote, quote];
    end
end

function string = loc_logicalToString(value)
    if value
        string = 'true';
    else
        string = 'false';
    end
end

function result = loc_isBuildinTarget(target)
    builtinTargets = ...
        {'ert.tlc', ...
         'autosar.tlc', ...
         'c166.tlc', ...
         'ccslink_ert.tlc', ...
         'ert_shrlib.tlc', ...
         'mpc555exp.tlc', ...
         'mpc555pil.tlc', ...
         'mpc555rt.tlc', ...
         'multilink_ert.tlc', ...
         'multilink_grt.tlc', ...
         'ti_c2000_ert.tlc', ...
         'ti_c2000_grt.tlc', ...
         'vdsplink_ert.tlc', ...
         'xpctargetert.tlc', ...
         'asap2.tlc', ...
         'grt.tlc', ...
         'c166_grt.tlc', ...
         'ccslink_grt.tlc', ...
         'grt_malloc.tlc', ...
         'mpc555rt_grt.tlc', ...
         'rsim.tlc', ...
         'rtwin.tlc', ...
         'rtwsfcn.tlc', ...
         'tornado.tlc', ...
         'vdsplink_grt.tlc', ...
         'xpctarget.tlc'
        };

    result = any(strcmp(builtinTargets, target));
end
