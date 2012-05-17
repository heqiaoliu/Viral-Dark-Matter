function [profData] = exprofile_unpack(rawData, profileInfo)
%EXPROFILE_UNPACK unpacks raw byte data for execution profiling
%   PROFDATA = EXPROFILE_UNPACK(RAWDATA, PROFILEINFO) takes an array of
%   uint8 values that have been uploaded from the Embedded Target real-time
%   system and converts it to a structured format. The format of RAWDATA depends
%   on how it was created on the Embedded Target, but must comply with the
%   following restrictions:
%
%   version        - 1 byte, version number of the Embedded Target profiling engine
%   oRunMaxSection - 1 bit, equals 1 if overrun flags included, zero otherwise
%   tMaxSection    - 1 bit, equals 1 if max turnaround times included, zero otherwise
%   logSection     - 1 bit, equals 1 if log section included, zero otherwise
%   alignment      - to next byte
%   numTimerTasks  - 2 bytes, number of timer-based tasks in the model
%   timePerTick    - 2 bytes, time per tick with units as defined by PROFILEINFO
%   reserved       - 2 bytes
%   oRunFlagsMax   - numTimerTasks bytes, maximum value of overrunFlags, since model
%                    execution began, for each timer based section; note that
%                    this is one greater than the maximum number of overruns
%                    that occurred at any one time.
%   alignment      - align to word size (as defined PROFILEINFO field)
%   tMax           - numTimerTasks*word_size bytes, max turnaround time, in seconds, for each task
%   alignment      - align to word size (as defined PROFILEINFO field)
%   numPoints      - word_size bytes, number of execution profiling data points
%   taskId         - word_size bytes, task identifier signed value with sign indicating
%                    task start (positive) or task end (negative)
%   counter        - word_size bytes, counter value for this event
%   
%      (taskId and counter fields repeated numPoints times)
%
%   The argument PROFILEINFO is a structure array that is required to provide supplementary
%   information about the execution profiling setup for the target processor. PROFILEINFO
%   must contain the following fields:
%   
%   .tasks.ids              - identifiers of non-timer based tasks
%   .tasks.names            - names of non-timer based tasks
%   .timer.timePerTickUnits - the target returns a value indicating the time per tick; this 
%                             field is the units for this value returned by the target.
%   .processor.wordsize     - word size in bytes of the target processor
%   .processor.lsbfirst     - byte ordering of the target processor; must be 1 if least significant
%                             byte is first (little Endian) or 0 otherwise (big Endian)
% 
%   An example:
%
%       profileInfo.tasks.names = {'CAN ISR'};     % CAN interrupt service routine
%       profileInfo.tasks.ids = [('7FFFFFF0')];    % Identifier for CAN interrupt service routine
%       profileInfo.timer.timePerTickUnits = 1e-9; % Time per tick returned in nanoseconds
%       profileInfo.processor.wordsize = 4;        % 32-bit processor, 4 bytes per word
%       profileInfo.processor.lsbFirst = 0;        % Word ordering is most significant byte first
%
%
%   The output PROFDATA is a structure with some or all of the following
%   fields. The fields that are included depend on which execution profiling
%   data sections were uploaded from the Embedded Target processor.
%
%   numTimerTasks  - number of timer-based tasks in the model
%   wsize          - word size, in bytes, of the task identifier and timer values
%   oRunMax        - The maximum number of overruns for each timer based section; 
%                    this is derived from the maximum value of the overrunFlags.
%   tMax           - see above
%   taskActivity   - task activity matrix
%   taskTs         - timer values in seconds corresponding to rows in the task 
%                    activity matrix
%   taskTicks      - timer values in ticks
%   timerPerTick   - number of seconds per timer tick
%   taskIdList     - array of task identifiers
%   taskNameList   - cell array of task names
%   warning        - warning text for when there is missing profiling data

