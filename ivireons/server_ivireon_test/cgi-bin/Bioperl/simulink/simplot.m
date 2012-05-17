function varargout = simplot(time, data, ports, diffStr)
%SIMPLOT Plot data structures output from Simulink.
%   SIMPLOT(DATA) creates Scope-like graphics in a Handle Graphics window.
%   DATA is either a data structure or matrix of the form produced by Simulink
%   output blocks.  Colors are set to match those used in the Simulink Scope.
%   
%   If DATA is a "Matrix" or "Structure without time", a separate time vector 
%   can be specified.  TIME is a vector with the same length as the data 
%   signals in DATA and is entered as the first input argument.  TIME has no
%   effect if DATA is a "Structure with time".  For example:
%
%       SIMPLOT(TIME, DATA)
%
%   plots DATA against the TIME.
%
%   If DATA is a structure produced by a multi-port Scope block, the data from 
%   each port are displayed in separate subplots.  A vector of port indices can 
%   be used to select specific ports.  For example:
%
%       PORTS = [1,3];
%       SIMPLOT(DATA, PORTS)
%
%   plots the data from the 1st and 3rd ports.
%
%   If DATA is a cell array of structures or matrices, the plots from each 
%   element are overlayed so that comparisons can be made between multiple runs.
%   Each run is assumed to have identical structure.  Line styles are used to 
%   differentiate between runs.  For example:
%
%      DATA = {RUN1, RUN2};      % NOTE: Cell array - {}
%      SIMPLOT(DATA);
%
%   overlays the data from RUN1 and RUN2.
%
%   If DATA contains "Matrices" or "Structures without time", the data sets for
%   all runs must be the same size. 
%
%   The 'diff' flag is used to display the difference between multiple runs. The
%   1st run is subtracted from subsequent runs and the results are plotted with 
%   the line style of the run being compared. Linear interpolation is used if 
%   time vectors are not identical. If start and stop times differ between runs, 
%   the difference is only plotted for the region of overlap. For example:
%
%      DATA = {RUN1 RUN2};
%      SIMPLOT(DATA, 'diff')
%
%   plots RUN2-RUN1 using the line style for RUN2.
%   
%   COMBINING INPUT ARGUMENT OPTIONS:
%   ---------------------------------
%   The options described above can be used in various combinations.
%   All input arguments, apart from DATA, are optional but when included must be 
%   entered in the following order:
%
%      SIMPLOT(TIME, DATA, PORTS, 'diff')
%
%   OBTAINING OBJECT HANDLES:
%   -------------------------
%   HFIG = SIMPLOT(DATA) returns the handle to the figure.
%
%   [HFIG, HAXES, HLINES] = SIMPLOT(DATA) returns the handles to the figure, 
%   axes and lines plotted respectively. 
%
%   Some common uses for these handles include:
%      WHITEBG(HFIG)                 to use standard MATLAB figure colors.
%      SET(HAXES, 'NextPlot', 'add') to turn HOLD ON for all axes.
%      SET(HLINES, 'LineStyle', '-') to set all line styles to solid lines.
%
%   See also PLOT.

%   Copyright 1990-2007 The MathWorks, Inc.
%   $Revision: 1.11.2.1 $


% ===========================================================================
% ERROR CHECKING
% ===========================================================================

% Check validity of 1st input argument:
switch nargin
case 1
  if isempty(time)
    DAStudio.error('Simulink:blocks:EmptyInputArgument');
  elseif (iscell(time) | isstruct(time) | isnumeric(time))
    % ({Struct}) | ({MATRIX}) | (Struct) | (MATRIX)
    data = time;
    clear time;
  else
    DAStudio.error('Simulink:blocks:InvalidInputArg4Simplot');
  end
