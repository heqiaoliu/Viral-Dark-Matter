
%   Copyright 2010 The MathWorks, Inc.

classdef CStructType < Simulink.symbol.CTypename
    properties
        Fields = {}
    end
    methods
        function obj = CStructType(name)
            obj = obj@Simulink.symbol.CTypename(name);
            obj.Type = 'struct';
        end
        function setFields(obj,fields)
            if ~iscell(fields)
                DAStudio.error('Simulink:utility:invalidInputArgs');
            end
            for k=1:length(fields)
                if ~isa(fields{k},'Simulink.symbol.Symbol')
                    DAStudio.error('Simulink:utility:invalidInputArgs');
                end
                fields{k}.Parent = obj;
            end
            obj.Fields = fields;
        end
        function out = char(obj)
            if isempty(obj.Name)
                out = obj.Type;
            else
                out = [obj.Type ' ' obj.Name];
            end
        end
    end
    methods
        function out = getDialogAgent(obj)
            for k=1:length(obj.Fields)
                % create DialogAgent of children upfront
                obj.Fields{k}.getDialogAgent;
            end
            out = getDialogAgent@Simulink.symbol.CTypename(obj);
        end
        
        function dlgstruct = getDialogSchema(obj, ~)
            
            CStructTbl.Type = 'table';
            CStructTbl.Size = [length(obj.Fields) 3];
            CStructTbl.Grid = true;
            CStructTbl.HeaderVisibility = [0 1];
            CStructTbl.RowHeader = {'col 1', 'col 2', 'col 3'};
            CStructTbl.ColHeader =  {sprintf('Name'),...
                                sprintf('Type'),...
                                sprintf('SimulinkDataType')}; 
            
            CStructTbl.Editable = true;
            CStructTbl.ValueChangedCallback = @onValueChanged;
            CStructTbl.ColumnCharacterWidth = [6 6 12]; 
            CStructTbl.ReadOnlyColumns = [0 1];
            
            Data = cell(length(obj.Fields), 3);
            
            for i=1:length(obj.Fields)
                s = obj.Fields{i};
                
                % name
                CStrName.Type = 'edit';
                CStrName.Value = s.Name;
                Data{i, 1} = CStrName;
                
                % type
                CStrType.Type = 'edit';
                CStrType.Value = s.Type;
                Data{i, 2} = CStrType;
                
                % simulink data type
                slDataType.Type = 'edit';
                slDataType.Value = s.SimulinkDataType;
                Data{i, 3} = slDataType;
            end
            
            CStructTbl.Data = Data;
            
            grp.Items = {CStructTbl};
            grp.LayoutGrid = [1 2];
            grp.Type = 'group';
            
            dlgstruct.DialogTitle = ['Table view of C struct type: ' obj.getDisplayLabel];
            dlgstruct.Items = {grp};
            dlgstruct.EmbeddedButtonSet = {''};
        
            function onValueChanged(~, r, ~, val)
                obj.Fields{r+1}.SimulinkDataType = val;
                r = obj.getRoot;
                r.setDirty;
            end
        end
            
    end
    % dialog callbacks
    methods
        function out = getChildren(obj)
            out = obj.Fields;
        end
        function out = getHierarchicalChildren(~)
            %out = obj.Fields;
            out = [];
        end
    end
end
