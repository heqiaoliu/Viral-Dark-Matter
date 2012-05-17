%% Using Data Stores to Access Per-Instance Memory
% This demonstration explains how to publish an AUTOSAR software component with 
% per-instance memory. 

%   Copyright 2010 The MathWorks, Inc.

%% Overview of Per-Instance Memory
% Per-instance memory is a feature that AUTOSAR provides 
% to specify instance-specific global memory within a software component.
% An AUTOSAR run-time environment generator allocates this memory and provides 
% an API for you to to access this memory. 

%% Modeling Per-Instance Memory
% To use per-instance memory in a Simulink(R) model, you can add a Data Store Memory 
% block together with an AUTOSAR.Signal data object that specifies the 
% "PerInstanceMemory" custom storage class.  Open the 
% |rtwdemo_autosar_PIM| model to see an example of such usage.
%
open_system('rtwdemo_autosar_PIM')

%%
% The AUTOSAR.Signal objects |nvmImplicitRExplicitW| and |nvmImplicitRW| have been 
% created in the base workspace, and are referenced by the Data Store Memory 
% blocks in the model.  In the C code generated for the model, the values of the
% data stores are accessed via the functions  |Rte_Pim_nvmImplicitRExplicitW()| and 
% |Rte_Pim_nvmImplicitRW()|, respectively.

%% Enforcing Data Consistency When Multiple Runnables Access a Data Store
% The generated XML files for the internal behavior
% of the software component will contain an exclusive area for each Data Store
% Memory block that references per-instance memory.
% Every runnable that accesses this per-instance memory 
% runs inside its corresponding exclusive area. 
% If multiple AUTOSAR runnables access to the same Data Store Memory block, 
% the exported AUTOSAR specification enforces data consistency by using an 
% AUTOSAR exclusive area.  This specification ensures that runnables will have
% mutually exclusive access to the per-instance memory global data, preventing
% data corruption.

%% Using Data Stores to Mirror Nonvolatile Memory
% In addition to defining generic global data, you can use per-instance memory
% as a RAM mirror for data in nonvolatile memory, in order to access and utilize 
% nonvolatile memory from your AUTOSAR application.
% AUTOSAR provides two modes of operation to synchronize the content in 
% nonvolatile memory with the per-instance memory RAM mirror.  The
% |rtwdemo_autosar_PIM| model demonstrates these two modes.
%
% * Implicit Read, Implicit write
%
% During ECU startup, the content in the per-instance memory is initialized by
% the NvM manager module.  During shutdown of the electronic control unit (ECU)
% the content is stored if
% at any time during the execution of runnables within the component, the
% per-instance memory block is updated and subsequently the 
% AUTOSAR server operation Nvm.setRamBlockStatus(true) is invoked.
% 
% * Implicit Read, Explicit write
%
% During ECU startup, the content in the per-instance memory is initialized by
% the NvM manager module.  During the execution of a software component,
% the content is stored if the per-instance memory value is updated, and the 
% AUTOSAR server operation NvM.WriteBlock(NULL) is executed. This technique is useful to 
% write values immediately to the nonvolatile memory without waiting
% for the ECU to shut down.
%
% Once an AUTOSAR.Signal data object specifies the PerInstanceMemory custom
% storage class, you can specify this per-instance memory to be a mirror block
% for a specific nonvolatile memory block by setting the data attribute 
% "needsNVRAMAccess" to true. This setting ensures that a
% SERVICE-NEEDS entry (in schema version 3.0) or NVRAM-MAPPINGS entry (in schema version 2.1) 
% is declared in the internal behavior of the software component to indicate
% that the per-instance memory is used as a RAM mirror block and needs to 
% be serviced by the NvM manager module.

%% NOTE: Merge into the Authoring Tool
% This demonstration makes use of nonvolatile memory. If you intend to import
% the generated XML files into an AUTOSAR authoring tool, you should include the
% server interface referenced by the Data Store Memory blocks
% (<matlab:web(fullfile(matlabroot,'toolbox','rtw','rtwdemos','NvMInterface2.arxml'))
% NvMInterface2.arxml>).

%% Further Information
%
% <matlab:helpview(fullfile(docroot,'toolbox','ecoder','helptargets.map'),'ecoder_autosar') AUTOSAR Target documentation>

bdclose('rtwdemo_autosar_PIM')
clear nvmImplicitRExplicitW nvmImplicitRW

displayEndOfDemoMessage(mfilename)