case 2
  if isempty(time) | isempty(data)
    DAStudio.error('Simulink:blocks:EmptyInputArgument');
  elseif (iscell(time) & strcmpi(data, 'diff'))
    % ({Struct}, 'diff') | ({MATRIX}, 'diff') 
    diffStr = 'diff';
    data = time;
    clear time;
  elseif iscell(time) & isnumeric(data) 
    % ({Struct}, [PORTS])
    if ~all(cellfun('isclass', time, 'struct'))
      DAStudio.error('Simulink:blocks:PortsValid4DataInStructureFormat');
    end
    ports = data;
    data = time;
    clear time;
  elseif isstruct(time) & isnumeric(data)
    % (Struct, [PORTS])
    ports = data;
    data = time;
    clear time;
  elseif isnumeric(time) & isnumeric(data)
    % (time, MATRIX)
    % *** CHECK AGAINST (MATRIX, [PORTS]) ***
    if all(size(time)~=1) % time must be a vector
      DAStudio.error('Simulink:blocks:PortsValid4DataInStructureFormat');
    elseif size(data, 1)==1 % expect column vector for data
      DAStudio.error('Simulink:blocks:PortsValid4DataInStructureFormat');
    end
  elseif ~(isnumeric(time) & (iscell(data) | isstruct(data))) 
    % (time, {Struct}) | (time, {MATRIX}) | (time, Struct) 
    DAStudio.error('Simulink:blocks:InvalidInputArg4Simplot');
  end
case 3
  if isempty(time) | isempty(data) | isempty(ports)
    DAStudio.error('Simulink:blocks:EmptyInputArgument');
  elseif strcmpi(ports, 'diff')
    diffStr = 'diff';
    if iscell(time) 
      % ({Struct}, [PORTS], 'diff')
      if ~all(cellfun('isclass', time, 'struct'))
        DAStudio.error('Simulink:blocks:PortsValid4DataInStructureFormat');
      end
      ports = data;
      data = time;
      clear time;
    elseif isnumeric(time) & iscell(data)
      diffStr = 'diff';
      clear ports
    else
      % (time, {Struct}, 'diff') | (time, {MATRIX}, 'diff')
      DAStudio.error('Simulink:blocks:InvalidInputArg4Simplot');
    end
  elseif isnumeric(time) & iscell(data) & isnumeric(ports)
    % (time, {Struct}, [PORTS])
    if ~all(cellfun('isclass', data, 'struct'))
      DAStudio.error('Simulink:blocks:PortsValid4DataInStructureFormat');
    end
  elseif ~(isnumeric(time) & isstruct(data) & isnumeric(ports))
    % (time, Struct, [PORTS])
    DAStudio.error('Simulink:blocks:InvalidInputArg4Simplot');
  end
case 4
  if isempty(time) | isempty(data) | isempty(ports) | isempty(diffStr)
    DAStudio.error('Simulink:blocks:EmptyInputArgument');
  elseif isnumeric(time) & iscell(data) & isnumeric(ports) & strcmpi(diffStr, 'diff') 
    % (time, {Struct}, [PORTS], 'diff')
    if ~all(cellfun('isclass', data, 'struct'))
      DAStudio.error('Simulink:blocks:PortsValid4DataInStructureFormat');
    end
  else
    DAStudio.error('Simulink:blocks:InvalidInputArg4Simplot');
  end
otherwise
  DAStudio.error('Simulink:blocks:SimplotArguments');
end

% Convert all data to cell array of structures.
if iscell(data)  
  if ~all(cellfun('isclass', data, 'struct')) % {Struct}
    for i = 1:length(data)
      if isnumeric(data{i}) % {MATRIX}
        % Assume that no time vector is provided.
        %if all(size(data{i})~=1) & all(diff(data{i}(:,1)>0)) %Check for time vector in 1st column
        %  warning(['Using first column of data as time vector for run #', num2str(i), '.'])
        %  sigStruct = struct('values', data{i}(:,2:end), 'label', '');
        %  data{i} = struct('time', data{i}(:,1), 'signals', sigStruct);
        %else % No Time Vector
        sigStruct = struct('values', data{i}, 'label', '');
        data{i} = struct('time', [], 'signals', sigStruct);
        %end
      else
        DAStudio.error('Simulink:blocks:DataMustContainStructuresOrMatrices');
      end
    end
  end
elseif isstruct(data) & all(size(data)==1) % Struct
  data = {data};