%   Copyright 1994-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  

  lsbFirst = profileInfo.processor.lsbFirst;
  wsize = profileInfo.processor.wordsize;
  
  [version, oRunMaxSection, tMaxSection, ...
   logSection, numTimerTasks, timePerTick] = ...
      i_unpack_info_section(rawData(1:8), lsbFirst);
  
  nextIdx = 9;
  
  % Unpack the overrun data
  if (oRunMaxSection==1)
    oRunFlagsMax = double(rawData(nextIdx:nextIdx+numTimerTasks-1));
    nextIdx = nextIdx + numTimerTasks;
  end
  
  % Align index to word size. Note that for e.g. 4 byte words this means 1,
  % 5, 9, 13 .... as we are using 1-based indexing
  nextIdx = ceil((nextIdx-1)/wsize)*wsize+1;
  
  % Unpack the turnaround data
  if (tMaxSection==1)
    tMax = rawData(nextIdx:(nextIdx+numTimerTasks*wsize-1));
    tMax = (reshape(tMax, wsize, numTimerTasks))';
    tMax = i_byte_array_to_uint(tMax, lsbFirst);
    tMax = tMax * timePerTick * profileInfo.timer.timePerTickUnits;
    nextIdx = nextIdx + numTimerTasks*wsize;
  end
  
  % Align index to word size. Note that for e.g. 4 byte words this means 1,
  % 5, 9, 13 .... as we are using 1-based indexing
  nextIdx = ceil((nextIdx-1)/wsize)*wsize+1;
  
  % Unpack logged execution profile data
  if (logSection==1) 
    numPointsByteArray = rawData(nextIdx: nextIdx+wsize-1);
    numPoints = i_byte_array_to_uint((numPointsByteArray)', lsbFirst);
    nextIdx = nextIdx + wsize;
    try
        [taskIds, taskTicks] = i_process_log_data( ...
            rawData(nextIdx:(nextIdx+numPoints*wsize-1)),...
            wsize, ...
            lsbFirst);
    catch e
      TargetCommon.ProductInfo.error('profiling', 'ProfilingErrorUnpacking', e.message);
    end

    % Do integrity check on timer data and if necessary uwrap and convert
    % from count down to count up
    taskTicks = i_process_timer(taskTicks, wsize);

    % Get a list of the unique task identifiers
    taskIdList = unique(abs(taskIds));

    % How many Periodic profiling tasks have been captured
    numPeriodicTaskProfilingTasks = length(setdiff(taskIdList, profileInfo.tasks.ids));
    % How many section profiling tasks have been captured
    numAsyncProfilingTasks = length(taskIdList) - numPeriodicTaskProfilingTasks;
    % Length of taskIdList should be equal to number of timer tasks (offline) + the number of section tasks if it is complete 
    complete_taskIdList = length(taskIdList) == (numTimerTasks + numAsyncProfilingTasks);
    if (~complete_taskIdList)
      % Get the section of the taskIdList that represents the Async tasks
      asyncTasks_taskIdList = taskIdList(((length(taskIdList) + 1) - numAsyncProfilingTasks):(length(taskIdList)));
      % Change to vertical array
      asyncTasks_taskIdList = asyncTasks_taskIdList.';
      % Create a taskIdList - This can be done without reference to the collected data
      periodicTasks_taskIdList = 1:double(numTimerTasks);
      % Change to vertical array
      periodicTasks_taskIdList = periodicTasks_taskIdList.';
      % Merge data back togeather periodicTasks + sectionTasks
      taskIdList = vertcat(periodicTasks_taskIdList, asyncTasks_taskIdList);
    end
    
    % Get names corresponding to identifiers
    taskNameList = i_get_task_name_list(taskIdList, profileInfo.tasks.ids, ...
                                        profileInfo.tasks.names, numTimerTasks); 
  
    % Build a task activity matrix
    [taskActivity] = i_task_activity(taskIds, taskIdList);
  end

  profData.numTimerTasks = numTimerTasks;
  profData.wsize = wsize;
  if (oRunMaxSection==1)
    % If the maximum overrunFlag is either 1 or zero then no overruns have 
    % occurred. Otherwise the number of overruns is one less than the max value
    % of the overrunFlag
    profData.oRunMax = max(zeros(size(oRunFlagsMax)), oRunFlagsMax-1);
  end
  if (tMaxSection==1)
    profData.tMax = tMax;
  end
  if (logSection==1)
    profData.taskActivity = taskActivity;
    profData.taskIdList = taskIdList;
    profData.taskTs = taskTicks * timePerTick * profileInfo.timer.timePerTickUnits;
    profData.taskTicks = taskTicks;
    profData.timePerTick = timePerTick * profileInfo.timer.timePerTickUnits;
    profData.taskNameList = taskNameList;
  end

  profData = profiling_data_warning(profData, complete_taskIdList);
    

% Get names corresponding to identifiers
function taskNameList = i_get_task_name_list(taskIdList, taskIds, taskNames, numTimerTasks)
  
  % Check that taskIdList is sorted
  if any(sort(taskIdList)~=taskIdList)
    TargetCommon.ProductInfo.error('profiling', 'ProfilingTaskIdsNotSorted');
  end

  % Create labels for all the Timer tasks
  %
  % This can be done without reference to the collected data as we have 
  % the variable numTimerTasks which is calaculated offline
  for i=1:numTimerTasks
    if i==1
      taskName = 'Base Rate';
    else
      taskName = ['Sub-Rate ' num2str(i-1)];
    end
    taskNameList{i} = taskName;
  end

  % Create task names for all the Section tasks collected
  %
  % This must be done with reference to the collected data as we have no way
  % of knowing how many section tasks there are
  for i=1:length(taskIdList)
    % Check for a match in the profileInfo variable
    matchingId = find(taskIdList(i) == taskIds);
    % Is there a match
    if length(matchingId) == 1
      % Set the task name to the tag in the profileInfo variable
      taskName = taskNames{matchingId};
      % Append section task name to taskNameList
      taskNameList{(length(taskNameList) + 1)} = taskName;
    else
      if i > numTimerTasks
       taskName = ['Task ' num2str(taskIdList(i))];
       % Append section task name to taskNameList
       taskNameList{(length(taskNameList) + 1)} = taskName;
      end
    end
  end
    
% Convert the logged execution profile data from a byte array to task
% identifiers and counter values
function [ids, timerTicks] = i_process_log_data(rawData, wdsize, lsbFirst)

  rawData = (reshape(rawData, wdsize, length(rawData)/wdsize))';
  rawDataUint = i_byte_array_to_uint(rawData, lsbFirst);  
  
  ids = rawDataUint(1:2:end-1);
  timerTicks = rawDataUint(2:2:end);
  
  % The task identifiers are signed numbers in twos complement
  id_neg = find(ids >= 2^(wdsize*8-1));
  ids(id_neg) = -( 2^(wdsize*8) - ids(id_neg) );
  

% Do integrity check on timerTicks data and if necessary uwrap and convert from
% count down to count up
function timerTicks = i_process_timer(timerTicks, wsize)
  timerTicks_diff = diff(timerTicks);
  
  %
  % Handle case where timer is counting down
  %
  if sum( sign(timerTicks_diff) ) < 0
    timerTicks_diff = - timerTicks_diff;
  end
  
  %
  % Make sure counter values are unwrapped
  %
  jump_idx = find(timerTicks_diff<0);
  if wsize == 2
      timerTicks_max = 2^16; 
  elseif wsize == 4
      timerTicks_max = 2^32;
  end
  
  timerTicks_diff(jump_idx) = timerTicks_diff(jump_idx) + timerTicks_max;
  
  %
  % Convert from difference sequence back to absolute values
  %
  timerTicks = [ 0; cumsum( timerTicks_diff ) ];
  
% Create a task activity matrix with a column for each task. Each entry in this
% matrix must be one of the following
%
% 'i' - inactive
% 'e' - executing
% 'p' - pre-empted
%
function  [taskActivity] = i_task_activity(full_ids, taskIdList)
  
  ids_idx=zeros(size(full_ids));
  for i=1:length(taskIdList)
    ids_idx((full_ids == taskIdList(i))) = i;
    ids_idx((full_ids == -(taskIdList(i)) )) = -i;
  end
  if any(ids_idx==0)
    TargetCommon.ProductInfo.error('profiling', 'ProfilingTaskIds');
  end
  
  % Stack to hold pre-empted tasks
  stack = zeros(size(taskIdList));
  stack_pointer = 0;
  
  % Initialize task activity matrix
  taskActivity = repmat('i',length(ids_idx), length(taskIdList));

  % Set all tasks initially inactive
  taskActivity(1,:) = repmat('i',1,length(taskIdList));
  
  % Variable to hold task states
  taskStates = taskActivity(1,:);

  for i=1:length(ids_idx)
    id=ids_idx(i);
    if id > 0
      % Any currently executing task becomes pre-empted
      taskP = find(taskStates=='e');
      % Push the task onto the stack
      if ~isempty(taskP)
        stack_pointer=stack_pointer+1;
        stack(stack_pointer) = taskP;
        % Update state of the pre-empted task
        taskStates(taskP) = 'p';
      end
      % Update state of task that is now executing
      taskStates(id) = 'e';
    else
      % Update state variable so this task now inactive
      taskStates(-id) = 'i';
      % Pop pre-empted task from stack
      if (stack_pointer > 0) 
        taskP = stack(stack_pointer); 
        stack_pointer = stack_pointer - 1;
        taskStates(taskP) = 'e';
      end
    end
    taskActivity(i,:) = taskStates;
  end
  
  
% Unpack the profile data info section and confirm that checksum is
% correct.
function [version, oRunMaxSection, tMaxSection, logSection, numTimerTasks, ...
          timePerTick] = i_unpack_info_section(infoData, lsbFirst)
  
  version = double(infoData(1));
  if version ~= 1
    TargetCommon.ProductInfo.error('profiling', 'ProfilingBadVersion');
  end
  
  oRunMaxSection = double(bitand(infoData(2), 2^7) / 2^7);
  tMaxSection    = double(bitand(infoData(2), 2^6) / 2^6);
  logSection     = double(bitand(infoData(2), 2^5) / 2^5);
  
  numTimerTasks = i_byte_array_to_uint((infoData(3:4))', lsbFirst);

  timePerTick = i_byte_array_to_uint((infoData(5:6))', lsbFirst); 
  
  
  
% Convert a byte array to an unsigned int. numPointsByteArray must be a 
% matrix where each row represents an array of bytes to be converted to 
% an integer.
function uint_val = i_byte_array_to_uint(numPointsByteArray, lsbFirst)
  wsize = length(numPointsByteArray(1,:));
  bytes = double(numPointsByteArray);
  powermat = repmat((0:8:8*(wsize-1)),length(bytes(:,1)),1);
  scale = (2*ones(size(bytes))).^powermat;
  if lsbFirst ~=1
    scale = fliplr(scale);
  end
  
  uint_val = (sum((bytes.*scale)'))';
  
% Create a warning text if there is missing profiling data based on 
% the status of complete_taskIdList
function [profData] = profiling_data_warning(profData, complete_taskIdList)

  profData.warning = '';

  % Have we got a complete profiling data set based on taskIdList
  if (~complete_taskIdList)
    warning_profData = ['There were an insufficient number of data points: the recorded profiling data does not ' ...
      'contain sufficient information to report on this timer based task. It may be possible to capture data to report on ' ...
      'this task by increasing the number of data points in the target Options pane of the Configuration Parameters ' ...
      'which is located under the Real-Time Workshop category. '];
    % Compose warning message
    profData.warning = warning_profData;
  end
  
% end profiling_data_warning(profData, complete_taskIdList)
           
  
