function rmidemo_callback(action, object, varargin)
% A collection of safely wrapped calls to rmi.
% Used by slvnvdemo_fuelsys_req demo.
% 
% Copyright 2009-2010 The MathWorks, Inc.
%

persistent current_object;

    switch action
        case 'open'
            try
                open_system(object);
            catch Mex %#ok: user might try to open a subsystem when system is closed
                parts = textscan(object, '%s', 'Delimiter', '/');
                system = '';
                for idx = 1:length(parts{1})
                    if isempty(system)
                        system = parts{1}{idx};
                    else
                        system = [system '/' parts{1}{idx}]; %#ok
                    end
                    open_system(system);
                end
            end
            
        case 'highlight'
            try
                rmi('highlightModel', object);
            catch Mex %#ok: user might have closed the system
                rmidemo_callback('open', object);
                rmi('highlightModel', object);
            end
            current_object = [];
            
        case 'open_highlight'
            try
                open_system(object);
            catch Mex %#ok: user might have closed the parent system
                rmidemo_callback('open', object);
            end
            rmi('highlightModel', object);
            current_object = [];
            
        case 'view'
            if ~isempty(strfind(object,':')) % ssid provided for stateflow objects
                target = sfprivate('ssIdToHandle', object);
                if isempty(target) % model must have been closed by user
                    model = strtok(object,'/');
                    open_system(model);
                    target = sfprivate('ssIdToHandle', object);
                end
            else  % plain full path for simulink objects
                target = object;
            end
            try 
                rmi('view', target, varargin{1});
            catch Mex %#ok - this happens if model is not open
                model = strtok(object,'/');
                open_system(model);
                rmi('view', target, varargin{1});
            end
            
        case 'locate' 
            unhighlight(current_object);
            try
                rmi('unhighlightModel', object);
                subsystem = get_param(object, 'Parent');
                open_system(subsystem);
            catch Mex %#ok - this happens if model is not open
                model = strtok(object,'/');
                open_system(model);
                subsystem = get_param(object, 'Parent');
                rmidemo_callback('open', subsystem);
            end
            set_param(object, 'hiliteAncestors', 'reqHere');
            current_object = object;
            
        case 'locate_sf' % sf object name expected in 'object'
            unhighlight(current_object);
            current_object = [];
            % get sf handle from name
            target = sfprivate('ssIdToHandle', object);
            if isempty(target) % model must have been closed by user
                model = strtok(object,'/');
                open_system(model);
                target = sfprivate('ssidToHandle', object);
            end
            target = get(target, 'Id');
            % unhighlight chart
            chart = vnvprivate('obj_chart', target);
            sf('Open', chart);
            sf('Highlight', chart, []);
            sf('ClearAltStyles', chart);
            sf('Redraw', chart);
            % highlight this object
            vnvprivate('sf_update_style', target, 'req');
            
        case 'signalgroup' % object should be a sigbuilder, varargin should be a tab index
            unhighlight(current_object);
            try
                rmidemo_callback('open', object);
            catch Mex %#ok - this happens if model is not open
                model = strtok(object,'/');
                open_system(model);
                rmidemo_callback('open', object);
            end
            signalbuilder(object, 'activeGroup', varargin{1});
            set_param(object, 'hiliteAncestors', 'reqInside');
            current_object = object;
            
        case 'report'
            try
                rmi('report', object);
            catch Mex %#ok
                model = strtok(object,'/');
                open_system(model);
                rmi('report', model);
            end
            
        case 'filter'
            rmidemo_callback('open', object);
            filterSettings = rmi.settings_mgr('get', 'filterSettings');
            filterSettings.enabled = true;
            filterSettings.tagsRequire = varargin(1);
            filterSettings.tagsExclude = {};
            rmi.settings_mgr('set','filterSettings', filterSettings);
            modelH = rmisl.getmodelh(object);
            rmi('highlight', modelH, 'on');
            current_object = [];
            
        case 'check'
            rmidemo_callback('open', object);
            eval(['cd ' tempdir])
            rmi('check', object, 'modeladvisor');
            
        otherwise
            error('slvnv:rmidemo_callback:UnsupportedAction', 'Unsupported action: %s', action);
    end
    
function unhighlight(object)
    if ~isempty(object)
        try
            set_param(object, 'hiliteAncestors', 'off');
        catch Mex %#ok
        end
    end

    
    