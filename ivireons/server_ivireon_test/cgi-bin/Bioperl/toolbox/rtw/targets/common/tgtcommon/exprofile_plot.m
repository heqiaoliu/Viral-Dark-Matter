function [profData] = exprofile_plot(profData)
%EXPROFILE_PLOT execution profiling function that displays a task activity plot
%   EXPROFILE_PLOT(PROFDATA) takes execution profile data in the form provided
%   by EXECPROF_UNPACK and displays it a task activity plot.
%
%   See also EXPROFILE_UNPACK

%   Copyright 1994-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  

% Task activity plot
  clf
  profData.recordedTaskIdx = i_task_plot(profData.taskActivity, profData.taskIdList, profData.taskTs);
  i_task_ylabels(profData.taskNameList);
  grid
  duration = num2str(( profData.taskTs(end) - profData.taskTs(1)) );  
  title(['Plot of recorded profiling data over ' duration ' seconds'])
  xlabel('Time in seconds')
  
  figure(gcf)
  
  % workaround issue 337529 with default renderer
  set(gcf,'Renderer','zbuffer'); 

% Add y-axis labels for each task
function i_task_ylabels( taskNameList )
  nLabels = 2*length(taskNameList);
  [labels{1:nLabels}] = deal(' ');
  [labels{1:2:(2*length(taskNameList))}] = deal(taskNameList{:});
  set(gca,'ytick',[1:0.5:length(taskNameList)]+0.5);
  set(gca,'yticklabel',strvcat(labels));
  set(gca,'TickLength',[0 0]);
  set(gca,'ylim',[0.9 (length(taskNameList) + 1)]);
  
function  recordedTaskIdx = i_task_plot(taskActivity, taskIdList, taskTs, tickTime)

  recordedTaskIdx = [];
  % For each task, plot regions where task is executing or pre-empted
  for i=1:length(taskIdList)
    [xExecData, yExecData, xPreemptData, yPreemptData] = ...
        i_get_patch_data(taskActivity(:,i), taskTs);

    % if the xExecData and yExecData is not empty then there is data for this task
    if ((~isempty(xExecData)) & (~isempty(yExecData)))
      % add the index of taskId to the list
      recordedTaskIdx((length(recordedTaskIdx) + 1)) = i;
    end

    execution_colour = [1 0.3 0.3];
    preemtion_colour = [1 0.85 0.85];
    h = patch(xExecData, yExecData+i, execution_colour);
    set(h, 'EdgeColor', execution_colour);
    set(h, 'FaceColor', execution_colour);
    
    h = patch(xPreemptData, yPreemptData+i, preemtion_colour);
    set(h, 'EdgeColor', 'none');
    set(h, 'FaceColor', preemtion_colour);

    
    % Mark the start of each task
    xStart = i_get_task_start_data(taskActivity(:,i), taskTs); 
    h = line(xStart, ones(size(xStart)) * i + 0.05);
    set(h,'marker','^');
    set(h,'linestyle','none');
    
  end
  
  % Add a border at top and bottom
  h = gca;
  set(h, 'YLim', get(h,'YLim')+[-0.1 0.1]);

% Build data to plot regions where task is executing or pre-empted
function [xExecData, yExecData, xPreemptData, yPreemptData] ...
      = i_get_patch_data(tActivity, taskTs)
  
  % identify all events
  event_idx = find(tActivity(:) ~= 'u');
  % identify all activation events
  e_idx = find(tActivity(event_idx) == 'e');
  % strip any trailing activation events
  if ~isempty(e_idx)
    if e_idx(end) == length(event_idx)
      e_idx = e_idx(1:end-1);
    end
  end
  % identify activation and de-activation times
  activationT = taskTs(event_idx(e_idx));
  stopT = taskTs(event_idx(e_idx+1));
  % build data for executing region
  xExecData = [activationT stopT stopT activationT]';
  yExecData = diag([0.1; 0.1; 0.9; 0.9])*ones(4,length(activationT));
  
  
  % identify all preemption events
  preempted_idx = find(tActivity(event_idx) == 'p');
  % strip any trailing pre-empted events
  if ~isempty(preempted_idx)
    if preempted_idx(end) == length(event_idx)
      preempted_idx = preempted_idx(1:end-1);
    end
    % identify activation and de-activation times
    activationT = taskTs(event_idx(preempted_idx));
    stopT = taskTs(event_idx(preempted_idx+1));
    % build data for pre-empted region
    xPreemptData = [activationT stopT stopT activationT]';
    yPreemptData = diag([0.1; 0.1; 0.9; 0.9])*ones(4,length(activationT));
  else
    xPreemptData = [];
    yPreemptData = [];
  end

% Data to plot task start times
function startT = i_get_task_start_data(tActivity, taskTs)
  
% identify all non-leading or trailing start executing events
  s_idx = 2;
  event_idx = s_idx:length(tActivity)-1;
  e_idx = find(tActivity(event_idx) == 'e') + (s_idx-1);

  % filter only the 'e'xecute events that were preceded by 'i'dle state
  start_idx = e_idx( find( tActivity(e_idx-1) == 'i' ) ); 
  
  % identify task start times
  startT = taskTs(start_idx);

