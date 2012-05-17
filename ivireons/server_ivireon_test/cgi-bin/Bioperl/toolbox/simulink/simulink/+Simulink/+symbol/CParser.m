
%   Copyright 2010 The MathWorks, Inc.

classdef CParser < handle
    properties
        Name = 'C Parser'
        LastMessage
        UserConfig
    end
    properties (Transient)
        Config
    end
    properties (Hidden)
        Parent
        SymbolFactory
    end
    properties (Access=private)
        SLTypeMap
    end
    properties (Constant,Hidden)
        BuiltInSLType = {...
            'int8','int16','int32','int64',...
            'uint8','uint16','uint32','uint64',...
            'single','double','logical'};
    end
    methods
        function obj = CParser(config)
            % EDG parser configuration
            if nargin == 0
                obj.Config = obj.setup;
            else
                obj.Config = config;
            end
            obj.SymbolFactory = Simulink.symbol.Factory;
            obj.UserConfig.Defines = {};
        end
        function out = parse(obj,file,varargin)
            if isempty(obj.Config)
                obj.Config = obj.setup;
            end
            config = obj.Config;
            config.Preprocessor.Defines = [config.Preprocessor.Defines ....
                obj.UserConfig.Defines];
            [obj.LastMessage symbols] = slfrontend_mex(file, config, 1);
            h = legacycode.util.lci_parsedSymbolsHelper(symbols);
            out = {};
            opts = slprivate('parseArgs',struct('var',true,'type',true,...
                'function',true),varargin{:});
            % variables
            if opts.var
                variables = h.getVariables;
                out = cell(1,length(variables));
                % cell h.getNumxx
                for k=1:length(variables)
                    v = obj.createCVariable(h,k);
                    if ~isempty(v)
                        out{k} = v;
                    end
                end
            end
            % typedefs
            if opts.type
                types = h.getTypes;
                for k=1:length(types)
                    t = types{k};
                    headerFile = '';
                    if isfield(t,'FileIdx') && ~isempty(t.FileIdx)
                        if t.FileIdx ~= 1, continue, end
                        rec = h.getFileRecord(t.FileIdx);
                        if rec.IsSystemFile, continue, end
                        if rec.IsIncludedFile
                            headerFile = rec.Name;
                        end
                    end
                    ctype = [];
                    switch t.Ctor
                        case 'typedef'
                            if isempty(t.Name) || t.Name(1) == '_'
                                continue
                            end
                            baseType = h.getTypeRecord(t.BaseIdx);
                            if strcmp(baseType.Ctor,'struct')
                                ctype = obj.createCStructType(h,t.BaseIdx);
                                ctype.Name = t.Name;
                            else
                                ctype = obj.SymbolFactory.newCTypename(t.Name);
                                ctype.Type = h.getTypeCName(t.BaseIdx);
                            end
                            if ~isempty(headerFile)
                                ctype.HeaderFile = headerFile;
                            end
                            ctype.Position = t.Position;
                        case 'struct'
                            if ~isempty(h.getTypeName(k))
                                ctype = obj.createCStructType(h,k);
                            end
                        case 'enum'
                            % not supported yet
                    end
                    if ~isempty(ctype)
                        out{end+1} = ctype;
                    end
                end
            end
            % functions
            if opts.function
                for k=1:h.getNumFunctions
                    if h.getFunctionFile(k) == 1
                        returnType = h.getTypeFunctionReturnType(k);
                        if isempty(returnType)
                            returnType = 'void';
                        else
                            returnType = h.getTypeName(returnType);
                        end
                        cfunction = obj.SymbolFactory.newCFunction(...
                            h.getFunctionName(k),returnType);
                        
                        % do not import functions
                        if isempty(cfunction), break, end
                        
                        cfunction.Position = h.getFunctionPosition(k);
                        if ~isempty(h.getFunctionArgNames(k))
                            for n=1:h.getFunctionNumArgs(k)
                                argName = h.getFunctionArgName(k,n);
                                argType = h.getTypeName(h.getFunctionArgType(k,n));
                                arg = obj.SymbolFactory.newCVariable(argName,argType);
                                arg.Storage = 'auto';
                                arg.Position = cfunction.Position;
                                cfunction.setArgument(n,arg);
                            end
                        end
                        out{end+1} = cfunction;
                    end
                end
            end
            % macros
        end
    end
    methods (Static)
        function out = setup
            config =  legacycode.util.lci_parserConfig;
            config.RemoveUnneededEntities = false;
            config.DoIlLowering = false;
            config.Preprocessor.IncludeDirs = {fullfile(matlabroot,'simulink','include')};

            out = config;
        end
        
        function out = refreshSetup
            legacycode.ParserConfig.resetPreferences;
            out = Simulink.symbol.CParser.setup;
        end
    end
    methods
        function out = getDialogAgentClassName(~)
            out = 'Simulink.SymbolDialogBase';
        end
    end
    methods
        function dlgstruct = getDialogSchema(obj,name)
            tag = 'CParser_Config_';
            
            PreprocessorDialog_widget = obj.getPreprocessorDialogWidget(name);
            TargetDialog_widget = obj.getTargetDialogWidget(name);
            
            % Auto-detect button
            widget = [];
            widget.Name = 'Auto-detect';
            widget.ToolTip = 'Automatically detect host system include directories and number of bits';
            widget.Tag = [tag 'AutoDetectButton'];
            widget.Type = 'pushbutton';
            widget.ObjectMethod = 'dialogCallback';
            widget.MethodArgs = {'%dialog', widget.Tag, 'AutoDetect'};
            widget.ArgDataTypes = {'handle', 'string', 'string'};
            widget.Mode = 1;
            widget.DialogRefresh = 1;
            AutoDetectButton_widget = widget;
            
            PreprocessorDialog_widget.RowSpan = [1 1];
            PreprocessorDialog_widget.ColSpan = [1 2];
            TargetDialog_widget.RowSpan = [2 2];
            TargetDialog_widget.ColSpan = [1 2];
            AutoDetectButton_widget.RowSpan = [3 3];
            AutoDetectButton_widget.ColSpan = [1 1];
            
            dlgstruct.DialogTitle = 'C Parser Configuration';
            dlgstruct.Items = {...
                PreprocessorDialog_widget,...
                TargetDialog_widget,...
                AutoDetectButton_widget}; %obj.targetDialogWidgets;
            dlgstruct.LayoutGrid = [2 2];
            dlgstruct.ColStretch = [0 1];
        end
        function widgets = getTargetDialogWidget(obj,~)
            widget = [];
            widget.Name = 'Number of bits';
            widget.Type = 'text';
            widget.ToolTip = 'Number of bits';
            numOfBits = widget;

            [numOfBitsChar_Lbl, numOfBitsChar] = ...
                obj.getNumOfBitsWidget('char:','CharNumBits',1,2);
            [numOfBitsShort_Lbl, numOfBitsShort] = ...
                obj.getNumOfBitsWidget('short:','ShortNumBits',1,4);
            [numOfBitsInt_Lbl, numOfBitsInt] = ...
                obj.getNumOfBitsWidget('int:','IntNumBits',1,6);
            [numOfBitsLong_Lbl, numOfBitsLong] = ...
                obj.getNumOfBitsWidget('long:','LongNumBits',2,2);
            [numOfBitsPointer_Lbl, numOfBitsPointer] = ...
                obj.getNumOfBitsWidget('pointer:','PointerNumBits',2,4);
            
            numOfBits.RowSpan = [1 1];
            
            tag = 'CParser_Config_Language_';
            widget = [];
            widget.Type = 'checkbox';
            widget.Name = 'Plain char is signed';
            widget.Tag = [tag 'PlainCharsAreSigned'];
            widget.Value = obj.Config.Language.PlainCharsAreSigned;
            widget.ObjectMethod = 'dialogCallback';
            widget.MethodArgs = {'%dialog', widget.Tag, 'checkbox'};
            widget.ArgDataTypes = {'handle', 'string', 'string'};
            plainCharsAreSigned_widget = widget;
            plainCharsAreSigned_widget.RowSpan = [3 3];
            plainCharsAreSigned_widget.ColSpan = [1 7];
                
            widget = [];
            widget.Type = 'group';
            widget.Name = 'Target Configuration';
            widget.LayoutGrid = [3 7];
            widget.Items = {numOfBits,...
                numOfBitsChar_Lbl,numOfBitsChar,...
                numOfBitsShort_Lbl,numOfBitsShort,...
                numOfBitsInt_Lbl,numOfBitsInt,...
                numOfBitsLong_Lbl,numOfBitsLong,...
                numOfBitsPointer_Lbl,numOfBitsPointer,...
                plainCharsAreSigned_widget};
            widgets = widget;
        end
        function widgets = getPreprocessorDialogWidget(obj,~)
            tag = 'CParser_Config_Preprocessor_';
            widget = [];
            widget.Name = 'Defines:';
            widget.Type = 'editarea';
            widget.ToolTip = 'Enter #defines needed to compile C code parsing in the form of ''MACRONAME=VALUE'', one per each line';
            widget.MaximumSize = [500, 70];
            widget.Tag = [tag 'Defines'];
            if isempty(obj.UserConfig.Defines)
                widget.Value = '';
            else
                widget.Value = sprintf('%s\n',obj.UserConfig.Defines{:});
            end
            widget.ObjectMethod = 'dialogCallback';
            widget.MethodArgs = {'%dialog', widget.Tag, 'editarea'};
            widget.ArgDataTypes = {'handle', 'string', 'string'};
            widget.Mode = 0;
            Defines_widget = widget;
            
            widget = [];
            widget.Name = 'User include directories:';
            widget.Type = 'editarea';
            widget.ToolTip = 'Enter directories to be added to the include path, one per each line.';
            widget.MaximumSize = [500, 70];
            widget.Tag = [tag 'IncludeDirs'];
            if isempty(obj.Config.Preprocessor.IncludeDirs)
                widget.Value = '';
            else
                widget.Value = sprintf('%s\n',obj.Config.Preprocessor.IncludeDirs{:});
            end
            widget.ObjectMethod = 'dialogCallback';
            widget.MethodArgs = {'%dialog', widget.Tag, 'editarea'};
            widget.ArgDataTypes = {'handle', 'string', 'string'};
            widget.Mode = 0;            
            %widget.Alignment = 2;
            IncludeDirs_widget = widget;
            
            widget = [];
            widget.Name = 'System include directories:';
            widget.Type = 'editarea';
            widget.Tag = [tag 'SystemIncludeDirs'];
            widget.ToolTip = 'Enter directories to be added to the include path for system headers, one per each line';
            widget.MaximumSize = [500, 70];
            widget.Value = obj.Config.Preprocessor.SystemIncludeDirs;
            if isempty(obj.Config.Preprocessor.SystemIncludeDirs)
                widget.Value = '';
            else
                widget.Value = sprintf('%s\n',obj.Config.Preprocessor.SystemIncludeDirs{:});
            end
            widget.ObjectMethod = 'dialogCallback';
            widget.MethodArgs = {'%dialog', widget.Tag, 'editarea'};
            widget.ArgDataTypes = {'handle', 'string', 'string'};
            widget.Mode = 0;
            %widget.Alignment = 2;
            SystemIncludeDirs_widget = widget;
            
            IncludeGroup = [];
            IncludeGroup.Type = 'group';
            IncludeGroup.Name = 'Preprocessor Setup';
            IncludeGroup.Items = {Defines_widget,IncludeDirs_widget,SystemIncludeDirs_widget};
            
            widgets = IncludeGroup;
        end
        function [widget_lbl,widget] = getNumOfBitsWidget(obj,label,property,row,col)
            widget_lbl.Name = label;
            widget_lbl.Type = 'text';
            widget_lbl.RowSpan = [row row];
            widget_lbl.ColSpan = [col col];
            
            widget.Type = 'edit';
            widget.Tag = ['CParser_Config_Target_' property];
            widget.Value = obj.Config.Target.(property);
            widget.ObjectMethod = 'dialogCallback';
            widget.MethodArgs = {'%dialog', widget.Tag, 'number'};
            widget.ArgDataTypes = {'handle', 'string', 'string'};
            widget.Mode = 0;
            widget.MaximumSize = [50 50];
            widget.RowSpan = [row row];
            widget.ColSpan = [col+1 col+1];
        end
        function dialogCallback(obj,dlg,widgetTag,action)
            switch action
                case 'number'
                    fields = textscan(widgetTag,'%s','Delimiter','_');
                    obj.Config.(fields{1}{3}).(fields{1}{4}) = ...
                        str2double(getWidgetValue(dlg,widgetTag));
                case 'editarea'
                    fields = textscan(widgetTag,'%s','Delimiter','_');
                    value = obj.getTextWidgetValue(dlg,widgetTag);
                    obj.Config.(fields{1}{3}).(fields{1}{4}) = value;
                case 'checkbox'
                    fields = textscan(widgetTag,'%s','Delimiter','_');
                    value = getWidgetValue(dlg,widgetTag);
                    obj.Config.(fields{1}{3}).(fields{1}{4}) = value;
                case 'UserConfig'
                    fields = textscan(widgetTag,'%s','Delimiter','_');
                    value = obj.getTextWidgetValue(dlg,widgetTag);
                    obj.UserConfig.(fields{1}{4}) = value;
                case 'AutoDetect'
                    dlg.setEnabled(widgetTag,false);
                    obj.Config = Simulink.symbol.CParser.refreshSetup;
                    dlg.setEnabled(widgetTag,true);
            end
            legacycode.ParserConfig.setPreference('Config',obj.Config);
        end
    end
    methods (Static)
        function out = getTextWidgetValue(dlg,widgetTag)
            value = getWidgetValue(dlg,widgetTag);
            if isempty(value)
                value = {};
            else
                value = textscan(value,'%s','Delimiter','\n');
                value = transpose(value{1});
            end
            out = value;
        end
        function out = targetConfig
            hostInfo = rtwhostwordlengths;
            target.Endianness = 'little'; 
            target.CharNumBits = hostInfo.CharNumBits;
            target.ShortNumBits = hostInfo.ShortNumBits;
            target.IntNumBits = hostInfo.IntNumBits;
            target.LongNumBits = hostInfo.LongNumBits;
            target.LongLongNumBits = 64;
            target.FloatNumBits = 32;
            target.DoubleNumBits = 64;
            target.LongDoubleNumBits = 64;
            target.PointerNumBits = hostInfo.IntNumBits;
            out = target;
        end
    end
    methods
        function out = getTypeSLName(obj,cTypeName)
            if isempty(obj.SLTypeMap)
                obj.SLTypeMap = obj.constructSLTypeMap;
            end
            if iskey(obj.SLTypeMap(cTypeName))
                out = obj.SLTypeMap(cTypeName);
            else
                out = '';
            end
        end
    end
    methods (Static)
        function out = getTypeSLMap
            out = Simulink.symbol.CParser.constructSLTypeMap;
        end
        function out = isBuiltInSLType(typename)
            out = any(strcmp(typename,Simulink.symbol.CParser.BuiltInSLType));
        end
    end
    methods (Static,Access=private)
        function out = constructSLTypeMap
            target = Simulink.symbol.CParser.targetConfig;
            map = containers.Map;
            map('char') = sprintf('int%d',target.CharNumBits);
            map('short') = sprintf('int%d',target.ShortNumBits);
            map('int') = sprintf('int%d',target.IntNumBits);
            map('long') = sprintf('int%d',target.LongNumBits);
            map('unsigned char') = sprintf('uint%d',target.CharNumBits);
            map('unsigned short') = sprintf('uint%d',target.ShortNumBits);
            map('unsigned int') = sprintf('uint%d',target.IntNumBits);
            map('unsigned long') = sprintf('uint%d',target.LongNumBits);
            map('float') = 'single';
            map('double') = 'double';
            out = map;
        end
    end
    methods
        function out = createCStructType(obj,h,idx)
            rec = h.getTypeRecord(idx);
            name = rec.Name;
            if isempty(name), name = ''; end
            out = obj.SymbolFactory.newCStructType(name);
            out.Position = rec.Position;
            fields = cell(h.getTypeNumElements(idx),1);
            for k=1:h.getTypeNumElements(idx)
                typeIdx = h.getTypeElementType(idx,k);
                type = obj.createCType(h,typeIdx);
                name = h.getTypeElementName(idx,k);
                cvar = obj.SymbolFactory.newCVariable(name,type);
                if isa(cvar,'Simulink.symbol.CVariableImport')
                    sltype = h.getTypeSLName(h.getTypeBottom(typeIdx));
                    if ~isempty(sltype)
                        cvar.setAutoSimulinkDataType(sltype);
                    end
                end