elseif isnumeric(data) % MATRIX
  % Assume that no time vector is provided.
  %if size(data)~=1 & all(diff(data(:,1)>0)) %Check for time vector in 1st column
  %  warning(['Using first column of data as time vector for run #', num2str(i), '.'])
  %  sigStruct = struct('values', data(:,2:end), 'label', '');
  %  data = {struct('time', data(:,1), 'signals', sigStruct)};
  %else % No Time Vector
  sigStruct = struct('values', data, 'label', '');
  data = {struct('time', [], 'signals', sigStruct)};
  %end
else
   DAStudio.error('Simulink:blocks:DataMustBeStructureOrMatrix');
end

% Check size of "time" 
if exist('time') == 1
  if any(size(time)==1)
    time = time(:);
  else
    DAStudio.error('Simulink:blocks:TimeMustBeAVector');
  end
end

% Check contents of "data"
nStructs = length(data);
for i=1:nStructs
  % Check for essential fields within data structure.
  if ~(isfield(data{i},'time')              & isfield(data{i},'signals') & ...
       isfield(data{i}.signals(1),'values') & isfield(data{i}.signals(1),'label'))
    DAStudio.error('Simulink:blocks:EssentialFieldsMissing',num2str(i));
  end
  
  % Handle matrix signals ("values" field contains 3-D matrix)
  % - "dimensions" contains [nRowsOfMatrixSignal nColsOfMatrixSignal]
  % - "values" field contains 3-D matrix (1 page per time step).
  %   NOTE: If there is only 1 time step, "values" contains a 2-D matrix
  % - Convert to 2-D matrix (1 row per time step).
  for j = 1:length(data{i}.signals)
    if isfield(data{i}.signals(j), 'dimensions')
      dimsVal = data{i}.signals(j).dimensions;
      if size(dimsVal, 2) == 2
        % Check that "values" contains 3-D matrix
        if ndims(data{i}.signals(j).values) == 3
          sizeVal = size(data{i}.signals(j).values);
          nCols = sizeVal(1)*sizeVal(2);
          nRows = sizeVal(3);
          data{i}.signals(j).values = ...
            reshape(data{i}.signals(j).values, [nCols nRows])';
        else % (Only one time step - "values" contains 2-D matrix)
          data{i}.signals(j).values = (data{i}.signals(j).values(:))';
        end
      end
    end
  end
  
  if i == 1 % Check validity of sizes & dimensions of structure for 1st run
    sizeSigs = size(data{1}.signals);
    if sizeSigs(1) ~= 1
      DAStudio.error('Simulink:blocks:ExpectedSignals2Contain1NDataStructure',num2str(i));
    end
    
    nDimsVal = cellfun('ndims', {data{1}.signals.values});
    if any(nDimsVal ~= 2)
      DAStudio.error('Simulink:blocks:ExpectedValues2Contain2dMatrix',num2str(i));
    end
    
    nCols = cellfun('size', {data{1}.signals.values}, 2); 
    
  else % Check that all other runs match 1st run (i~=1)
    
    % Check number of signals in each run (must match 1st run)
    if ~isequal(size(data{i}.signals), sizeSigs)
      DAStudio.error('Simulink:blocks:SizeOfDataStructuresDiff',num2str(i));
    end
    
    % Check signal widths for each run (must equal 1st run)
    if (~isequal(cellfun('ndims',{data{i}.signals.values}),  nDimsVal) | ...
        ~isequal(cellfun('size', {data{i}.signals.values},2),nCols))
      DAStudio.error('Simulink:blocks:SignalWidthsDiffBtwnRuns', num2str(i));
    end
  end
  
  % Check time vector for each run. 
  if isempty(data{i}.time) & exist('time')==1
    data{i}.time = time;
  end
  
  if isempty(data{i}.time)
    if ~(exist('noTimeVector')==1) 
      if i > 1
        DAStudio.error('Simulink:blocks:TimeVectorNotDefined4Run', num2str(i));
      else
        noTimeVector = 1;
      end
    elseif size(data{i}.signals(1).values,1) ~= size(data{noTimeVector}.signals(1).values)
      DAStudio.error('Simulink:blocks:NoTimeVectorDefined',  num2str(i));
    end
  elseif exist('noTimeVector')==1
    DAStudio.error('Simulink:blocks:TimeVectorNotDefined4PrevRuns',num2str(i));
  elseif ndims(data{i}.time) ~= 2 | size(data{i}.time, 2) ~= 1 | any(diff(data{i}.time) <= 0) | ...
         ~all(size(data{i}.time, 1) == cellfun('size', {data{i}.signals.values}, 1))
    DAStudio.error('Simulink:blocks:InvalidTimeVector4Run',num2str(i));
  end
