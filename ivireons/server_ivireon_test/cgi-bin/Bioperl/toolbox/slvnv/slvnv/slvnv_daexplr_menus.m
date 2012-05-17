function [visible,enabled,subMenu] = slvnv_daexplr_menus(method, varargin)

%   Copyright 2007-2010 The MathWorks, Inc.

    persistent CbInfo
    persistent schemas
    persistent lastSubMenu

    if ~ischar(method)
        mdlexplrudd = method;
        method = 'create';
    end

    switch(method)
      case 'create',
        % Cleanup previous menu if there was one
        if ~isempty(lastSubMenu)
            try
                delete(lastSubMenu.getChildren);
                lastSubMenu.delete;
            catch Mex %#ok<NASGU>
            end
        end

        obj = varargin{1};
        subMenu = [];
        if explrHasMultSelect(mdlexplrudd)
            visible = false;
            enabled = false;
            schemas = cell(0);
            CbInfo = [];
        else
            [visible, enabled, schemas, CbInfo] = create(obj);
        end

        if ~isempty(schemas)
            subMenu = create_submenu(mdlexplrudd, schemas);
            lastSubMenu = subMenu;
        end

      case 'callback',
        idx = varargin{1};
        invoke_callback(idx, CbInfo, schemas);

      otherwise
        assert('Unexpected method');
    end

function out = explrHasMultSelect(mdlexplrudd)
    imme = DAStudio.imExplorer(mdlexplrudd);
    selList = imme.getSelectedListNodes();
    out = (length(selList)>1);

function hello_world(varargin)
    disp('Hello world');

function [visible, enabled, schemas, CbInfo] = create(obj)
    if isa(obj,'DAStudio.WSOAdapter')
        obj = -1;  % Used to be obj = obj.getVariable
    end


    if ishandle(obj) && obj.rmiIsSupported && ...
            ( license('test','sl_verification_validation') || ~isempty(rmi.getReqs(obj)) )
        CbInfo = create_callback_info(obj, true);
        schemaGen = rmisl.menus_rmi_object(CbInfo);
        schemas = getSchemas(schemaGen, obj);
        visible = true;
        enabled = true;
    else
        CbInfo = [];
        schemas = cell(0);
        visible = false;
        enabled = false;
    end


function actions = structs2actions(menuStructs)

    sepCnt = sum([menuStructs.hasSeparator]);
    actions = handle(-1*ones(1,length(menuStructs)+sepCnt));

    schIdx = 1;

    for idx = 1:length(menuStructs)
        schema = sl_action_schema;
        schema.label = menuStructs(idx).label;
        schema.callback = menuStructs(idx).callbackFcn;
        schema.userdata = menuStructs(idx).arg;

        actions(schIdx) = schema;
        schIdx = schIdx + 1 + ...
                 (idx<length(menuStructs) && menuStructs(idx+1).hasSeparator);
    end

function subMenu = create_submenu(mdlexplrudd, schemas)

    am = DAStudio.ActionManager;
    subMenu = am.createPopupMenu(mdlexplrudd);

    for idx=1:length(schemas)
        if( ~isequal(schemas{idx}, 'separator') )

            callback = sprintf('slvnv_daexplr_menus(''callback'',%d);',idx);
            action = am.createAction(mdlexplrudd, 'Text', schemas{idx}.label, ...
                                     'Callback',   callback, ...
                                     'Tag',schemas{idx}.tag);
            subMenu.addMenuItem(action);

            if (idx<length(schemas) && isequal(schemas{idx+1},'separator'))
                subMenu.addSeparator;
            end
        end
    end

function cbInfo = create_callback_info(selectedUdi, varargin)
    cbInfo = DAStudio.CallbackInfo;
    cbInfo.uiObject = selectedUdi;
    if( ~isempty(varargin) )
        cbInfo.userdata = varargin{1};
    else
        cbInfo.userdata = true;
    end

function schemas = getSchemas(handles, selectedUdi)
    schemas = cell(0);
    for i=1:length(handles)

        handle = handles{i};
        if (iscell(handle) )
            cbInfo = create_callback_info(selectedUdi, handle{2});
            funhandle = handle{1};
            schemas = {schemas{:} funhandle(cbInfo)};
        else
            if ( isequal(handle,'separator') )
                schemas = {schemas{:} 'separator'};
            else
                cbInfo = create_callback_info(selectedUdi);
                schemas = {schemas{:} handle(cbInfo)};
            end
        end
    end


function invoke_callback(idx, cbInfo, schemas)

    if idx>0 && idx<=length(schemas)
        if(~isequal(schemas{idx},'separator') )
            schema = schemas{idx};

            cbInfo.userdata = schema.userdata;
            funhandle = schema.callback;
            funhandle(cbInfo);
        end
    end