%                 if h.isTypePointer(type)
%                     basetype = h.getTypeBase(type);
%                     typename = [h.getTypeName(basetype) '*'];
%                     if h.isTypeStruct(basetype)
%                         typename = ['struct ' typename]; %#ok<AGROW>
%                     end
%                     cvar = obj.SymbolFactory.newCVariable(name,typename);
%                 elseif h.isTypeStruct(type)
%                     % recursive structure
%                     cvar = obj.createCStructType(h,type);
%                     cvar.Name = ['struct ' name];
%                 else
%                     if h.isTypePointer(type)
%                         cvar.Type = [cvar.Type '*'];
%                     end
%                 end
                fields{k} = cvar;
            end
            out.setFields(fields);
        end
        function out = getValue(~,h,v)
            if isempty(v.Value), out = v.Value; return, end
            if ~iscell(v.Value)
                value = {v.Value};
            else
                value = v.Value;
            end
            out = cell(size(value));
            for k=1:length(value)
                if h.isTypeStruct(v.DataTypeIdx)
                    out{k} = value{k};
                elseif isstruct(value{k})
                    if strcmp(value{k}.kind,'VarAddr')
                        out{k} = ['&' value{k}.ObjectName];
                    else
                        out{k} = [value{k}.kind ' ' value{k}.ObjectName];
                    end
                else
                    out{k} = value{k};
                end
            end
            if ~iscell(v.Value)
                out = out{1};
            end
        end
        function out = createCVariable(obj,h,idx)
            v = h.getVariableRecord(idx);
            
            type = createCType(obj,h,v.DataTypeIdx);
            cvar = obj.SymbolFactory.newCVariable(v.Name,type);
            cvar.Value = obj.getValue(h,v);
            cvar.Position = v.Position;
            cvar.Storage = v.Storage;
            if isa(cvar,'Simulink.symbol.CVariableImport')
                baseTypeIdx = h.getTypeBottom(v.DataTypeIdx);
                if h.isTypeAggregate(baseTypeIdx)
                    cvar.setAutoSimulinkDataType('struct');
                else
                    sltype = h.getTypeSLName(h.getTypeBottom(v.DataTypeIdx));
                    if ~isempty(sltype)
                        cvar.setAutoSimulinkDataType(sltype);
                    end
                end
            end
            if ~ischar(cvar.Type)
                cvar.Type.Parent = cvar;
            end
            out = cvar;
        end
        function out = createCType(obj,h,idx)
            baseTypeIdx = idx;
            type = '';
            % get base type
            while h.isTypePointer(baseTypeIdx) || ...
                  h.isTypeArray(baseTypeIdx),
                if h.isTypePointer(baseTypeIdx)
                    type = ['*' type]; %#ok<AGROW>
                else % array
                    if ~isempty(type) && type(end) ~= ']'
                        type = ['(' type ')']; %#ok<AGROW>
                    end
                    type = [type sprintf('[%d]',h.getTypeDimensions(baseTypeIdx))]; %#ok<AGROW>
                end
                baseTypeIdx = h.getTypeBase(baseTypeIdx);
            end
            if h.isTypeStruct(baseTypeIdx)
                if ~isempty(h.getTypeName(baseTypeIdx))
                    type = ['struct ' h.getTypeName(baseTypeIdx) type];
                else
                    % here struct should not be annoymous
                    assert(isempty(type));
                    type = createCStructType(obj,h,idx);
                end
            else
                type = [h.getTypeName(baseTypeIdx) type];
            end
            out = type;
        end
    end
end
