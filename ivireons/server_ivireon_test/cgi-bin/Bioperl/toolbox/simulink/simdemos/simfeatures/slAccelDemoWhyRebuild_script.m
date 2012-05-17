%% Determining Why Simulink(R) Accelerator(TM) is Regenerating Code
%
% Sometimes, for no apparent reason, Simulink(R) Accelerator(TM) regenerates the
% simulation target for a model at the beginning of every simulation. This demo
% uses Simulink(R) MATLAB(R) file API to determine why Simulink Accelerator keeps regenerating
% the target and then uses this information to change the model to eliminate
% the cause of the target regeneration.
%    
% First, some background. Simulink Accelerator speeds up simulation of your
% model by creating an executable version of the model, called a simulation
% target, and running this target instead of interpreting the model as is done
% during normal (unaccelerated) simulation. Simulink Accelerator creates the
% simulation target by generating C code from your model and invoking the MATLAB(R)
% mex function to compile and dynamically link the generated code to Simulink.
%
% This code generation and compilation process happens the first time you
% accelerate the model and any time the model changes significantly enough to
% require regeneration (for example, after addition of a block). Simulink uses
% the model's checksum to determine if the code needs to be regenerated. This
% checksum is an array of four integers computed by using an md5 checksum
% algorithm based on attributes of the model and the blocks it contains. Any
% change in the model that changes the checksum causes Simulink Accelerator to
% regenerate the simulation target.
% 
% Sometimes, it is not clear what model change triggered a checksum change and
% hence code regeneration. This demo creates such a scenario and then resolves
% it.

% Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.5.2.1 $


%% Create a Temporary Working Directory
% Since running in accelerated mode
% creates some files, first move to a temporary area.

originalDir = pwd;
tempDir = tempname;
mkdir(tempDir)
cd(tempDir)

