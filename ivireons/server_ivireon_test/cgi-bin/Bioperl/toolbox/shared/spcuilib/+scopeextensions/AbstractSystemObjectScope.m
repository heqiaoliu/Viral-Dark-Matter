classdef AbstractSystemObjectScope < matlab.system.API
%AbstractSystemObjectScope   Define the AbstractSystemObjectScope

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2010/05/20 03:07:32 $
  
  properties (Abstract)
    Name;
  end
  
  properties(Dependent)
    %Position Scope window position in pixels
    %   Specify the size and location of the scope window in pixels, as a
    %   four-element double vector of the form: [left bottom width height].
    %   The default value of this property is dependent on the screen
    %   resolution, and is such that the window is positioned in the center
    %   of the screen, with a width and height of 410 and 300 pixels
    %   respectively. This property is tunable.
    Position;
  end
  
  properties(Dependent,Hidden)
    %WindowPosition Size and position of the scope window in pixels
    %   This property has been deprecated. Please use the Position property
    %   instead.
    WindowPosition;
  end
  
  properties(Access=protected)
    pPosition = uiscopes.getDefaultPosition;
  end
  
  properties (Access=protected, Transient)
    pFramework;
    pSource;
  end
  
  methods
    
    function this = AbstractSystemObjectScope(varargin)
      %AbstractSystemObjectScope   Construct the AbstractSystemObjectScope class.
      this@matlab.system.API(varargin);
      
      launchScope(this);
      setScopeName(this, this.Name);
      
      % Add empty data message
      emptyScreenMsg = {['Data is available only after you call the ', ...
        'step method on the ', this.getDescription, ' System object.']};
      screenMsg(this.pFramework, emptyScreenMsg);
      
      if ~isempty(this.Position)
        set(this.pFramework.Parent, 'Position', this.Position);
      end
    end
    
    function show(this)
      %show    Show scope window
      %   SHOW(H) turns on the visibility of the scope window associated
      %   with the System object H.
      
      % If user deleted (via call to close all force) the GUI, we
      % need to create a new application
      if ~isScopeLaunched(this)
        launchScope(this);
      end
      this.pSource.SystemObject = this;
      visible(this.pFramework, 'on');
      drawnow;
    end
    
    function hide(this)
      %hide    Hide scope window
      %   HIDE(H) turns off the visibility of the scope window associated
      %   with the System object H.
      hScope = getFramework(this);
      visible(hScope, 'Off');
      this.pSource.SystemObject = [];
    end
  
    function delete(this)
      % Delete the Framework.
      hScope = getFramework(this);
      % The destructor might be called in the process of deleting the
      % figure. Check if we still have a valid figure handle before
      % shutting down the scope.
      if isScopeLaunched(this) && isa(getGUI(hScope), 'uimgr.uifigure')
        close(hScope);
      end
      delete@matlab.system.API(this);
    end

    function set.Position(this, value)
      if ~isnumeric(value)  || ~all(isfinite(value)) || ...
          ~isequal(size(value), [1 4])
        error('matlab:system:SystemObjectScope:invalidPosition', ...
          'Position must be a finite numeric vector of format: [left bottom width height]');
      end
      if isScopeLaunched(this)
        set(this.pFramework.Parent, 'Position', value);
      else
        this.pPosition = value;
      end
    end
    
    function value = get.Position(this)
      if isScopeLaunched(this)
        value = get(this.pFramework.Parent, 'Position');
      else
        value = this.pPosition;
      end
    end
    
    % same as set.Position
    function set.WindowPosition(this, value)
      warning('spcuilib:scopeextensions:AbstractSystemObjectScope:notRecommendedProp', ...
        'WindowPosition property is not recommended. Use Position property instead.');
      if ~isnumeric(value) || ~all(isfinite(value)) || ...
          ~isequal(size(value), [1 4])
        error('matlab:system:SystemObjectScope:invalidPosition', ...
          'Position must be a finite numeric vector of format: [left bottom width height]');
      end
      if isScopeLaunched(this)
        set(this.pFramework.Parent, 'Position', value);
      else
        this.pPosition = value;
      end
    end
    
    % same as get.Position
    function value = get.WindowPosition(this)
      warning('spcuilib:scopeextensions:AbstractSystemObjectScope:notRecommendedProp', ...
        'WindowPosition property is not recommended. Use Position property instead.');
      if isScopeLaunched(this)
        value = get(this.pFramework.Parent, 'Position');
      else
        value = this.pPosition;
      end
    end
  end
  
  methods (Access = protected)
    function status = isScopeLaunched(this)
      status = isa(this.pFramework, 'uiscopes.Framework');
    end
    
    function setScopeName(this, value)
      scomputil.validatePropValue(this, value, 'Name', ...
        {'char'}, {'nonsparse'});
      if isScopeLaunched(this)
        set(get(this.pFramework, 'Parent'),'Name',value);
      end
    end
    
    function launchScope(this)
      %launchScope Launch the uiscopes.Framework object.
      
      % Get a new scope configuration object from the subclass.
      hScopeCfg  = getScopeCfg(this);
      position = this.Position;
      if ~isempty(position)
        hScopeCfg.Position = position;
      end
      
      % Construct the scope.
      hFramework = uiscopes.new(hScopeCfg);
      this.pFramework = hFramework;
      this.pSource    = hFramework.getExtInst('Sources', 'Streaming');
      
      %If the system object is in a locked state, it means that it is
      %completely initialized - we are creating a new
      %application. Throw a warning in this case.
      if this.isLocked
        warn_msg = getNewScopeWarningMsg(this);
        backtrace_state = warning('query','backtrace');
        warning('backtrace','off');
        warning('matlab:system:SystemObjectScope:newScopeWarning',...
          warn_msg);
        warning(backtrace_state);
        % Notify the source of the default data so that it can
        % initialize itself and preallocate the data buffer.
        this.pSource.SystemObject = this;
        start(this.pSource);
      else
        % If not yet initialized, add empty data message
        emptyScreenMsg = {['Data is available only after you call the ', ...
          'step method on the ', this.getDescription, ' System object.']};
        screenMsg(this.pFramework, emptyScreenMsg);
      end
    end
    
    function mUpdate(this, varargin)
      % If the scope does not exist, create one and post new data
      if ~isScopeLaunched(this)
        launchScope(this);
      end
      update(this.pSource, varargin{:});      
    end
    
    function mStart(this)
    % Validate the input - use exemplary input
    % Fixed-point inputs are not currently supported.
    
     % If user closed the GUI, we need to create a new application
      if ~isScopeLaunched(this)
        launchScope(this);
      end

      % We need to do this before calling start on the source because source
      % needs to setup its internals based on the input specs.
      this.pSource.SystemObject = this;
      
      % Notify the source of the default data so that it can initialize
      % itself and preallocate the data buffer.
      start(this.pSource);
      
      %turn on the visibility
      show(this);    
    end
    
    function mRelease(this)
      % If the scope is closed, we don't need to do anything.
      if isScopeLaunched(this)
        release(this.pSource);
      end
    end
    
    function mReset(this)
      % If the scope is closed, we don't need to do anything.
      if isScopeLaunched(this)
        % Reset the video streaming source data handler
        reset(this.pSource);
      end
    end
    
    function props = getTunableProps(this) %#ok<MANU>
      props = {'Position', 'WindowPosition'};
    end
    
    function num = mNumOutputs(this)  %#ok<MANU>
      num = 0;
    end
  end
  
  methods (Hidden)
    % Methods used by the scope source extension
    function inputInfo = getInputInfo(this)
      inputInfo = repmat(struct( ...
        'dataType', {''}, ...
        'size', []), 1, getNumInputs(this));
        
      for indx = 1:getNumInputs(this)
          inputInfo(indx).dataType = getInputDataType(this, indx);
          inputInfo(indx).size     = getInputSize(this, indx);
      end
    end   
    
    function sampleTime = getInputSampleTime(~)
      sampleTime = 1; %ones(getNumInputs(this), 1);
    end
    
    function msg = getNewScopeWarningMsg(this)
      % The NumericType Scope is not documented as a System object,
      % so the message should not contain references to System
      % objects.
      msg = sprintf(['The %s figure and associated data was '...
        'deleted. The System object created a new figure.'],...
        feval([class(this) '.getDescription']));
    end
    
    % Methods used by tests
    function hmply = getFramework(this)
      hmply = this.pFramework;
    end
    function hsrc = getSource(this)
      hsrc = this.pSource;
    end
    function hdh = getDataHandler(this)
      hdh = this.pSource.DataHandler;
    end
  end
  
  methods(Hidden, Static)
    function props = getDisplayProps()
      props = {'Name', 'Position'};%, 'FrameRate'};
    end
    
    function b = generatesCode
      b = false;
    end
  end
  
  methods (Access = protected, Abstract)
    hScopeCfg = getScopeCfg(this)
  end
  
end

% [EOF]