end

% Set "ports" if not already set.
if ~(exist('ports')==1)
  ports = 1:length(data{1}.signals);
elseif ~isnumeric(ports) | any(rem(ports,1)) | any(ports<1) | any(ports>sizeSigs(2)) 
  DAStudio.error('Simulink:blocks:PortIndicesExceedNoOfSignals');
end

% ===========================================================================
% DIFFERENCE CALCULATIONS - INTERPOLATING IF NECESSARY
% ===========================================================================
if exist('diffStr') == 1
  if nStructs < 2,
    DAStudio.error('Simulink:blocks:SpecifyAtleast1RunToPlotDiffs');
  end
  
  % Check whether time vectors are all identical
  doInterp = zeros(nStructs,1);
  if ~isempty(data{1}.time)
    for i=2:nStructs,
      if length(data{i}.time) ~= length(data{1}.time)
        doInterp(i) = 1;
      elseif data{i}.time ~= data{1}.time
        doInterp(i) = 1;
      end
      % Produce warning if start and stop times are different.
      if ((data{i}.time(1) == 0) | (data{1}.time(1) == 0)),
        if (data{i}.time(1) - data{1}.time(1))^2 > eps,
          DAStudio.warning('Simulink:blocks:StartTimeDiffBtwnRuns',num2str(i));
        end
      elseif ((data{i}.time(1) - data{1}.time(1))/data{1}.time(1))^2 > eps,
          DAStudio.warning('Simulink:blocks:StartTimeDiffBtwnRuns',num2str(i));
      end
      
      if ((data{i}.time(end) == 0) | (data{1}.time(end) == 0)),
        if (data{i}.time(end) - data{1}.time(end))^2 > eps,
          DAStudio.warning('Simulink:blocks:StopTimeDiffBtwnRuns',num2str(i));
        end
      elseif ((data{i}.time(end) - data{1}.time(end))/data{1}.time(end))^2 > eps,
          DAStudio.warning('Simulink:blocks:StopTimeDiffBtwnRuns',num2str(i));
      end
      
    end
  end
  
  for i=2:nStructs,
    if doInterp(i) == 1; % Do differences with interpolation
      DAStudio.warning('Simulink:blocks:TimeVectorDiffBtwnRuns',num2str(i));
      tMin  = max(data{i}.time(1),   data{1}.time(1));
      tMax  = min(data{i}.time(end), data{1}.time(end));
      tStep = (tMax-tMin)/(max(length(data{i}.time), length(data{1}.time))-1);
      for j=ports,
        tValid = (tMin:tStep:tMax)';
        dataValid =  interp1(data{i}.time, data{i}.signals(j).values, tValid, 'linear');
        data1Valid = interp1(data{1}.time, data{1}.signals(j).values, tValid, 'linear');
        data{i}.signals(j).values = dataValid - data1Valid;
      end
      data{i}.time = tValid;
    else % Do differences without interpolation
      for j=ports,
        data{i}.signals(j).values = data{i}.signals(j).values - data{1}.signals(j).values;
      end
    end
  end
end

% ===========================================================================
% CREATE GRAPHICS
% ===========================================================================
% Set necessary properties to match Simulink Scope.

figColor     = [0.5 0.5 0.5];

axesColor = 'k';
ticColor  = 'w';

axesColorOrder = [1 1 0
                  1 0 1
                  0 1 1
                  1 0 0
                  0 1 0
                  0 0 1];
                