%% Open an Example Model That Regenerates Code For Every Run
% The simple model, slAccelDemoWhyRebuild, regenerates code every time 
% it is simulated in Accelerator mode. 
model = 'slAccelDemoWhyRebuild';
open_system(model)
%%
% The first time the model runs in Accelerator mode, it generates and compiles code as expected. 
simOutput = evalc(['sim(''',model,''')']);
if ~isempty(strfind(simOutput,'Building the Accelerator target for model'))
    disp('Built Simulink Accelerator mex file')
else 
    disp('Did not build Simulink Accelerator mex file')
end
%%
% It is natural to expect the second simulation to reuse the same 
% Simulink Accelerator mex file. However, it regenerates code.
simOutput = evalc(['sim(''',model,''')']);
if ~isempty(strfind(simOutput,'Building the Accelerator target for model'))
    disp('Built Simulink Accelerator mex file')
else 
    disp('Did not build Simulink Accelerator mex file')
end
%%
% We'd like to know why.
%
% To determine if the previously generated code is still valid for the current
% model configuration, Simulink Accelerator compares the checksum of the model as
% used to generate the code to the current checksum. If they are equal, the
% previously generated code is still valid and Simulink Accelerator reuses it
% for the current simulation. If the values differ, Simulink Accelerator regenerates and
% rebuilds the code. Thus examining the details of the checksum computation can 
% reveal why Simulink Accelerator regenerated the code.

%% Get the Checksum Details
% The following command gets the model checksum computation details:

[cs1,csdet1]=Simulink.BlockDiagram.getChecksum(model);

%%
% The first output is the model checksum value itself. 
% The second output gives details of what went into the checksum computation. 
% Let's get the checksum and details a second time. 

[cs2,csdet2]=Simulink.BlockDiagram.getChecksum(model);

%%
% Comparing these two checksum values is equivalent to determining if the 
% Simulink Accelerator will regenerate code. 
% Note that the checksum values are different, as we expect based on the 
% fact that Simulink Accelerator regenerates code every time it runs.
if (cs1 ~= cs2)
    disp('Checksums are different')
else
    disp('Checksums are the same')
end

%%
% Now that we know that the checksums differ, the next question is why. Many
% things go into the checksum computation, including signal data types, some
% block parameter values, and block connectivity information. To understand why
% the checksums differ, we need to see what has changed about the items used in
% computing the checksum.  The checksum details returned as the second argument
% give that information.
csdet1
%%
% The checksum details is a structure array with four fields, two of which are
% the component checksums of the model checksum (i.e. ContentsChecksum and 
% InterfaceChecksum) and the other two of which are the corresponding checksum 
% details. 
%
% First let's see if the difference lies in the model's contents or the 
% model's interface
if (csdet1.ContentsChecksum.Value ~= csdet2.ContentsChecksum.Value)
    disp('Contents checksums are different')
else
    disp('Contents checksums are the same')
end
if (csdet1.InterfaceChecksum.Value ~= csdet2.InterfaceChecksum.Value)
    disp('Interface checksums are different')
else
    disp('Interface checksums are the same')
end

%% Use the Details to Determine the Change
% Now that we know the change is in the ContentsChecksum, we can look at the
% ContentsChecksumItems to see what has changed.
idxForDifferences=[];
for idx = 1:length(csdet1.ContentsChecksumItems)
    if (~strcmp(csdet1.ContentsChecksumItems(idx).Handle, ...
                csdet2.ContentsChecksumItems(idx).Handle))
        idxForDifferences=[idxForDifferences,idx];
        disp(['Handles different for item ',num2str(idx)]);
    end
    if (~strcmp(csdet1.ContentsChecksumItems(idx).Identifier, ...
                csdet2.ContentsChecksumItems(idx).Identifier))
        disp(['Identifiers different for item ',num2str(idx)]);
        idxForDifferences=[idxForDifferences,idx];
    end
    if(ischar(csdet1.ContentsChecksumItems(idx).Value))
        if (~strcmp(csdet1.ContentsChecksumItems(idx).Value, ...
                    csdet2.ContentsChecksumItems(idx).Value))
            disp(['String Values different for item ',num2str(idx)]);
            idxForDifferences=[idxForDifferences,idx];
        end 
    end
    if(isnumeric(csdet1.ContentsChecksumItems(idx).Value))
        if (csdet1.ContentsChecksumItems(idx).Value ~= ...
            csdet2.ContentsChecksumItems(idx).Value)
            disp(['Numeric values are different for item ',num2str(idx)]);
            idxForDifferences=[idxForDifferences,idx];
        end
    end
end
%%
% Now that we know the differences are in the items at the indices listed in
% idxForDifferences, we can look at those items in the two ContentsChecksumItems
% arrays
blk1 = csdet1.ContentsChecksumItems(idxForDifferences(1)).Handle
blk2 = csdet2.ContentsChecksumItems(idxForDifferences(1)).Handle
id1 = csdet1.ContentsChecksumItems(idxForDifferences(1)).Identifier
id2 = csdet2.ContentsChecksumItems(idxForDifferences(1)).Identifier

%%
% The Handle for both is 'slAccelDemoWhyRebuild/Random Number' which indicates
% the block with the changing data.  The identifier for both is
% 'RunTimeParameter{'Seed'}.RTParamCSInfo.Data' which tells us that the block's
% run-time parameter named 'Seed' is changing its Data (or value)
%
% Let's look at the Seed parameter
get_param(csdet1.ContentsChecksumItems(idxForDifferences(1)).Handle,'Seed')
  
%%
% The Seed parameter of the Random Number block is floor((sum(clock)+rand)*10000),
% which changes every time the model runs.  This model has the "Inline
% Parameters" optimization selected, which causes all parameters to be
% nontunable by default.  If a parameter is nontunable, Simulink Accelerator
% inserts the actual value of the parameter as a constant expression wherever
% the generated code needs the value. Thus as the value of the nontunable
% parameter changes, the code needs to be regenerated.  If a parameter is
% tunable, Simulink Accelerator generates a global variable declaration for
% the parameter and uses the variable wherever the generated code needs the
% parameter's value. This configuration allows for the parameter's value to
% change without causing Simulink Accelerator to regenerate code.
%
 

%% Changing the Model So It Will Not Need to Rebuild
% To keep Simulink Accelerator from needing to regenerate 
% code every time the model runs, we need to make the Seed parameter 
% in the Random Number block tunable. Here is how we can do that:
%
% First, create a tunable Simulink.Parameter object. For this demo, we will use
% the command line to do this, but you could use the Model Explorer 
% instead. 
initSeed = Simulink.Parameter;
initSeed.RTWInfo.StorageClass = 'ExportedGlobal';
initSeed.Value = floor((sum(clock)+rand)*10000)

%%
% Next, set the tunable parameter object as the value of the block's Seed parameter
set_param(csdet1.ContentsChecksumItems(idxForDifferences(1)).Handle,'Seed','initSeed')
%%
% Finally, set the model's InitFcn to change the value of the parameter with each run
set_param(model,'InitFcn','initSeed.Value = floor((sum(clock)+rand)*10000);')

%% Verify that the Model Does Not Regenerate Code Every Time It Is Simulated
% Let's simulate the model in Accelerator mode and verify that it does
% build, as we expect because we changed some things. 

simOutput = evalc(['sim(''',model,''')']);
if ~isempty(strfind(simOutput,'Building the Accelerator target for model'))
    disp('Built Simulink Accelerator mex file')
else 
    disp('Did not build Simulink Accelerator mex file')
end
%%
% Now let's simulate a second time. This time no rebuild should happen.
simOutput = evalc(['sim(''',model,''')']);
if ~isempty(strfind(simOutput,'Building the Accelerator target for model'))
    disp('Built Simulink Accelerator mex file')
else 
    disp('Did not build Simulink Accelerator mex file')
end
%%
% Note that Simulink Accelerator needed to generate code only for the first simulation.

%% Cleaning Up
% Close the model and remove the generated files.
bdclose(model)
clear([model,'_acc'])
cd(originalDir)
rmdir(tempDir,'s')


displayEndOfDemoMessage(mfilename)
