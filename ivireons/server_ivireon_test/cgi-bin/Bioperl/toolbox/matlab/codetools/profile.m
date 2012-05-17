function s = profile(varargin)
%PROFILE Profile execution time for function
%   PROFILE ON starts the profiler and clears previously recorded
%   profile statistics.
%
%   PROFILE takes the following options:
%
%      -TIMER CLOCK
%         This option specifies the type of time to be used in profiling.
%         If CLOCK is 'cpu' (the default), then compute time is measured.
%         If CLOCK is 'real', then wall-clock time is measured.  For
%         example, the function PAUSE will have very small cpu time, but
%         real time that accounts for the actual time paused.
%
%      -HISTORY
%         If this option is specified, MATLAB records the exact
%         sequence of function calls so that a function call
%         history report can be generated.  NOTE: MATLAB will
%         not record more than 10000 function entry and exit events
%         (see -HISTORYSIZE below).  However, MATLAB will continue
%         recording other profiling statistics after this limit has
%         been reached.
%
%      -NOHISTORY
%         If this option is specified, MATLAB will disable history
%         recording.  All other profiler statistics will continue
%         to be collected.
%
%      -HISTORYSIZE SIZE
%         This option specifies the length of the function call history
%         buffer.  The default is 1000000.
%
%      Options may appear either before or after ON in the same command,
%      but they may not be changed if the profiler has been started in a
%      previous command and has not yet been stopped.
%
%   PROFILE OFF stops the profiler.
%
%   PROFILE VIEWER stops the profiler and opens the graphical profile browser.
%   The output for PROFILE VIEWER is an HTML file in the Profiler window.
%   The file listing at the bottom of the function profile page shows four
%   columns to the left of each line of code.
%         Column 1 (red) is total time spent on the line in seconds.
%         Column 2 (blue) is number of calls to that line.
%         Column 3 is the line number
%
%   PROFILE RESUME restarts the profiler without clearing
%   previously recorded function statistics.
%
%   PROFILE CLEAR clears all recorded profile statistics.
%
%   S = PROFILE('STATUS') returns a structure containing
%   information about the current profiler state.  S contains
%   these fields:
%
%       ProfilerStatus   -- 'on' or 'off'
%       DetailLevel      -- 'mmex'
%       Timer            -- 'cpu' or 'real'
%       HistoryTracking  -- 'on' or 'off'
%       HistorySize      -- 10000 (default)
%
%   STATS = PROFILE('INFO') suspends the profiler and returns
%   a structure containing the current profiler statistics.
%   STATS contains these fields:
%
%       FunctionTable    -- structure array containing stats
%                           about each called function
%       FunctionHistory  -- function call history table
%       ClockPrecision   -- precision of profiler time
%                           measurement
%       ClockSpeed       -- Estimated clock speed of the cpu (or 0)
%       Name             -- name of the profiler (i.e. MATLAB)
%
%   The FunctionTable array is the most important part of the STATS
%   structure. Its fields are:
%
%       FunctionName     -- function name, includes subfunction references
%       FileName         -- file name is a fully qualified path
%       Type             -- MATLAB function, MEX-function
%       NumCalls         -- number of times this function was called
%       TotalTime        -- total time spent in this function
%       Children         -- FunctionTable indices to child functions
%       Parents          -- FunctionTable indices to parent functions
%       ExecutedLines    -- array detailing line-by-line details (see below)
%       IsRecursive      -- is this function recursive? boolean value
%       PartialData      -- did this function change during profiling?
%                           boolean value
%
%   The ExecutedLines array has several columns. Column 1 is the line
%   number that executed. If a line was not executed, it does not appear in
%   this matrix. Column 2 is the number of times that line was executed,
%   and Column 3 is the total spent on that line. Note: The sum of Column 3
%   does not necessarily add up to the function's TotalTime.
%
%   If you want to save the results of your profiler session to disk, use
%   the PROFSAVE command.
%
%   Examples:
%
%       profile on
%       plot(magic(35))
%       profile viewer
%       profsave(profile('info'),'profile_results')
%
%       profile on -history
%       plot(magic(4));
%       p = profile('info');
%       for n = 1:size(p.FunctionHistory,2)
%           if p.FunctionHistory(1,n)==0
%               str = 'entering function: ';
%           else
%               str = ' exiting function: ';
%           end
%           disp([str p.FunctionTable(p.FunctionHistory(2,n)).FunctionName]);
%       end
%
%   See also PROFSAVE, PROFVIEW.

%   Copyright 1984-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.28 $  $Date: 2010/03/31 18:23:25 $

enableAtEnd = callstats('stop');
if enableAtEnd
  initialState = 'on';
else
  initialState = 'off';
end

try
    [action, detailLevel, timerIndex, history, historysize, memory, overhead] ...
         = ParseInputs(initialState, varargin{:});
catch ME
    MX = MException('MATLAB:profiler:InputParseProblem',ME.message);
    throw(MX);
end

if detailLevel > 0
    callstats('level', detailLevel);
end

if timerIndex > 0
    callstats('timer', timerIndex - 1);
end

if history ~= -1
    callstats('history', history);
end

if historysize ~= -1
    callstats('historysize', historysize);
end

if memory ~= -1
    callstats('memory', memory);
end

if overhead ~= -1
    callstats('remove_sample_overhead', overhead-1);
end