% Set figure properties
hFig         = gcf;
set(hFig, 'Color', figColor, ...        
          'DefaultAxesColor',  axesColor,...
	  'DefaultAxesXColor', ticColor, ...
	  'DefaultAxesYColor', ticColor, ...
	  'DefaultAxesZColor', ticColor, ...
	  'DefaultTextColor',  ticColor);

nAxes        = length(ports);

% Determine which axes need to be reset to "replace" once finished
for i=1:nAxes,
  hAxes(i,1) = subplot(nAxes, 1, i);
  if strcmpi(get(hAxes(i), 'NextPlot'), 'replace')
    cla;
  end
end
axesToClear = findobj(hFig, 'Type', 'Axes', 'NextPlot', 'replace');

% Set axis properties
set(hAxes, 'NextPlot',         'add', ...
           'XGrid',            'on', ...
           'YGrid',            'on', ...
           'Color',            axesColor, ...
           'ColorOrder',       axesColorOrder, ...
           'XColor',           ticColor, ...
           'YColor',           ticColor, ...
           'Box',              'on', ...
           'View',             [0 90]);
                
% Create the plots.
if ~(exist('diffStr')==1),
  for i=1:nStructs,
    i_PlotScopeStruct(data{i}, ports, i);
  end
else,
  for i=2:nStructs,
    i_PlotScopeStruct(data{i}, ports, i);
  end
end

% Reset axes to initial conditions
set(axesToClear, 'NextPlot', 'replace');


% ===========================================================================
% CREATE RETURN ARGUMENTS.
% ===========================================================================
switch nargout,
case 1,
  varargout = {hFig};
case 2,
  varargout = {hFig, hAxes};
case 3,
  hLines = findobj(gcf, 'Type', 'line');
  varargout = {hFig, hAxes, hLines};
end


% ===========================================================================
% SUB-FUNCTIONS
% ===========================================================================

% ---------------------------------------------------------------------------
% I_PLOTSCOPESTRUCT  Overlay the plots from the specified scope logVar.
% ---------------------------------------------------------------------------
function i_PlotScopeStruct(data, ports, runNo)

nAxes = length(ports);

lineStyles = {'-'
             '-.' 
             '--'
             ':' 
             '.'};
           
if isempty(data.time)
  xString = 'Indices';
  data.time = (1:size(data.signals(1).values, 1))';
else
  xString = 'Time';
end

for i=1:nAxes,
  hAx       = subplot(nAxes, 1, i);
  port      = ports(i);
  nLines    = size(data.signals(port).values, 2);
  hLines    = plot(ones(2,nLines)*NaN, 'LineStyle', lineStyles{rem(runNo-1,length(lineStyles))+1});
  
  if isfield(data.signals(port), 'plotStyle')
    plotStyle = reshape(data.signals(port).plotStyle,1,nLines);
  else
    plotStyle = zeros(1,nLines);
  end  
  
  for j=1:nLines,
    if ~plotStyle(j),
      set(hLines(j), 'Xdata', data.time, 'Ydata', data.signals(port).values(:,j), ...
                     'Tag', ['Run #', num2str(runNo), ' - ', 'data', num2str(j)]);
    else,
      [Xdata, Ydata] = stairs(data.time, data.signals(port).values(:,j));
      set(hLines(j), 'Xdata', Xdata, 'Ydata', Ydata, ...
                     'Tag', ['Run #', num2str(runNo), ' - ', 'data', num2str(j)]);
    end
  end
  
  hTitle = get(hAx, 'Title');
  hYLabel = get(hAx, 'YLabel');
  hXLabel = get(hAx, 'XLabel');
  if isfield(data.signals(port), 'title') & ~isempty(data.signals(port).title)
    set(hTitle, 'String',       data.signals(port).title, ...
                'Color',        get(hAx, 'XColor'), ...
                'Interpreter',  'none');
    set(hYLabel, 'String', '');
    set(hXLabel, 'String', '');
  else
    set(hTitle, 'String', '');
    set(hYLabel, 'String',      data.signals(port).label, ...
                 'Interpreter', 'none');
    set(hXLabel, 'String', '');
  end
end

% Set XLabel for last subplot
set(hXLabel, 'String', xString);
           
% Bring Figure to front
shg;
% END OF SUBFUNCTION

