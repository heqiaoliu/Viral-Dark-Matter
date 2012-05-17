%% SLDEMO_SOLVERS_MCODE
%
% This is a script that contains all the code necessary for sldemo_solvers
% demo. This code configures the model, creates solver settings, generates code
% for the model and then runs the generated code several times with different
% solver settings. In the end the script plots the results and cleans up the
% workspace.
%
% See also: SLDEMO_SOLVERS, SLDEMO_FOUCAULT

%   Copyright 2006-2008 The MathWorks, Inc.



% Make sure the current directory is writable
clear data;
[data.stat, data.fa] = fileattrib(pwd);
if ~data.fa.UserWrite
    disp('This script must be run in a writable directory');
    return
end

data.mdlName='sldemo_solvers';
open_system(data.mdlName);
% Open the model and configure it to use the RSim target. 
data.cs = getActiveConfigSet(data.mdlName);
set_param(data.cs, 'StopTime', '86400');
set_param(data.cs, 'SystemTargetFile','rsim.tlc');
set_param(data.cs, 'TemplateMakefile','rsim_default_tmf');
set_param(data.cs, 'RSIM_SOLVER_SELECTION','UseSolverModule');

% Define the names of files and folders that will be created during this demo.
data.optsFileName = [data.mdlName, '_opt_sets.mat'];
data.logFileName = [data.mdlName, '_run_scr.log'];
data.batFileName = [data.mdlName, '_run_scr'];
data.exeFileName = data.mdlName;
data.stop_time = get_param(data.mdlName,'StopTime');
if ispc
    data.exeFileName = [data.exeFileName, '.exe'];
    data.batFileName = [data.batFileName, '.bat'];
end
data.aggDataFile = [data.mdlName, '_results.mat'];
data.outDir = [data.mdlName, '_out'];
tic;

evalc('rtwbuild(data.mdlName)'); % Build the RSim executable for the model, don't show output 


% Create Solver sets.
% In this step we create the solver option sets to run the RSim executable
% using various variable-step solvers and relative tolerances.
if exist(data.optsFileName,'file')
   delete(data.optsFileName);
end

% create the list of solvers
data.SolverName_vals = {'ode45', 'ode23', 'ode15s', 'ode23t'};

% generate 10 relative values from 1e-1 to 1e-10
data.RelTol_vals = logspace(-3.5,-7,6); 

% number of option sets
data.nOptSets = length(data.RelTol_vals)*length(data.SolverName_vals);

% create the fields corresponding to all RelTols
data.aggData.Solver.Tolerance(1:length(data.RelTol_vals)) = struct('Deviation',[],'TimeElapsed',[],'t',[],'E',[],'SolverName',[],'RelTol',[]);

% create the fields corresponding to all Solvers
data.aggData.Solver=repmat(data.aggData.Solver, length(data.SolverName_vals), 1);

% options/settings for each simulation
options = struct('SolverName',[],'RelTol', [],'MaxOrder',5);
options = repmat(options, data.nOptSets, 1);

idx=1;
for i = 1:length(data.SolverName_vals)
    for j = 1:length(data.RelTol_vals)
        data.aggData.Solver(i).Tolerance(j).SolverName = data.SolverName_vals{i};
        data.aggData.Solver(i).Tolerance(j).RelTol = data.RelTol_vals(j);
        options(idx).SolverName =data.SolverName_vals{i};
        options(idx).RelTol = data.RelTol_vals(j);
        idx = idx + 1;
    end
end

% Save the options structure array with all the parameter sets to a mat file.
save(data.optsFileName, 'options');
clear options;

% Create a batch file to run the executable many times
% We create a batch/script file to run the RSim executable over the solver
% options sets. Each run reads the specified solver-options set from the solver-options
% mat-file and writes the results to the specified output mat-file.  Note that we use the
% time out option so that if a particular run were to hang (because the model
% may have a singularity for that particular parameter set), we abort the run
% after the specified time limit is exceeded and proceed to the next run.
% 
% For example, the command (on windows):
%
%   model.exe -S solver_opt.mat@3 -o run3.mat -L 3600 2>&1>> run.log
%
% specifies that the 3rd parameter set from opts structure in solver_opt.mat be used as
% the solver specifications for the model, the results be written to run3.mat and 
% abort execution if it takes longer than 3600 seconds of CPU time. The messages
% displayed during execution are saved in the logfile, run.log which can be
% viewed for debugging purposes after execution.

fid = fopen(data.batFileName, 'w');
if exist(data.outDir,'dir')
    [data.s,data.msg] = rmdir(data.outDir,'s');
    if (data.s == 0)
        error(data.msg); 
    end
end

[data.s,data.msg] = mkdir('.', data.outDir);
if (data.s == 0) 
    error(data.msg); 
end

if exist(data.logFileName,'file') 
   delete(data.logFileName); 
end

