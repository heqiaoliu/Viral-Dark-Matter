
%   Copyright 2010 The MathWorks, Inc.

classdef Config < handle
    properties (SetObservable,AbortSet)
        Selected = false
        SimulinkDataType = ''
        AutoSimulinkDataType = ''
        SimulinkClass = ''
        RTWStorageClass = ''
    end
    properties (Abstract)
        Name
        Type
        Parent
    end
    methods
        function setSelected(obj,val)
            if val
                obj.Selected = true;
            else
                obj.Selected = false;
            end
        end
        function setAutoSimulinkDataType(obj,sltype)
            obj.AutoSimulinkDataType = sltype;
            obj.SimulinkDataType = sltype;
        end
        function copyConfig(obj,from)
            obj.Selected = from.Selected;
            if ~strcmp(from.SimulinkDataType,from.AutoSimulinkDataType);
                % copy user-entered SimulinkDataType only 
                obj.SimulinkDataType = from.SimulinkDataType;
            end
            obj.SimulinkClass = from.SimulinkClass;
            obj.RTWStorageClass = from.RTWStorageClass;
        end
        function out = importToWorkspace(obj)
            out = false;
            config = obj;
            if isempty(config.SimulinkClass)
                DAStudio.error('Simulink:utility:SINoSimulinkClassConfig',obj.Name);
            end
            v = Simulink.symbol.Config.createSimulinkObject(obj,config);
            if isempty(v)
                DAStudio.error('Simulink:utility:SIUnsupportedSimulinkClassConfig',obj.Name,obj.SimulinkClass);
            end
            if ~isempty(v)
                % need to resolve conflict
                assignin('base',obj.Name,v);
                out = true;
            end
        end
        function setModifyListener(obj,listener)
            addlistener(obj,{'Selected','SimulinkDataType',...
                'SimulinkClass','RTWStorageClass'},'PostSet',listener);
        end
    end
    methods
        function out = getDialogAgentClassName(~)
            out = 'Simulink.SymbolConfigDialog';
        end
    end

    methods
        function out = resolveType(obj)
            out = [];
            group = obj.Parent;
            if ~isempty(group)
                file = group.Parent;
                out = file.getType(obj.Type);
                if ~isempty(out) && ~out.Selected
                    % ignore deselected type
                    out = [];
                end
            end
        end
        function out = resolveValue(obj,value)
            out = [];
            if ~ischar(value) || value(1) ~= '&'
                return
            end
            pointTo = value(2:end);
            group = obj.Parent;
            if ~isempty(group) && group.Symbols.isKey(pointTo);
                v = group.Symbols(pointTo);
                out = v.Value;
                if iscell(out)
                    out = cell2mat(out);
                end
            end
        end
    end
    % methods to create Simulink object
    methods (Static=true)
        function [out varargout] = createSimulinkObject(symbol,config)
            if nargin == 1
                config = symbol;
            end
            simulinkClass = config.SimulinkClass;
            switch simulinkClass
                case 'Simulink.Parameter'
                    out = Simulink.symbol.Config.createSimulinkParameter(...
                        symbol,config);
                case 'Simulink.Signal'
                    out = Simulink.symbol.Config.createSimulinkSignal(...
                        symbol,config);
                case 'Simulink.NumericType'
                    out = Simulink.symbol.Config.createSimulinkNumericType(...
                        symbol,config);
                case 'Simulink.AliasType'
                    out = Simulink.symbol.Config.createSimulinkAliasType(...
                        symbol,config);
                case 'MATLAB array'
                    out = Simulink.symbol.Config.createMATLABArray(...
                        symbol,config);
                case 'embedded.fi'
                    out = Simulink.symbol.Config.createEmbeddedFI(...
                        symbol,config);
                case 'Simulink.Bus'
                    if nargout > 1
                        [out varargout{1}] = Simulink.symbol.Config.createSimulinkBus(...
                            symbol,config);
                    else
                        out = Simulink.symbol.Config.createSimulinkBus(...
                            symbol,config);
                    end
                case 'Simulink.StructType'
                    if nargout > 1
                        [out varargout{1}] = Simulink.symbol.Config.createSimulinkStructType(...
                            symbol,config);
                    else
                        out = Simulink.symbol.Config.createSimulinkStructType(...
                            symbol,config);
                    end
                otherwise
                    out = [];
            end
        end
    end
    methods (Static=true, Access=private)
        function out = createSimulinkParameter(symbol,config)
            out = Simulink.Parameter;
            
            if iscell(symbol.Value)
                out.Value = cell2mat(symbol.Value);
            elseif ischar(symbol.Value)
                out.Value = symbol.resolveValue(symbol.Value);
            else
                out.Value = symbol.Value;
            end

            % set fixed point type
            % need error checking
            if strncmp(config.SimulinkDataType,'fixdt',5)
                % value conversion
                out.Value = Simulink.symbol.Config.getRealWorldValue(symbol,config.SimulinkDataType);
                % set type
                dataType = config.SimulinkDataType;
            else
                [dataType, dim] = strtok(symbol.Type,'[');
                if ~isempty(config.SimulinkDataType)
                    % need to resolve type to base type
                    resolvedType = symbol.resolveType;
                    if ~isempty(resolvedType) && Simulink.symbol.Config.isFixdt(resolvedType.SimulinkDataType)
                        out.Value = Simulink.symbol.Config.getRealWorldValue(symbol,resolvedType.SimulinkDataType);
                    end
                    dataType = config.SimulinkDataType;
                end
                if isempty(out.Value) && ~isempty(dim)
                    dim = sscanf(dim,'[%d]');
                    out.Value = zeros(dim);
                end
            end
            % change to auto to avoid warning
            if strcmp(dataType,'double') && (...
                    strcmp(config.SimulinkDataType,'double') || ...
                    isempty(config.SimulinkDataType,''))
                dataType = 'auto';
            end
            out.DataType = dataType;
            
            % set storage class
            if ~isempty(config.RTWStorageClass)
                out.RTWInfo.StorageClass = config.RTWStorageClass;
            end
        end
        function out = createSimulinkSignal(symbol,config)
            out = Simulink.Signal;
            out.DataType = config.SimulinkDataType;
            % set storage class
            if ~isempty(config.RTWStorageClass)
                out.RTWInfo.StorageClass = config.RTWStorageClass;
            end
        end
        function [out varargout] = createSimulinkBus(symbol,~)
            [out, nested] = Simulink.symbol.Config.createSimulinkBusOrStruct(symbol,Simulink.Bus);
            if nargout > 1
                varargout{1} = nested;
            end
        end
        function [out varargout] = createSimulinkStructType(symbol,~)
            [out, nested] = Simulink.symbol.Config.createSimulinkBusOrStruct(symbol,Simulink.StructType);
            if nargout > 1
                varargout{1} = nested;
            end
        end
        function [out varargout] = createSimulinkBusOrStruct(symbol,dataObj)
            nestedbus = [];
            dataObj.HeaderFile = symbol.HeaderFile;
            if isa(symbol.Type,'Simulink.symbol.CStructType')
                fields = symbol.Type.Fields;
            else
                fields = symbol.Fields;
            end
            for k=1:length(fields)
                % we need separate config object for each field, but ...
                if isa(dataObj,'Simulink.Bus')
                    elem = Simulink.BusElement;
                else
                    elem = Simulink.StructElement;
                end
                [dataObj.Elements(end+1), inner] = ...
                    Simulink.symbol.Config.createSimulinkBusOrStructElement(elem,fields{k});
                nestedbus = [inner; nestedbus];
            end
            out = dataObj;
            if nargout > 1
                varargout{1} = nestedbus;
            end
        end
        function [out nestedbus] = createSimulinkBusOrStructElement(elem,symbol)
            elem.Name = symbol.Name;
            % we need to allow configuration
            if isa(symbol.Type,'Simulink.symbol.CStructType')
                if isa(elem,'Simulink.BusElement')
                    nested = Simulink.Bus;
                else
                    nested = Simulink.StructType;
                end
                nestedbus.Obj = Simulink.symbol.Config.createSimulinkBusOrStruct(symbol,nested);
                nestedbus.Name = symbol.Name;
                elem.DataType = symbol.Name; % DataType references BE name
            else
                nestedbus = [];
                if ~isempty(symbol.SimulinkDataType)
                    elem.DataType = symbol.SimulinkDataType;
                else
                    elem.DataType = symbol.Type;
                end
                %be.Dimensions
                %be.DimensionsMode
                %be.SamplingMode
                %be.SampleTime
            end
            out = elem;
        end
        function out = createSimulinkNumericType(symbol,config)
            if Simulink.symbol.Config.isFixdt(config.SimulinkDataType)
                out = eval(config.SimulinkDataType);
            else
                out = fixdt(config.SimulinkDataType);
            end
            out.IsAlias = true;
            out.HeaderFile = symbol.HeaderFile;
        end
        function out = createSimulinkAliasType(symbol,config)
            out = Simulink.AliasType;
            out.HeaderFile = symbol.HeaderFile;
            if ~isempty(config.SimulinkDataType)
                out.BaseType = config.SimulinkDataType;
            else
                out.BaseType = symbol.Type;
            end
        end
        function out = createMATLABArray(symbol,~)
            out = eval([symbol.SimulinkDataType '(symbol.Value);']);
        end
        function out = createEmbeddedFI(symbol,config)
            value = Simulink.symbol.Config.getRealWorldValue(symbol,...
                config.SimulinkDataType);
            out = fi(value,eval(config.SimulinkDataType));
        end
        function out = isFixdt(typename)
            try
                dt = eval(typename);
            catch me
                out = false;
                return
            end
            out = isa(dt,'Simulink.NumericType') && ...
                strncmp(dt.DataTypeMode,'Fixed-point',11);
        end
        function out = getRealWorldValue(symbol,SimulinkDataType)
            if isempty(symbol.Value)
                out = [];
                return
            end
            % Use fi object to convert stored integer value to real world
            % value.  Need to validate license / installation requirement.
            fiobj = fi(0,eval(SimulinkDataType));
            fiobj.int = symbol.Value;
            out = fiobj.double;
        end
    end
    
    % Dialog callback methods
    methods
        function out = getCheckableProperty(~)
            out = 'Selected';
        end
        function out = getContextMenuImpl(obj,nodes,me,cm)
            callback = me.getActionCallbackName;
            am = DAStudio.ActionManager;
            if isempty(cm)
                cm = am.createPopupMenu(me);
            else
                cm.addSeparator;
            end
            cm.addMenuItem(am.createAction(me,...
                'text',DAStudio.message('Simulink:utility:SIMenuImportToWorkspace'),...
                'icon','',...
                'enabled',Simulink.symbol.Object.getOnOff(obj.Selected),...
                'callback',[callback '(''list'',''importToWorkspaceCB'')']));
            cm.addSeparator;
            showAll = false;
            multipleNodes = false;
            if length(nodes) > 1
                multipleNodes = true;
                root = obj.getRoot;
                if root.ShowAll
                    showAll = true;
                end
            end
            cm.addMenuItem(am.createAction(me,...
                    'text',DAStudio.message('Simulink:utility:SIMenuDelete'),...
                    'icon','',...
                    'enabled',Simulink.symbol.Object.getOnOff(multipleNodes || obj.Selected),...
                    'callback',[callback '(''list'',''deleteCB'')']));
            cm.addMenuItem(am.createAction(me,...
                    'text',DAStudio.message('Simulink:utility:SIMenuUndelete'),...
                    'icon','',...
                    'enabled',Simulink.symbol.Object.getOnOff((multipleNodes && showAll) || ~obj.Selected),...
                    'callback',[callback '(''list'',''undeleteCB'')']));
            out = cm;
        end
        function out = getDisplayIcon(obj)
            if obj.Selected
                out = '';
            else
                out = [Simulink.symbol.Object.getIconPath 'delete.gif'];
            end
        end
        function out = getPreferredProperties(~)
            out = {'SimulinkDataType','SimulinkClass'};
        end
        function out = isEditableProperty(~,propName)
            switch propName
                case {'Selected','SimulinkDataType','SimulinkClass','RTWStorageClass'}
                    out = true;
                otherwise
                    out = false;
            end
        end
        function out = isReadonlyProperty(obj,~)
            out = ~obj.Selected;
        end
    end
    methods
        function out = isHidden(obj)
            out = ~obj.Selected;
        end
    end
    methods
        function out = importToWorkspaceCB(obj)
            out = '';
            if evalin('base',['exist(''' obj.Name ''',''var'')'])
                buttonName = questdlg(...
                    DAStudio.message('Simulink:utility:SIOverwritePrompt',obj.Name),...
                    DAStudio.message('Simulink:utility:SITitle'),...
                    DAStudio.message('Simulink:utility:SIOK'),...
                    DAStudio.message('Simulink:utility:SICancel'),...
                    DAStudio.message('Simulink:utility:SICancel'));
                if ~strcmp(buttonName,DAStudio.message('Simulink:utility:SIOK'));
                    return
                end
            end
            obj.importToWorkspace;
            root = obj.getRoot;
            if isa(root.SymbolDlg,'DAStudio.Dialog')
                delete(root.SymbolDlg);
            end
            if evalin('base',['isa(' obj.Name ',''DAStudio.Object'');'])
                root.SymbolDlg = DAStudio.Dialog(evalin('base',obj.Name));
            else
                openvar(obj.Name);
            end
        end
        function out = deleteCB(obj)
            obj.Selected = false;
            out = {'HierarchyChangedEvent','PropertyChangedEvent'};
        end
        function out = undeleteCB(obj)
            obj.Selected = true;
            out = {'HierarchyChangedEvent','PropertyChangedEvent'};
        end
    end
end