switch lower(action)
    case 'on'
        callstats('reset');
        notifyUI('start');
        enableAtEnd = true;

    case 'off'
        notifyUI('stop');
        enableAtEnd = false;

    case 'resume'
        notifyUI('start');
        enableAtEnd = true;

    case 'clear'
        callstats('clear');
        notifyUI('clear');

    case 'report'
        profreport

    case 'viewer'
        if ~usejava('mwt')
            error('MATLAB:profiler:RequiresJVM', 'The profiler requires the Java VM');
        else
	    notifyUI('stop');
            enableAtEnd = false;
            stats = profile('info');
            if isempty(stats.FunctionTable) && ~callstats('has_run')
                com.mathworks.mde.profiler.Profiler.invoke;
            else
                profview(0,stats);
            end
        end

    case 'status'
        s.ProfilerStatus = initialState;
        switch callstats('level')
            case 1
                s.DetailLevel = 'mmex';

            case 2
                s.DetailLevel = 'builtin';
        end
        switch callstats('timer')
            case 0
                s.Timer = 'none';
            case 1
                s.Timer = 'cpu';
            case 2
                s.Timer = 'real';
        end
        switch(callstats('history'))
            case 0
                s.HistoryTracking = 'off';
            case 1
                s.HistoryTracking = 'on';
            case 2
                s.HistoryTracking = 'timestamp';
        end
	s.HistorySize = callstats('historysize');

    case 'info'
        [ft,fh,cp,name,cs,~,overhead] = callstats('stats');
        s.FunctionTable = ft;
        s.FunctionHistory = fh;
        s.ClockPrecision = cp;
        s.ClockSpeed = cs;
        s.Name = name;
	s.Overhead = overhead;

    case 'none'
        % Nothing to do

    otherwise
        warning('MATLAB:profile:ObsoleteSyntax', ...
            'Unknown argument for PROFILE. See HELP PROFILE.');
end

if (enableAtEnd)
    callstats('resume');
end
end

%%%
%%% ParseInputs
%%%
function [action, level, clock, history, historysize, memory, overhead] ...
    = ParseInputs(initialState, varargin)
%PARSEINPUTS Parse user's input arguments.

% Defaults
action = 'none';
level = 0;
clock = 0;
history = -1;
historysize = -1;
memory = -1;
overhead = -1;

error(nargchk(2,Inf,nargin,'struct'));

  function option = ParseOption(optionname, argname, options)
    if strcmp(initialState, 'on');
        error('MATLAB:profiler:InputParseProblem', 'The profiler has already been started.  %s cannot be changed.', ...
                                                   optionname);
    elseif k == length(varargin)
        error('MATLAB:profiler:InputParseProblem', '%s must follow -%s option.', argname, optionname);
    else
        k = k + 1;
        if isempty(options)
          if ischar(varargin{k})
            option = str2num(varargin{k});		%#ok - mlint
          else
            option = varargin{k};
          end
          if isempty(option) || option <= 0 || fix(option) ~= option
 	    error('MATLAB:profiler:InputParseProblem', '%s must be a positive integer.', optionname);
          end
        else
          option = strmatch(lower(varargin{k}), options);
          if (isempty(option))
            error('MATLAB:profiler:InputParseProblem', 'Invalid %s setting.', argname);
          elseif (length(option) > 1)
            error('MATLAB:profiler:InputParseProblem', 'Ambiguous %s setting.', argname);
          end
        end
    end
  end

% Walk the input argument list
k = 1;
while (k <= length(varargin))
    arg = varargin{k};
    if (~ischar(arg) || isempty(arg))
        error('MATLAB:profiler:InputParseProblem', 'Invalid input.');
    end

    if (arg(1) == '-')
        % It's an option
        options = {'detail', 'timer', 'history', 'nohistory', 'historysize', ...
                   'timestamp', 'memory', 'callmemory', 'nomemory', ...
	 	   'remove_overhead' };
        idx = strmatch(lower(arg(2:end)), options, 'exact');
        if (isempty(idx))
            error('MATLAB:profiler:InputParseProblem', 'Unknown option.');
        end
        if (length(idx) > 1)
            error('MATLAB:profiler:InputParseProblem', 'Ambiguous option.');
        end

        option = options{idx};
        switch option
            case 'detail'
                level = ParseOption('DETAIL','LEVEL',{'mmex','builtin'});

            case 'timer'
                clock = ParseOption('TIMER','CLOCK',{'none','cpu','real'});

            case 'remove_overhead'
                overhead = ParseOption('REMOVE_PROFILER_OVERHEAD','ON/OFF',{'off','on'});

            case 'nohistory'
                history = 0;

            case 'history'
                history = 1;

            case 'timestamp'
                history = 2;

            case 'historysize'
                historysize = ParseOption('HISTORYSIZE','SIZE',{});

            case 'nomemory'
                memory = 1;

            case 'callnomemory'
                memory = 2;

            case 'memory'
                memory = 3;

            otherwise
                error('MATLAB:profiler:InputParseProblem', 'Unknown option.');
        end

    else
        % It's an action
        action = arg;
    end

    k = k + 1;
end
end

function notifyUI(action)
% Test help ... Remove me...

if usejava('mwt')
%     import com.mathworks.mde.profiler.Profiler;
    switch action
        case 'start'
            com.mathworks.mde.profiler.Profiler.start;
        case 'stop'
            com.mathworks.mde.profiler.Profiler.stop;
        case 'clear'
            com.mathworks.mde.profiler.Profiler.clear;
    end
end
end
