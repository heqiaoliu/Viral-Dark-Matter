function schema = contextMenu(callbackInfo)

    schema = DAStudio.ContainerSchema;
    schema.tag = 'Simulink:CoverageContextMenu';
    schema.label = xlate('Coverage');
    if  ~license('test','sl_verification_validation') || ...
        exist('cvsim', 'file') == 0 
        schema.state = 'Hidden';
        return;
    else
        schema.state = 'Enabled';        
    end

    schema.childrenFcns = { @CoverageReport};
    
    if strcmpi(cv('Feature', 'enable coverage filter'), 'on')
        schema.childrenFcns = [ schema.childrenFcns, ...
                                {'separator', ...
                                @CoverageFilter}];

    end

    schema.childrenFcns = [ schema.childrenFcns,...
                            {'separator', ...
                            @CoverageMouseOverInfo, ...
                            @CoverageClickInfo, ...
                            'separator', ...
                            @CoverageDisableInfo, ...
                            'separator', ...
                            @CoverageSettingsMenu}];

end

%========================
function CoverageFilter_callback(callbackInfo )

fileName = get_param(callbackInfo.model.Name, 'CovFilter');
filter = cv.FilterEditor.loadFilter(fileName);

block = get_param(callbackInfo.getSelection.Handle,'Object');
if ~isfield(filter, 'BlockPath')
    filter.BlockPath = {};
end
val = Simulink.ID.getSID(block.getFullName);
if ~isempty(filter.BlockPath)
    filter.BlockPath{end+1} = val;
else
    filter.BlockPath{1} = val;
end
filterBuilder = coverageFilterBuild(fileName, callbackInfo.model.Name);
filterBuilder.loadState(filter);
filterBuilder.m_dlg.refresh;

end

function schema = CoverageFilter( callbackInfo )
    schema = DAStudio.ActionSchema;
    schema.tag = 'Simulink:CoverageFilter';
    schema.label = xlate('Filter Block ...');
    selBlocks = callbackInfo.getSelection.Handle;
    suppBlocks = cvi.TopModelCov.getSupportedBlockTypes;
    blockTypes = get(selBlocks, 'BlockType');
    enabled = ~isempty(intersect(blockTypes, suppBlocks));
    
    if ~enabled
        libs = libinfo(callbackInfo.model.Name);
        if ~isempty(libs)
            o = get_param(callbackInfo.getSelection.Handle, 'Object');
            enabled = strfind([libs.Block], o.getFullName);
        end
    end
    if enabled && strcmpi(get_param(callbackInfo.model.Name, 'RecordCoverage'), 'on')
        schema.state ='Enabled';
    else
        schema.state ='Hidden';
    end
    schema.callback = @CoverageFilter_callback;            
end

%========================
function schema = CoverageSettingsMenu( callbackInfo )
    schema = SlCov.CovMenus.settingsMenu(callbackInfo);
    schema.label = xlate('Settings...');

end
%========================
function schema = CoverageReport( callbackInfo )
    schema = DAStudio.ActionSchema;
    schema.tag = 'Simulink:CoverageReport';
    schema.label = xlate('Report');
    blockCoverageId  = 0;
    if ~isempty(callbackInfo.getSelection)
        blockCoverageId  = get_param(callbackInfo.getSelection.Handle, 'CoverageId');
    end
    modelCoverageId  = get_param(callbackInfo.model.Name, 'CoverageId');
    if blockCoverageId >0 && modelCoverageId  > 0
        schema.state ='Enabled';
    else
        schema.state ='Hidden';
    end
    schema.callback = @CoverageReport_callback;            
end

function CoverageReport_callback(callbackInfo )
    cv('SlsfCallback','reportLink', get_param(callbackInfo.getSelection.Handle, 'CoverageId'));
end
%========================
function res = isInformerDisplayed(modelH)
 res = ~isempty(cv('get', get_param(modelH, 'CoverageId'), '.currentDisplay.informer'));
end


%========================
function schema = CoverageMouseOverInfo( callbackInfo )
    schema = DAStudio.ToggleSchema;
    schema.tag = 'Simulink:CoverageMouseOverInfo';
    schema.label = xlate('Display details on mouse-over');    
    modelCoverageId  = get_param(callbackInfo.model.Name, 'CoverageId');
    if  (modelCoverageId  > 0) && isInformerDisplayed(callbackInfo.model.Name)
        schema.state ='Enabled';
    else
        schema.state ='Hidden';
    end
    schema.callback = @CoverageMouseOverInfo_callback;            
end

function CoverageMouseOverInfo_callback(callbackInfo )
    cv('SlsfCallback','mouseOverToggle',get_param(callbackInfo.model.Name, 'CoverageId'));
end

%========================
function schema = CoverageClickInfo( callbackInfo )
    schema = DAStudio.ToggleSchema;
    schema.tag = 'Simulink:CoverageClickInfo';
    schema.label = xlate('Display details on mouse click');
    modelCoverageId  = get_param(callbackInfo.model.Name, 'CoverageId');
    if  (modelCoverageId  > 0) && isInformerDisplayed(callbackInfo.model.Name)
        schema.state ='Enabled';
    else
        schema.state ='Hidden';
    end
    schema.callback = @CoverageClickInfo_callback;            
end    
function CoverageClickInfo_callback(callbackInfo )
    cv('SlsfCallback','mouseOverToggle',get_param(callbackInfo.model.Name, 'CoverageId'));
end

%========================
function schema = CoverageDisableInfo( callbackInfo )
    schema = DAStudio.ToggleSchema;
    schema.tag = 'Simulink:CoverageDisableInfo';
    schema.label = xlate('Remove information');

    modelCoverageId  = get_param(callbackInfo.model.Name, 'CoverageId');
    if  (modelCoverageId  > 0) && isInformerDisplayed(callbackInfo.model.Name)
        schema.state ='Enabled';
    else
        schema.state ='Hidden';
    end
        schema.callback = @CoverageDisableInfo_callback;
end
function CoverageDisableInfo_callback(callbackInfo )
    cv('SlsfCallback','disableInfo',get_param(callbackInfo.model.Name, 'CoverageId'));
end
