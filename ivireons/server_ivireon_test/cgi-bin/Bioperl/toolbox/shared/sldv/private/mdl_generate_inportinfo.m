function varargout = mdl_generate_inportinfo(modelH, testcomp, storeOnTestComponent, strictBusErros)
% Function: mdl_generate_inportinfo ====================================
% Abstract:
%   This function resolves the compiled Inport and Outport attributes of the modelH.
%   modelH must be in compiled state when you invoke this utility. It
%   stores the following info about the model on the testComponent, if 
%   storeOnTestComponent is true:
%
%   Case 1: {Inport,Outport} i is defined by the bus object 'bus':
%
%                           signal_1
%               sub_bus  [------------
%            [===========[  signal_2  
%       bus  [  signal_3 [------------
%    >=======[----------
%            [  signal_4
%            [----------
%
%   testcomp.mdlFlatIOInfo.{Inport,Outport}(i).BlockPath = ...;
%   testcomp.mdlFlatIOInfo.{Inport,Outport}(i).SignalName = ...;
%   testcomp.mdlFlatIOInfo.{Inport,Outport}(i).IsStructBus = 1;
%   testcomp.mdlFlatIOInfo.{Inport,Outport}(i).IsVirtualBus = 1;
%   testcomp.mdlFlatIOInfo.{Inport,Outport}(i).IsStruct = 0;
%   if strictBusErrors == false
%       testcomp.mdlFlatIOInfo.{Inport,Outport}(i).CompiledBusType = get_param(portH,'CompiledBusType')
%       testcomp.mdlFlatIOInfo.{Inport,Outport}(i).SignalHierarchy = get_param(portH,'SignalHierarchy') 
%   else
%       testcomp.mdlFlatIOInfo.{Inport,Outport}(i).CompiledBusType = []
%       testcomp.mdlFlatIOInfo.{Inport,Outport}(i).SignalHierarchy = []
%   end
%   testcomp.mdlFlatIOInfo.{Inport,Outport}(i).SampleTime = .. Compiled sample time of Inport i
%   testcomp.mdlFlatIOInfo.{Inport,Outport}(i).SampleTimeStr = .. Compiled sample time string
%   testcomp.mdlFlatIOInfo.{Inport,Outport}(i).compiledInfo(1).DataType = ...
%   testcomp.mdlFlatIOInfo.{Inport,Outport}(i).compiledInfo(1).Complexity = ...
%   testcomp.mdlFlatIOInfo.{Inport,Outport}(i).compiledInfo(1).Dimensions = ...
%   testcomp.mdlFlatIOInfo.{Inport,Outport}(i).compiledInfo(1).SampleTime = ...
%   testcomp.mdlFlatIOInfo.{Inport,Outport}(i).compiledInfo(1).BusObjPath = 'bus.sub_bus'
%   testcomp.mdlFlatIOInfo.{Inport,Outport}(i).compiledInfo(1).SignalPath = 'In.elem(1)_name.elem(1)_name'
%   testcomp.mdlFlatIOInfo.{Inport,Outport}(i).compiledInfo(1).Used = true
%   testcomp.mdlFlatIOInfo.{Inport,Outport}(i).compiledInfo(2).DataType = ...
%   testcomp.mdlFlatIOInfo.{Inport,Outport}(i).compiledInfo(2).Complexity = ...
%   testcomp.mdlFlatIOInfo.{Inport,Outport}(i).compiledInfo(2).Dimensions = ...
%   testcomp.mdlFlatIOInfo.{Inport,Outport}(i).compiledInfo(2).SampleTime = ...
%   testcomp.mdlFlatIOInfo.{Inport,Outport}(i).compiledInfo(2).BusObjPath = 'bus.sub_bus'
%   testcomp.mdlFlatIOInfo.{Inport,Outport}(i).compiledInfo(2).SignalPath = 'In.elem(1)_name.elem(2)_name'
%   testcomp.mdlFlatIOInfo.{Inport,Outport}(i).compiledInfo(2).Used = true
%   testcomp.mdlFlatIOInfo.{Inport,Outport}(i).compiledInfo(3).DataType = ...
%   testcomp.mdlFlatIOInfo.{Inport,Outport}(i).compiledInfo(3).Complexity = ...
%   testcomp.mdlFlatIOInfo.{Inport,Outport}(i).compiledInfo(3).Dimensions = ...
%   testcomp.mdlFlatIOInfo.{Inport,Outport}(i).compiledInfo(3).SampleTime = ...
%   testcomp.mdlFlatIOInfo.{Inport,Outport}(i).compiledInfo(3).BusObjPath = 'bus'
%   testcomp.mdlFlatIOInfo.{Inport,Outport}(i).compiledInfo(3).SignalPath = 'In.elem(2)_name'
%   testcomp.mdlFlatIOInfo.{Inport,Outport}(i).compiledInfo(3).Used = true
%   testcomp.mdlFlatIOInfo.{Inport,Outport}(i).compiledInfo(4).DataType = ...
%   testcomp.mdlFlatIOInfo.{Inport,Outport}(i).compiledInfo(4).Complexity = ...
%   testcomp.mdlFlatIOInfo.{Inport,Outport}(i).compiledInfo(4).Dimensions = ...
%   testcomp.mdlFlatIOInfo.{Inport,Outport}(i).compiledInfo(4).SampleTime = ...
%   testcomp.mdlFlatIOInfo.{Inport,Outport}(i).compiledInfo(4).BusObjPath = 'bus'
%   testcomp.mdlFlatIOInfo.{Inport,Outport}(i).compiledInfo(4).SignalPath = 'In.elem(3)_name'
%   testcomp.mdlFlatIOInfo.{Inport,Outport}(i).compiledInfo(4).Used = true
%
%   Important: We need to store testcomp.SampleTime because Bus Objects may
%   inherit sample times from the Inport or Outport. 
%
%   Case 2: {Inport,Outport} i is NOT defined by a bus object
%
%      signal_1
%   >------------
%
%   testcomp.mdlFlatIOInfo.{Inport,Outport}(i).BlockPath = ...;
%   testcomp.mdlFlatIOInfo.{Inport,Outport}(i).SignalName = ...;
%   testcomp.mdlFlatIOInfo.{Inport,Outport}(i).IsStructBus = 0;
%   testcomp.mdlFlatIOInfo.{Inport,Outport}(i).IsVirtualBus = 0;
%   testcomp.mdlFlatIOInfo.{Inport,Outport}(i).IsStruct = 0;
%   testcomp.mdlFlatIOInfo.{Inport,Outport}(i).SampleTime = .. Compiled sample time of Inport i
%   testcomp.mdlFlatIOInfo.{Inport,Outport}(i).SampleTimeStr = .. Compiled sample time string
%   testcomp.mdlFlatIOInfo.{Inport,Outport}(i).compiledInfo.DataType = ...
%   testcomp.mdlFlatIOInfo.{Inport,Outport}(i).compiledInfo.Complexity = ...
%   testcomp.mdlFlatIOInfo.{Inport,Outport}(i).compiledInfo.Dimensions = ...
%   testcomp.mdlFlatIOInfo.{Inport,Outport}(i).compiledInfo.SignalPath = 'In'
%
%   If storeOnTestComponent=false, the it returns mdlFlatIOInfo structure
%   mentioned above. 
%
%   If strictBusErrors=true, then the model gives error messages when
%   StrictBusMsg is set to error

%   Copyright 2008-2010 The MathWorks, Inc.


    if nargin<2
        storeOnTestComponent = false;
    end
    
    if nargin<3
        strictBusErros = false;        
    end
    
    if storeOnTestComponent
        % If there is test component attached to the model, then obtain the
        % whether model errors when StrictBusMsg is set to error. This
        % information is obtained when we compile the model for coverage.
        strictBusErros = testcomp.analysisInfo.strictBusErros;
    end
      
    [inPortsInfo, outPortsInfo] = GetModelInOutPorts(modelH);      
    
    InputCache = genPortCache(inPortsInfo, strictBusErros);       
    
    [lastmsg, lastid] = lastwarn;
     
    warningId = 'Simulink:blocks:StrictMsgIsSetToNonStrict';
    warningstatus = warning('query',warningId);    
    warning('off',warningId);
    
    OutputCache = genPortCache(outPortsInfo, strictBusErros);
    
    warning(warningstatus.state,warningId);
    
    lastwarn(lastmsg,lastid);
        
    mdlFlatIOInfo.Inport = InputCache;
    mdlFlatIOInfo.Outport = OutputCache;
             
    if storeOnTestComponent        
        testcomp.mdlFlatIOInfo =  mdlFlatIOInfo;
        testcomp.createableSimData = checkInputForFixedPoint(InputCache);
    else
        varargout{1} = mdlFlatIOInfo;      
    end
end

function [inPortsInfo, outPortsInfo] = GetModelInOutPorts(modelH)
    inPortsInfo = [];
    outPortsInfo = [];

    inportBlksH = find_system(modelH, ...
        'SearchDepth',1,...        
        'BlockType','Inport'); 
    
    outportBlksH = find_system(modelH, ...
        'SearchDepth',1,...        
        'BlockType','Outport'); 

    inPortsInfo.numofports = length(inportBlksH);    
    inPortsInfo.blksH = inportBlksH;
    
    outPortsInfo.numofports = length(outportBlksH);    
    outPortsInfo.blksH = outportBlksH;
end

function portCache = genPortCache(portsInfo, strictBusErros)
    portCache = [];    
    for i=1:portsInfo.numofports
        if isempty(portCache)
            portCache = getIOportBus(portsInfo.blksH(i), strictBusErros);
        else
            portCache(end+1) = getIOportBus(portsInfo.blksH(i), strictBusErros); %#ok<AGROW>
        end
    end
end

function portAttributes = getIOportBus(blockH, strictBusErros) 
    ph = get_param(blockH, 'porthandles');
    lineH = get_param(blockH,'LineHandles');    
    if strcmp(get_param(blockH,'BlockType'),'Inport')
        portH = ph.Outport;               
        if(lineH.Outport ~= -1)
            signalName = get_param(lineH.Outport,'Name');
        else
            signalName = '';
        end
        isOutPort = false;
    else
        portH = ph.Inport;               
        if(lineH.Inport ~= -1)
            signalName = get_param(lineH.Inport,'Name');
        else
            signalName = '';
        end
        isOutPort = true;
    end    
       
    compiledportPrm = sl('slport_get_compiled_info',portH);
    
    portAttributes.BlockPath = getfullname(blockH);
    portAttributes.SignalName = signalName;
    portAttributes.IsStructBus = compiledportPrm.IsStructBus;       
    portAttributes.IsVirtualBus = strcmp(get_param(blockH,'UseBusObject'),'on') && ... 
            strcmp(get_param(blockH,'BusOutputAsStruct'),'off');           
    portAttributes.SampleTime = compiledportPrm.SampleTime;
    portAttributes.SampleTimeStr = compiledportPrm.SampleTimeStr;    
    portAttributes.IsStruct = false;
    if strictBusErros
        portAttributes.CompiledBusType = [];
        portAttributes.SignalHierarchy = [];
    else
        portAttributes.CompiledBusType = get_param(portH,'CompiledBusType');
        portAttributes.SignalHierarchy = get_param(portH,'SignalHierarchy');
    end
    
    busElemNamePath = cr_to_space(strrep(get_param(blockH,'Name'),'.','_'));
     
    if ~portAttributes.IsStructBus     
        if sldvshareprivate('util_is_sltruct_type',compiledportPrm.AliasThruDataType)
            portAttributes.IsStruct = true;
            structName = compiledportPrm.AliasThruDataType;
            structObj = sldvshareprivate('util_get_sltruct_type_from_name',structName);
            flatSignalInfo = [];            
            portAttributes.compiledInfo = ...
                construcLeavesForStruct(structObj, structName, busElemNamePath, flatSignalInfo);
        else
            portAttributes.compiledInfo.DataType = compiledportPrm.AliasThruDataType;        
            portAttributes.compiledInfo.Complexity = compiledportPrm.Complexity;
            portAttributes.compiledInfo.Dimensions = compiledportPrm.Dimensions;          
            portAttributes.compiledInfo.SignalPath = busElemNamePath;
            portAttributes.compiledInfo.Used = true;
            % If the port handle belongs to the Outport block, then the signal
            % that goes into the Outport blocks might be Virtual Bus signal
            % with all of the signals having the same data type. The utility
            % 'slport_get_compiled_info' gives the flat dimension and data
            % types for the port. But we really need to know whether it is a
            % virtual bus signal. But if the model errors with strictBusMsg,
            % then this information can not be obtained, we will assume that it
            % is not a virtual bus
            if isOutPort
                if ~strictBusErros
                    portAttributes.IsVirtualBus = ~isempty(get_param(portH,'CompiledBusStruct'));        
                else
                    portAttributes.IsVirtualBus = false;
                end
            end
        end        
    else                           
        busName = compiledportPrm.AliasThruDataType;        
        busObject = sl('slbus_get_object_from_name', busName, true);
        flatSignalInfo = [];
        busPath = busName;        
        portAttributes.compiledInfo = construcLeaves(busObject, busPath, busElemNamePath, flatSignalInfo);        
    end
    
end

function out = cr_to_space(in)
    out = in;
    if ~isempty(in)
        out(in==10) = char(32);
    end
end

function flatSignalInfo = construcLeaves(busObject, busPath, busElemNamePath, flatSignalInfo)
    for i=1:length(busObject.Elements)
        subBusObject = busObject.Elements(i); 
        subBusElemNamePath = sprintf('%s.%s',busElemNamePath,subBusObject.Name);
        busName = subBusObject.DataType;
        [isleaf, baseTyp] = isLeafType(busName);
        if(isleaf)              
            subBusObject.DataType = baseTyp;
            flatSignalInfo = push_into_flatSignalInfo(flatSignalInfo,...
                                                      subBusObject,...
                                                      busPath,...
                                                      subBusElemNamePath);                                                  
        else            
            leafebusObject = sl('slbus_get_object_from_name', busName, true);
            subBusPath = sprintf('%s.%s',busPath,busName);           
            flatSignalInfo = construcLeaves(leafebusObject, subBusPath, subBusElemNamePath, flatSignalInfo);
        end
    end
end

function flatSignalInfo = construcLeavesForStruct(structObj,  structPath, structElemNamePath, flatSignalInfo)
    for i=1:length(structObj.Elements)
        subStructObject = structObj.Elements(i); 
        subStructElemNamePath = sprintf('%s.%s', structElemNamePath, subStructObject.Name);       
        structName = subStructObject.DataType;
        [isleaf, baseTyp] = isLeafType(structName);
        if isleaf
            subStructObject.DataType = baseTyp;
        if isempty(flatSignalInfo)
            flatSignalInfo = get_struct_object_properties(subStructObject, structPath, subStructElemNamePath);
        else
            flatSignalInfo(end+1) = get_struct_object_properties(subStructObject, structPath, subStructElemNamePath); %#ok<AGROW>
        end        
        else
            leafestructObject = sldvshareprivate('util_get_sltruct_type_from_name',structName);
            subStructPath = sprintf('%s.%s',structPath,structName);           
            flatSignalInfo = construcLeavesForStruct(leafestructObject, subStructPath, subStructElemNamePath, flatSignalInfo);
        end                   
    end
end


function flatSignalInfo = push_into_flatSignalInfo(flatSignalInfo,subBusObject,busPath,busElemNamePath)
    
    if isempty(flatSignalInfo)
        flatSignalInfo = get_bus_object_properties(subBusObject,busPath,busElemNamePath);
    else
        flatSignalInfo(end+1) = get_bus_object_properties(subBusObject,busPath,busElemNamePath);
    end

end

function busObjectProperties = get_bus_object_properties(subBusObject,busPath,busElemNamePath)
    busObjectProperties.DataType = subBusObject.DataType;
    busObjectProperties.Complexity = subBusObject.Complexity;
    busObjectProperties.Dimensions = subBusObject.Dimensions;
    busObjectProperties.SampleTime = subBusObject.SampleTime;
    busObjectProperties.BusObjPath = busPath;
    busObjectProperties.SignalPath = busElemNamePath;
    busObjectProperties.Used = true;
end

function structObjectProperties = get_struct_object_properties(subStructObject,structPath,subStructElemNamePath)
    structObjectProperties.DataType = subStructObject.DataType;
    structObjectProperties.Complexity = subStructObject.Complexity;
    structObjectProperties.Dimensions = subStructObject.Dimensions;    
    structObjectProperties.StructObjPath = structPath;
    structObjectProperties.SignalPath = subStructElemNamePath;
    structObjectProperties.Used = true;
end

function createableSimData = checkInputForFixedPoint(InputCache)
    createableSimData = true;
    inputhasFixPnt = false;
    for i=1:length(InputCache)
        inputhasFixPnt = any(strncmp({InputCache(i).compiledInfo.DataType}, 'sfix',4) | ...
            strncmp({InputCache(i).compiledInfo.DataType}, 'ufix',4) | ...
            strncmp({InputCache(i).compiledInfo.DataType}, 'flt',3) | ...
            strncmp({InputCache(i).compiledInfo.DataType}, 'fixdt',5) | ...
            strncmp({InputCache(i).compiledInfo.DataType}, 'numerictype',11));
        %Need a new case here?
        if inputhasFixPnt
            break;
        end
    end
    if inputhasFixPnt
        createableSimData = exist('fi','file')==2;
    end
end

function [out, baseTypStr] = isLeafType(dataTypeStr)
    baseTypStr = dataTypeStr;
    out = sldvshareprivate('util_is_builtin_or_fxp_type',dataTypeStr);
    if ~out
        out = strncmp(dataTypeStr,'fixdt',5) || ...
              strncmp(dataTypeStr,'numerictype',11);
        if(~out)
            %check for Simulink NumericType 
            [out, baseTypStr] = sldvshareprivate('util_is_sim_numeric_type', dataTypeStr);
        end
    end
end
% LocalWords:  fxp porthandles slport sltruct testcomp testcomponent
