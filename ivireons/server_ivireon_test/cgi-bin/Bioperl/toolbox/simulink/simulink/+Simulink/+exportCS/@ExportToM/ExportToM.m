% Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.6.8 $


classdef ExportToM < handle
    properties (SetAccess=public)   % properties
        obj = [];
        AncestorSetList=[];
        DAGSimpleRootHash = [];
        DAGSimpleRoot = [];
        nOfParams = [];
        printed = [];        
        printlist = [];
        printlistidx = [];
        scriptRaw = [];
        scriptFinal = [];
        scriptfinalidx = [];
        paramHash = [];
        filename = [];
        outputFormat = [];
        variableName = [];
        update = [];
        isCustomTarget = [];
        configSetPane = [];
        paneManager = [];
        paneManagerIdx = [];
        additionalComponentClass = [];
        outputBuffer = [];
        outputBufferIdx = [];
        uiNameHash = [];
        description = [];
        name = [];
    end

    properties (SetAccess=public, Hidden=true)
        csCopyFrom = [];
        csCopyFromParamHash = [];
    end
    
    methods        
        function etm = ExportToM()     % constructor
            etm.initialize();
        end
    end

    methods
        function initialize(etm, format)
            etm.AncestorSetList = cell(1,1);
            etm.DAGSimpleRootHash = containers.Map('KeyType', 'int32', 'ValueType', 'int32');
            etm.printed = containers.Map('KeyType', 'int32', 'ValueType', 'int32');
            etm.printlist = cell(1,1);
            etm.printlistidx = 1;
            etm.paramHash = containers.Map; 
            etm.csCopyFromParamHash = containers.Map;
            etm.scriptfinalidx=0;
            etm.variableName = 'cs';
            etm.update = 'update';
            etm.isCustomTarget = false;
            etm.configSetPane = containers.Map;
            etm.outputBufferIdx = 0;
            etm.uiNameHash = containers.Map;
            
            if nargin>1
                etm.outputFormat = format;
            end
        end
    end

    methods                         % all other methods
        export(etm, cs, filename, argName, argValue)
        constructCSP(etm)
        preprocess(etm, noComment)
        generate(etm, update, noComment, timestamp, encoding)
        print(etm, id, noComment, addIndent)
        saveToBuffer(etm, scriptline, id, bridge, special, specialInfo)
        result = bridge(etm, cs)
        result = generateToBridge(etm, noComment)
        printToBridge(etm, id)
    end
    
    methods
        function r = isOutputFormatFunction(etm)
            if strcmpi(etm.outputFormat, 'MATLAB function')
                r = true;
            else
                r = false;
            end
        end
    end

    methods
        function populateConfigSetPane(etm, noComment)
            if noComment
                return;
            end
            
            hash = etm.configSetPane;
            hash('Solver') = '1';
            hash('Data Import/Export') = '2';
            hash('Optimization') = '3';
            hash('Diagnostics') = '4';
            hash('Diagnostics/Sample Time') = '4.1';
            hash('Diagnostics/Data Validity') = '4.2';
            hash('Diagnostics/Type Conversion') = '4.3';
            hash('Diagnostics/Connectivity') = '4.4';
            hash('Diagnostics/Compatibility') = '4.5';
            hash('Diagnostics/Model Referencing') = '4.6';
            hash('Diagnostics/Saving') = '4.7';
            hash('Diagnostics/Stateflow') = '4.8';
            hash('Hardware Implementation') = '5';
            hash('Model Referencing') = '6';
            hash('Simulation Target') = '7';
            hash('Simulation Target/Symbols') = '7.1';
            hash('Simulation Target/Custom Code') = '7.2';
            hash('Real-Time Workshop') = '8';
            hash('Real-Time Workshop/Report') = '8.1';
            hash('Real-Time Workshop/Comments') = '8.2';
            hash('Real-Time Workshop/Symbols') = '8.3';
            hash('Real-Time Workshop/Custom Code') = '8.4';
            hash('Real-Time Workshop/Debug') = '8.5';
            hash('Real-Time Workshop/Interface') = '8.6';
            hash('Real-Time Workshop/Code Style') = '8.7';
            hash('Real-Time Workshop/Templates') = '8.8';
            hash('Real-Time Workshop/Data Placement') = '8.9';
            hash('Real-Time Workshop/Data Type Replacement') = '8.10';
            hash('Real-Time Workshop/Memory Sections') = '8.11';
            hash('totalNumOf-Real-Time Workshop-Pane') = 11;
            hash('totalNumOfMajorPane') = 8;
            etm.configSetPane = hash;
        end
    end
end