for idx=1:data.nOptSets
    data.outMatFile = [data.outDir, filesep, filesep, 'out', num2str(idx), '.mat'];
    data.cmd  = [data.exeFileName, ' -S ', data.optsFileName, '@', num2str(idx-1), ...
        ' -o ', data.outMatFile,' -L 3600'];
    if isunix
        data.cmd  = [data.cmd, ' 2>&1 >> ', data.logFileName];
        data.preEcho = '';
        data.postEcho = '';
        fprintf(fid,[data.preEcho, 'echo "', data.cmd, '"\n']);
        fprintf(fid,['sh -c ''' data.cmd,''' \n']);   fprintf(fid,[data.preEcho, 'echo' data.postEcho,'\n']);
    else
        data.cmd  = [data.cmd, ' 1>> ', data.logFileName, ' 2>&1'];
        data.preEcho = '@';
        data.postEcho = '.';
        fprintf(fid,[data.preEcho, 'echo "', data.cmd, '"\n']);
        fprintf(fid,[data.cmd,'\n']);   fprintf(fid,[data.preEcho, 'echo' data.postEcho,'\n']);
   end
 end
if isunix,
    system(['touch ', data.logFileName]);
    system(['chmod +x ', data.batFileName]);
end
fclose(fid);

% Run the batch file. All the results are saved in the directory modelname_out.
[data.stat, data.res] = system(['.' filesep data.batFileName]);
if data.stat ~= 0
    error(['Error running batch file ''', data.batFileName, ''' :', data.res]);
end

% Obtain the execution times for each run from the log-file
fid = fopen(data.logFileName);
data.runlog= fscanf(fid,'%s');
fclose(fid);
data.etime = regexp(data.runlog,'=(?<exetime>[\.\d]+)s','names');
data.exetime = zeros(1,data.nOptSets);
for i =1: size(data.etime,2)
    data.exetime(i)= str2num(data.etime(i).exetime); %#ok<ST2NM>
end

idx=1; %index
% Compute the energy deviation: how much the normalized energy changed over the course of the simulation
for i = 1:length(data.SolverName_vals)
    for j = 1:length(data.RelTol_vals)
        data.outMatFile = [data.outDir, filesep,'out', num2str(idx), '.mat'];
        if exist(data.outMatFile,'file')
            load(data.outMatFile);
            
            % deviation in percent
            data.aggData.Solver(i).Tolerance(j).Deviation = max(abs(rt_E.signals.values(1)-rt_E.signals.values(end))); 
            
            data.aggData.Solver(i).Tolerance(j).t = rt_E.time;
            data.aggData.Solver(i).Tolerance(j).E = rt_E.signals.values;
            data.aggData.Solver(i).Tolerance(j).TimeElapsed = data.exetime(idx);
            
            if data.aggData.Solver(i).Tolerance(j).t(end) < data.stop_time
               aggData(idx).Deviation = nan; %#ok<AGROW>
            end
        else
            data.exetime(idx+1:end) = data.exetime (idx:end-1);
            data.aggData.Solver(i).Tolerance(j).TimeElapsed = nan;
            data.aggData.Solver(i).Tolerance(j).Deviation = nan;
            data.aggData.Solver(i).Tolerance(j).t = nan;
            data.aggData.Solver(i).Tolerance(j).E = nan;
        end
        idx=idx+1;
    end
end


% Save the aggData structure to the results MAT-file. At this point all the other
% MAT-files can be deleted as the data.aggData data structure contains the aggregation
% of all input (parameters sets) and output data (simulation results).

temp=data.aggData; %#ok<NASGU> used in save command below
save(data.aggDataFile,'temp');
clear temp i j idx;
data.t=toc;
disp(['Took ',num2str(data.t),' seconds to generate results from ',num2str(data.nOptSets),' simulation runs']);
close_system(data.mdlName, 0);


% Plot the results
for i =  1:length(data.SolverName_vals)
    for j = 1:length(data.RelTol_vals)
        data.Deviation(i,j)  = data.aggData.Solver(i).Tolerance(j).Deviation;
        data.TimeElapsed(i,j)  = data.aggData.Solver(i).Tolerance(j).TimeElapsed;        
    end
end

figure('Tag','CloseMe','units','pixels','position',[50 50 700 600]);
subplot(2,1,1);
H1 =loglog(data.RelTol_vals, data.Deviation); 
axis([1e-7 10^(-3.5) 1e-5 10]);
ylabel('Maximum Relative Error in Energy'); 
title('Variable-Step Solver Performance Asessment');
subplot(2,1,2);
H2 = loglog(data.RelTol_vals, data.TimeElapsed);
ylabel('Simulation Execution Time (sec)');
xlabel('Relative Tolerance');
axis([1e-7 10^(-3.5) 0.4 70]);
SolverMark = ['d','o','p','s'];
for i=1:length(H1)
    % set(H1(i),'LineStyle','-');
    % set(H2(i),'LineStyle','-.');
    set(H1(i),'Marker',SolverMark(i));
    set(H2(i),'Marker',SolverMark(i));
    % set(H1(i),'Color', 'b');
    % set(H2(i),'Color', 'k');
    % set(H1(i),'MarkerFaceColor', 'b');
    % set(H2(i),'MarkerFaceColor', 'k');
end

legend(H1,data.SolverName_vals,'Location','E');
legend(H2,data.SolverName_vals,'Location','NE');
clear rt_E fid data;