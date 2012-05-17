classdef (Hidden = true) AutosarTargetInterface < rtw.pil.StandaloneTargetInterface   
%AUTOSARTARGETINTERFACE creates a target interface file defined by AUTOSAR CodeInfo
%
%   This is an undocumented class. Its methods and properties are likely to
%   change without warning from one release to the next.    

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.9.2.2 $

    properties (SetAccess = 'private', GetAccess = 'private')
        PIMCSCS; % struct array of PIM CSC info
    end

    methods
        % constructor
        function this = AutosarTargetInterface(codeInfo, ...
                targetInterfacePath, ...
                pilInterface, ...
                infoStruct)
            error(nargchk(4, 4, nargin, 'struct'));
            % call super class constructor
            this@rtw.pil.StandaloneTargetInterface(codeInfo, ...
                targetInterfacePath, ...                
                pilInterface, ...
                infoStruct);                   
            
            % initialize PIMCSCs
            this.PIMCSCS = this.getPIMCSCs;
       end
    end           
    
    methods (Static = true)                        
        function sharedValidation(componentPath)            
            % get root model
            [rootModel systemPath] = strtok(componentPath, '/');            
            if isempty(systemPath)
                isRootModel = true;
            else
                isRootModel = false;
            end
            % if AutosarCompliant, apply various checks
            if strcmp(get_param(rootModel, 'AutosarCompliant'), 'on')
                % make sure required header files will be generated
                if ~strcmp(get_param(rootModel, 'AutosarRTEHeaderFileGeneration'), 'on')
                    rtw.pil.ProductInfo.error('pil', ...
                        'AutosarRTEHeaderFileGeneration', ...
                        rootModel, rootModel);
                end
                % get AUTOSAR Interface for the component
                if isRootModel
                   aiParam = 'RTWFcnClass'; 
                else
                   aiParam = 'ssRTWFcnClass';
                end
                autosarInterface = get_param(componentPath, aiParam);
                % if empty, AUTOSAR Target will check and throw an error during build
                if ~isempty(autosarInterface) && isa(autosarInterface, 'RTW.AutosarInterface')
                    % check for server operation and error
                    if autosarInterface.IsServerOperation
                        rtw.pil.ProductInfo.error('pil', ...
                            'AutosarServerOperation', ...
                            componentPath);
                    end
                end
                % check for client blocks which may or may not be part of config
                % subsystem
                clientBlocks = arblk.findAUTOSARClientBlks(componentPath);
                rtw.pil.AutosarTargetInterface.throwAUTOSARClientBlockError(componentPath, clientBlocks);
                % check for client block configurable subsystems
                %
                % this check catches the "simulation mode" case of the configurable
                % subsystem
                clientBlocks = arblk.findOperationConfigurableSubsystems(componentPath);
                rtw.pil.AutosarTargetInterface.throwAUTOSARClientBlockError(componentPath, clientBlocks);
                
                % check for AUTOSAR Calibration Parameters
                vars = get_param(componentPath, 'ReferencedWSVars');
                for i=1:length(vars)
                    % CSC's are only active in the base workspace
                    obj = evalin('base', vars(i).Name);
                    paramName = vars(i).Name;
                    % Check if value is an AUTOSAR CalPrm
                    if isa(obj, 'AUTOSAR.Parameter') && strcmp(obj.RTWInfo.CustomStorageClass, 'CalPrm')
                        rtw.pil.ProductInfo.error('pil', ...
                            'AutosarCalibrationParameter', ...
                            componentPath, ...
                            paramName);
                    end
                end
            end
        end                
    end
    
    methods (Static = true, Access = 'private')
        function throwAUTOSARClientBlockError(iMdl, clientBlocks)
            if ~isempty(clientBlocks)
                clientBlocksStr = '';
                for i=1:length(clientBlocks)
                    clientBlocksStr = [clientBlocksStr '"' clientBlocks{i} '"' sprintf('\n')];  %#ok<AGROW>
                end
                rtw.pil.ProductInfo.error('pil', ...
                    'AutosarClientBlocks', ...
                    iMdl, ...
                    clientBlocksStr);
            end
        end
    end
        
    methods (Access = 'protected')        
        function initCodeInfoUtils(this, codeInfo)
            % create the codeInfoUtils object           
            this.codeInfoUtils = rtw.connectivity.AutosarCodeInfoUtils(codeInfo);
        end                             
        
        function writeSectionUserFunctions(this) 
            % Generate RTE function definitions
            
            % assumptions about RTE generation
            %
            % AUTOSAR Target does not allow:
            %
            % - non-auto storage classes at I/O boundary        
            
            this.writer.writeLine('/* AUTOSAR RTE Implementation - see Rte_SWC.h */');          
            
            % for each runnable, process all required RTE Functions
            runnables = this.getOutputTasks;
            for runnableIdx = 1:length(runnables)
               runnable = runnables(runnableIdx);
               this.writeRTEFunctions(runnable);
            end           
        end
        
        function writeSectionExternalInitialization(this) 
            % call super class method
            writeSectionExternalInitialization@rtw.pil.TargetInterface(this);
            
            % additionally, process all IRV's in InternalData
            this.writer.writeLine('/* initialize IRV storage owned by PIL */');          
            allInternalData = this.codeInfo.InternalData;
            for i=1:length(allInternalData)
                impl = allInternalData(i).Implementation;
                if isa(impl, 'RTW.AutosarInterRunnable')
                    this.writeDataInterfaceDefaultInitialization(impl);    
                end                
            end      
            
            % additionally, initialize NVRAM PIM global and local data stores
            % via the X_Init_Pim_* functions generated into Rte_X_PIM.c
            dataStores = this.codeInfo.DataStores;
            for diIdx = 1:length(dataStores)
                ds = dataStores(diIdx);
                implementation = ds.Implementation;
                % limit scope to RTW.Variable
                if isa(implementation, 'RTW.Variable')
                    [isPIMCSC, isNVRAM] = this.isPIMCSC(implementation);
                    if isPIMCSC && isNVRAM
                        rteID = this.getRteID(implementation);
                        this.writer.writeLine('/* initialize NVRAM PIM datastore */');
                        this.writer.writeLine([this.codeInfo.GraphicalPath ...
                            '_Init_Pim_' rteID '();']);
                    end
                end
            end            
        end
        
        function writeRTEFunctions(this, periodicRunnable) 
            % create RTE functions for all DirectWrites and DirectReads
            directWrites = periodicRunnable.DirectWrites;
            directReads = periodicRunnable.DirectReads;
            dataInterfaces = [directWrites; directReads];                        
            
            for i=1:length(dataInterfaces)
                dataInterface = dataInterfaces(i);                                                          
                implementation = dataInterface.Implementation;  
                assert(implementation == rtw.connectivity.CodeInfoTypeUtils.getStorageImplementation(implementation), ...
                       'Data interface implementation must equal storage implementation');
                switch class(implementation)
                    case {'RTW.AutosarSenderReceiver' 'RTW.AutosarClientServer' 'RTW.AutosarInterRunnable'}
                        % ok
                    case 'RTW.AutosarErrorStatus'
                        % skip - processed when corresponding Receiver is
                        % processed
                        continue;  
                    case 'RTW.Variable'
                        % g644749: PIM DSMs are recorded in DirectReads only.
                        %          Non-PIM DSMs are not recorded in
                        %          DirectReads or DirectWrites.                        
                        assert(this.codeInfoUtils.isDataStore(dataInterface), ...
                               'Found DirectRead/DirectWrite RTW.Variable not associated with a Data Store');                    
                        isPIMCSC = this.isPIMCSC(implementation);
                        assert(isPIMCSC, ...
                            'Found DirectRead/DirectWrite Data Store with RTW.Variable but no PIM CSC');                        
                        % PIM Global or Local Data Store 
                        % (either NVRAM or none NVRAM)
                        %
                        % Global DS are supported for data
                        % transfer, which also initializes them.
                        %
                        % None NVRAM Local DS internally to the component
                        % are ok - non-zero initialization (including default
                        % values for enums and fixed point types with
                        % bias) will be generated into the model
                        % initialize function.
                        %
                        % NVRAM global and local datastores will be 
                        % initialized via the X_Init_Pim_* functions (see
                        % writeSectionExternalInitialization)
                        %
                        % PerInstanceMemory already defined in Rte_PIM.c
                        continue;
                    otherwise
                        assert(false, 'Unexpected implementation class: %s', class(implementation));
                end                                
                isBusOrStruct = rtw.connectivity.CodeInfoTypeUtils.isBusOrStruct(implementation.Type);                
                % expand into contiguous data
                contiguousData = rtw.connectivity.CodeInfoTypeUtils.getSimulinkInterfaceContiguousData(implementation);
                if isBusOrStruct                    
                    % first element of contiguousData has all the info we
                    % need
                    cData = contiguousData(1);
                    % first element of BusInfo has all the info we need
                    busInfo = cData.BusInfo(1);
                    storageSize = prod(busInfo.StructDimensions);                    
                    baseRteType = busInfo.StructType.Identifier;                                                          
                else
                    assert(isscalar(contiguousData), 'Non-bus or struct type must have scalar contiguous data representation');
                    cData = contiguousData;
                    assert(~rtw.connectivity.CodeInfoTypeUtils.isComplex(cData.Type), 'Complex data is not supported.');
                    storageSize = rtw.connectivity.CodeInfoTypeUtils.getNumDataElementsForContiguousData(cData);
                    % body                    
                    storageType = cData.Type;
                    baseStorageType = rtw.connectivity.CodeInfoTypeUtils.getBaseType(storageType);                                                                                            
                    baseRteType = baseStorageType.Identifier;                           
                end                                               
                if storageSize == 1
                    rteType = baseRteType;
                else
                    % type is not captured in CodeInfo
                    %
                    % construct as per autosarsup.tlc:
                    % FcnAutosarArrayTypeWithoutAliasResolution
                    rteType = ['Rte_rt_Array__' baseRteType '_' int2str(storageSize)];
                    maxShortNameLength = this.getParam('AutosarMaxShortNameLength');
                    if length(rteType) > maxShortNameLength
                        rteType = arxml.arxml_private('p_create_aridentifier', rteType, maxShortNameLength);
                    end                    
                end
                
                % determine whether to use pointer arguments in RTE functions
                usePointerIO = ~(storageSize == 1 && ~isBusOrStruct);
                switch implementation.DataAccessMode                   
                    case 'ImplicitReceive'
                        this.writeSectionImplicitReceive(periodicRunnable, ...
                                                         usePointerIO, ...
                                                         rteType, ...
                                                         implementation);                        
                    case 'ImplicitSend'
                        this.writeSectionImplicitSend(periodicRunnable, ...
                                                      usePointerIO, ...
                                                      rteType, ...
                                                      implementation);
                    case 'ExplicitReceive'
                        this.writeSectionExplicitReceive(rteType, ...
                                                         implementation)
                    case 'QueuedExplicitReceive'
                        this.writeSectionQueuedExplicitReceive(rteType, ...
                                                     implementation)
                    case 'ExplicitSend'
                        this.writeSectionExplicitSend(usePointerIO, ...
                                                      rteType, ...
                                                      implementation);
                    case 'BasicSoftwarePort'
                        this.writeSectionBasicSoftwarePort(usePointerIO, ...
                                                           rteType, ...
                                                           dataInterface);
                    case 'ImplicitInterRunnable'
                        % create both IRV IRead and IWrite functions
                        %                        
                        assert(~usePointerIO, 'IRVs must be scalar and cannot be buses or structs');
                        this.writeSectionIRVRead(periodicRunnable, ...
                                                         rteType, ...
                                                         implementation,...
                                                         true);
                                                     
                        this.writeSectionIRVWrite(periodicRunnable, ...
                                                          rteType, ...
                                                          implementation,...
                                                          true);
                    case 'ExplicitInterRunnable'
                        % create both IRV Read and Write functions
                        %                        
                        assert(~usePointerIO, 'IRVs must be scalar and cannot be buses or structs');
                        this.writeSectionIRVRead(periodicRunnable, ...
                                                         rteType, ...
                                                         implementation,...
                                                         false);
                                                     
                        this.writeSectionIRVWrite(periodicRunnable, ...
                                                          rteType, ...
                                                          implementation,...
                                                          false);                        
                    otherwise
                        assert(false, 'Unexpected DataAccessMode: %s', implementation.DataAccessMode);
                end
                this.writer.newLine;
            end                       
        end                
                
        % override super class method
        function hasOnlyLocalAccess = hasOnlyLocalAccess(this, dataInterface) %#ok<MANU>
            switch class(dataInterface.Implementation)
                case {'RTW.AutosarSenderReceiver' ...
                      'RTW.AutosarErrorStatus' ...
                      'RTW.AutosarClientServer' ...
                      'RTW.AutosarInterRunnable'} 
                    % data is not directly accessed outside of
                    % pil_interface.c
                    hasOnlyLocalAccess = true;
                otherwise            
                    hasOnlyLocalAccess = false;    
            end                         
        end
        
        % return the "base" storage implementation for a root implementation
        function storageImplementation = getBaseStorageImplementation(this, implementation)
            implementationClass = class(implementation);
            switch implementationClass               
                case {'RTW.AutosarSenderReceiver', ...
                      'RTW.AutosarErrorStatus' ...
                      'RTW.AutosarClientServer' ...
                      'RTW.AutosarInterRunnable'}
                    storageImplementation = implementation;                 
                otherwise
                    % call super class
                    storageImplementation = getBaseStorageImplementation@rtw.pil.StandaloneTargetInterface(this, implementation);
            end                        
        end                
        
        function expression = getExpression(this, implementation)
            switch class(implementation)
                case 'RTW.AutosarSenderReceiver'
                    rteID = this.getRteID(implementation);
                    % add psd - PIL static data                    
                    expression = ['psd_' rteID];
                case 'RTW.AutosarErrorStatus'             
                    rteID = this.getRteID(implementation);                    
                    % add psd - PIL static data
                    % add err - error status
                    expression = ['psd_' rteID '_err'];
                case 'RTW.AutosarClientServer'
                    rteID = this.getRteID(implementation);                    
                    % add psd - PIL static data
                    % add bs - basic software
                    expression = ['psd_' rteID '_bs'];
                case 'RTW.AutosarInterRunnable'
                    rteID = this.getRteID(implementation);
                    % add psd - PIL static data                    
                    expression = ['psd_' rteID];
                case 'RTW.Variable'                    
                    if this.isPIMCSC(implementation)
                        rteID = this.getRteID(implementation);
                        % go through Rte API defined in Rte_PIM.c
                        expression = ['(*(Rte_Pim_' rteID '()))'];
                    else
                        % call superclass
                        expression = getExpression@rtw.pil.StandaloneTargetInterface(this, implementation);
                    end
                otherwise            
                    % call superclass
                    expression = getExpression@rtw.pil.StandaloneTargetInterface(this, implementation);
            end                              
        end   
        
        function setImplementationOwner(this, implementation, owner)            
            switch class(implementation)
                case {'RTW.AutosarSenderReceiver' ...
                      'RTW.AutosarErrorStatus' ...
                      'RTW.AutosarClientServer' ...
                      'RTW.AutosarInterRunnable'}
                    % Always owned by PIL
                otherwise            
                    % call superclass
                    setImplementationOwner@rtw.pil.StandaloneTargetInterface(this, implementation, owner);
            end
        end
        
        function owner = getImplementationOwner(this, implementation)  
            switch class(implementation)
                case {'RTW.AutosarSenderReceiver' ...
                      'RTW.AutosarErrorStatus' ...
                      'RTW.AutosarClientServer' ...
                      'RTW.AutosarInterRunnable'}
                    % Always owned by PIL
                    owner = 'PIL';
                otherwise            
                    % call superclass
                    owner = getImplementationOwner@rtw.pil.StandaloneTargetInterface(this, implementation);                
            end                        
        end 
        
        function writeSectionStorageForDataAddPrefix(this, dataInterface, implementation)
            switch class(implementation)
                case {'RTW.AutosarSenderReceiver' ...
                      'RTW.AutosarErrorStatus' ...
                      'RTW.AutosarClientServer' ...
                      'RTW.AutosarInterRunnable'} 
                    % no prefix
                otherwise            
                    % call superclass
                    writeSectionStorageForDataAddPrefix@rtw.pil.StandaloneTargetInterface(this, ...
                        dataInterface, ...
                        implementation);
            end    
        end
        
        % abstract away difference between INHERITED and PERIODIC output tasks
        function tasks = getOutputTasks(this)
            if this.codeInfoUtils.isExportFunctions
                tasks = this.codeInfoUtils.getOutputTasks('PERIODIC');                
            else
                % call superclass
                tasks = getOutputTasks@rtw.pil.StandaloneTargetInterface(this);
            end
        end
    end  
    
    methods (Access = 'private')
        function runnableName = getPeriodicRunnableName(this, periodicRunnable) %#ok<MANU>
            % get the name of the periodic runnable            
            runnableName = periodicRunnable.Prototype.Name;              
        end                        
        
        function rteID = getRteID(this, ...
                                  implementation)
            switch class(implementation)
                case 'RTW.AutosarSenderReceiver'
                    rteID = [implementation.Port '_' implementation.DataElement];
                case 'RTW.AutosarErrorStatus'
                    receiver = this.codeInfoUtils.getReceiverFromErrorStatus(implementation);                    
                    rteID = [receiver.Port '_' receiver.DataElement];
                case 'RTW.AutosarClientServer'                    
                    rteID = [implementation.ServiceName '_' implementation.ServiceOperation];
                case 'RTW.AutosarInterRunnable'
                    rteID = implementation.VariableName;
                case 'RTW.Variable'
                    assert(this.isPIMCSC(implementation), ...
                           'Found RTW.Variable not associated with a PIM CSC');                                        
                    rteID = implementation.Identifier;                                            
                otherwise
                    assert(false, 'Unexpected implementation class: %s', class(implementation));
            end                              
        end        
        
        % write RTE IRV implicit/explicit (buffered/not-buffered) read function
        function writeSectionIRVRead(this, ...
                                     periodicRunnable, ...                                             
                                     rteType, ...
                                     implementation,...
                                     isImplicit)                   
            returnType = rteType;
            returnValue = this.getExpression(implementation);                
            
            optI = '';
            if isImplicit
                % IRead
                optI = 'I';
            end
            
            this.writer.writeLine([returnType ' ' ...
                'Rte_Irv',optI,'Read_' ...
                this.getPeriodicRunnableName(periodicRunnable) '_' ...
                this.getRteID(implementation) ...
                '(void) {']);
            this.writer.writeLine(['   return ' returnValue ';']);
            this.writer.writeLine('}');
            this.writer.newLine;                
        end
        
        
        % write RTE implicit (buffered) receive function & 
        % corresponding IStatus function
        function writeSectionImplicitReceive(this, ...
                                             periodicRunnable, ...
                                             usePointerIO, ...
                                             rteType, ...
                                             implementation)       
            if usePointerIO
                returnType = [rteType '*'];
                returnValue = ['&(' this.getExpression(implementation) ')'];
            else
                returnType = rteType;
                returnValue = this.getExpression(implementation);                
            end
            % IRead
            this.writer.writeLine([returnType ' ' ...
                'Rte_IRead_' ...
                this.getPeriodicRunnableName(periodicRunnable) '_' ...
                this.getRteID(implementation) ...
                '(void) {']);
            this.writer.writeLine(['   return ' returnValue ';']);
            this.writer.writeLine('}');
            this.writer.newLine;    
            % IStatus
            errorStatus = this.codeInfoUtils.getErrorStatusFromReceiver(implementation);                                                                                  
            if ~isempty(errorStatus)
                this.writer.writeLine(['uint8_T Rte_IStatus_' ...
                                       this.getPeriodicRunnableName(periodicRunnable) '_' ...
                                       this.getRteID(implementation) ...
                                       '(void) {']);
                this.writer.writeLine(['   return ' this.getExpression(errorStatus) ';']);
                this.writer.writeLine('}');
            end                         
        end
        
        % write RTE IRV implicit/explicit (buffered/not-buffered) write function
        function writeSectionIRVWrite(this, ...
                                      periodicRunnable, ...
                                      rteType, ...
                                      implementation,...
                                      isImplicit)            
            inputType = rteType;
            inputAddressValue = '&u';                
            
            optI = '';
            if isImplicit
                % IWrite
                optI = 'I';
            end
            
            this.writer.writeLine(['void ' ...
                'Rte_Irv',optI,'Write_' ...
                this.getPeriodicRunnableName(periodicRunnable) '_' ...
                this.getRteID(implementation) ...
                '(' inputType ' u) {']);
            this.writer.writeLine(['   memcpy(&(' this.getExpression(implementation) '), ' inputAddressValue ', sizeof(' rteType '));']);
            this.writer.writeLine('}');
        end        
        
        % write RTE implicit (buffered) send function
        function writeSectionImplicitSend(this, ...
                                          periodicRunnable, ...
                                          usePointerIO, ...
                                          rteType, ...
                                          implementation)
            if usePointerIO
                inputType = [rteType '*'];
                inputAddressValue = 'u';
            else
                inputType = rteType;
                inputAddressValue = '&u';                
            end
            % IWrite
            this.writer.writeLine(['void ' ...
                'Rte_IWrite_' ...
                this.getPeriodicRunnableName(periodicRunnable) '_' ...
                this.getRteID(implementation) ...
                '(' inputType ' u) {']);
            this.writer.writeLine(['   memcpy(&(' this.getExpression(implementation) '), ' inputAddressValue ', sizeof(' rteType '));']);
            this.writer.writeLine('}');
        end
        
        % write RTE explicit receive function
        function writeSectionExplicitReceive(this, ...
                                             rteType, ...
                                             implementation)                                         
            errorStatus = this.codeInfoUtils.getErrorStatusFromReceiver(implementation);
            if isempty(errorStatus)                
                returnType = 'void';
            else                
                returnType = 'uint8_T';
            end
            % Read
            this.writer.writeLine([returnType ' ' ...
                'Rte_Read_' ...
                this.getRteID(implementation) ...
                '(' rteType '* u) {']);
            this.writer.writeLine(['   memcpy(u, &(' this.getExpression(implementation) '), sizeof(' rteType '));']);
            if ~isempty(errorStatus)                                 
                this.writer.writeLine(['   return ' this.getExpression(errorStatus) ';']);
            end
            this.writer.writeLine('}');
        end

        
        % write RTE queued explicit receive function
        function writeSectionQueuedExplicitReceive(this, ...
                                             rteType, ...
                                             implementation)                                         
            errorStatus = this.codeInfoUtils.getErrorStatusFromReceiver(implementation);
            if isempty(errorStatus)                
                returnType = 'void';
            else                
                returnType = 'uint8_T';
            end
            % Read
            this.writer.writeLine([returnType ' ' ...
                'Rte_Receive_' ...
                this.getRteID(implementation) ...
                '(' rteType '* u) {']);
            this.writer.writeLine(['   memcpy(u, &(' this.getExpression(implementation) '), sizeof(' rteType '));']);
            if ~isempty(errorStatus)                                 
                this.writer.writeLine(['   return ' this.getExpression(errorStatus) ';']);
            end
            this.writer.writeLine('}');
        end

        
        % write RTE explicit send function
        function writeSectionExplicitSend(this, ...
                                          usePointerIO, ...
                                          rteType, ...
                                          implementation)            
            if usePointerIO
                inputType = [rteType '*'];
                inputAddressValue = 'u';
            else
                inputType = rteType;
                inputAddressValue = '&u';                
            end
            % Write
            this.writer.writeLine(['void ' ...
                'Rte_Write_' ...
                this.getRteID(implementation) ...
                '(' inputType ' u) {']);
            this.writer.writeLine(['   memcpy(&(' this.getExpression(implementation) '), ' inputAddressValue ', sizeof(' rteType '));']);
            this.writer.writeLine('}');            
        end
        
        function writeSectionBasicSoftwarePort(this, ...
                                               usePointerIO, ...
                                               rteType, ...
                                               dataInterface)
            % determine type of dataInterface
            dataInterfaceType = this.codeInfoUtils.resolveIODataInterface(dataInterface);                                                             
            switch dataInterfaceType
                case 'Inport'
                    isInput = true;
                case 'Outport'
                    isInput = false;
                otherwise
                    assert(false, 'Unknown dataInterfaceType: %s', dataInterfaceType);
            end                                                                                                                                 
            if usePointerIO || isInput
                inputType = [rteType '*'];
                inputAddressValue = 'u';
            else
                inputType = rteType;
                inputAddressValue = '&u';                
            end
            % Rte_Call
            implementation = dataInterface.Implementation;
            this.writer.writeLine(['void ' ...
                'Rte_Call_' ...
                this.getRteID(implementation) ...
                '(' inputType ' u) {']);
            if isInput
                this.writer.writeLine(['   memcpy(' inputAddressValue ', &(' this.getExpression(implementation) '), sizeof(' rteType '));']);
            else
                this.writer.writeLine(['   memcpy(&(' this.getExpression(implementation) '), ' inputAddressValue ', sizeof(' rteType '));']);
            end
            this.writer.writeLine('}');
        end                                        
        
        % Get cell array of PIM CSC's referenced by component
        function pimCSCs = getPIMCSCs(this)
            pimCSCs = [];                                     
            
            % get global workspace variables
            %
            % no need to get the list for referenced models - PIM CSC's can
            % only be referenced by the top-model
            globalParams = this.getInfoStruct.globalsInfo.GlobalParamInfo.VarList;
                        
            % VarList is a comma separated list
            if ~isempty(globalParams)
                globalParams = regexp(globalParams, ' *, *', 'split');                                
            end

            for i=1:length(globalParams)
                % find PIM CSCs
                objName = globalParams{i};                
                % Attempt to load the Simulink object from the MATLAB workspace
                isSlObjDefined = evalin('base', sprintf('exist(''%s'',''var'')', objName));
                if isSlObjDefined == 1
                    obj = evalin('base', objName);
                else
                    rtw.pil.ProductInfo.error('pil', ...
                        'AutosarDataObjectMissing', ...
                        objName);
                end                                                                
                if isa(obj,'AUTOSAR.Signal') && ...
                       obj.getIsAutosarPerInstanceMemory()    
                    % create struct
                    pimCSCs(end+1).Name = objName; %#ok<AGROW>
                    pimCSCs(end).NeedsNVRAMAccess = obj.RTWInfo.CustomAttributes.needsNVRAMAccess;                     %#ok<AGROW>
                end                                                                                   
            end                                                                   
        end
        
        % determine if implementation has an associated PIM CSC
        function [isPIMCSC, isNVRAM] = isPIMCSC(this, implementation)
            assert(isa(implementation, 'RTW.Variable'), ...
                   'Implementation must be RTW.Variable.');
            name = implementation.Identifier;
            if isempty(this.PIMCSCS)
                isPIMCSC = false;
                isNVRAM = false;
            else
                % see if there is a match in the list of PIMCSCs
                [isPIMCSC, loc] = ismember(name, {this.PIMCSCS.Name});
                if isPIMCSC
                    isNVRAM = this.PIMCSCS(loc).NeedsNVRAMAccess;
                else
                    isNVRAM = false;
                end
            end
        end
    end
end
