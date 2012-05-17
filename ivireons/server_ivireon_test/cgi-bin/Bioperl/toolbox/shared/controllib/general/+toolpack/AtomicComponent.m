classdef AtomicComponent < handle
  % Abstract base class for atomic tool components.  Atomic tool components can
  % be combined to construct composite tool components.  However, they cannot
  % themselves be composite.
  
  % Author(s): Bora Eryilmaz
  % Revised:
  % Copyright 2009 The MathWorks, Inc.
  % $Revision: 1.1.8.2 $ $Date: 2010/01/25 22:35:54 $
  
  % ----------------------------------------------------------------------------
  properties (Dependent, Access = protected)
    % Component data (structure, default = struct with no field).
    Database
    % Uncommitted data changes (structure, default = struct with no field).
    ChangeSet
  end
  
  properties (Access = protected)
    % Version
    Version = toolpack.ver();
  end
  
  properties (Access = private)
    % Workspace object handle (acts as private data for Database property).
    Workspace_
    % Structure or [] for default value struct.
    ChangeSet_
    % Logical. Set to true upon component initialization.
    Initialized = false;
  end
  
  % ----------------------------------------------------------------------------
  events
    % Event sent upon component change.  Event data is passed using a
    % ComponentEventData object.
    ComponentChanged
  end
    
  % ----------------------------------------------------------------------------
  % User-defined methods
  methods (Access = protected)
    function mCheckConsistency(this)
      % Check component data consistency.  Error out if changes are inconsistent
      % with the current state of the component.
    end
    
    function mStart(this)
      % Perform initial setup and one-time-only calculations.  Assign model
      % parameters.
    end
    
    function mReset(this)
      % Reset all independent variables and current state to their default
      % values.
    end
    
    function mUpdate(this)
      % Compute next state from current state and independent variables.
    end
    
    function mOutput(this)
      % Compute stored outputs from current state and independent variables.
    end
    
    function state = mGetState(this)
      % Return the state of the component (structure or [] for default value
      % struct).
      state = [];
    end
    
    function mSetState(this, state)
      % Set the current state by passing a struct argument.
    end
    
    function props = getIndependentVariables(this)
      % Return list of independent variable names.
      props = {};
    end
  end
  
  % ----------------------------------------------------------------------------
  methods
    function this = AtomicComponent(varargin)
      % Constructor.
      %
      % Subclasses should call
      %   obj = obj@toolpack.AtomicComponent( varargin{:} )
      if nargin < 1
        % Default argument
        wksp = toolpack.Workspace;
      else
        wksp = varargin{1};
      end
      this.setWorkspace(wksp);
    end
  end
  
  % ----------------------------------------------------------------------------
  % Component state management
  methods (Sealed)
    function reset(this)
      % Resets the component to its default state if it has been already
      % initialized.
      if this.Initialized;
        mReset(this)
      else
        % No effect on uninitialized components.
        ctrlMsgUtils.warning('Controllib:toolpack:UninitializedComponent')
      end
    end
    
    function setup(this)
      % Configures the component for the first time.
      if ~this.Initialized
        mStart(this);
        mReset(this)
        this.Initialized = true;
      else
        % No effect on initialized components.
        ctrlMsgUtils.warning('Controllib:toolpack:InitializedComponent')
      end
    end
    
    function this = output(this)
      % Updates the component outputs.
      
      % Initialize the component if it has not been initialized before.
      if ~this.Initialized
        setup(this)
      end
      
      % Use state and input (if direct feedthrough) values to calculate (or
      % clear) stored output values.
      mOutput(this)
    end
    
    function this = update(this)
      % Updates the component state and compute outputs.
      
      % Initialize the component if it has not been initialized before.
      if ~this.Initialized
        setup(this)
      end
      
      % Check joint property consistency.
      try
        mCheckConsistency(this)
      catch E
        throwAsCaller(E)
      end
      
      % Update component state.
      mUpdate(this)
      
      % Use state and input (if direct feedthrough) values to calculate (or
      % clear) stored output values.
      mOutput(this)
      
      % Component is now up-to-date.
      this.ChangeSet = [];
      notify(this, 'ComponentChanged', toolpack.ComponentEventData(''))
    end
  
    function state = getState(this)
      % Get the current state.
      if this.Initialized
        state = mGetState(this);
        if isempty(state)
          state = struct; % default
        end
      else
        % No effect on uninitialized components.
        ctrlMsgUtils.warning('Controllib:toolpack:UninitializedComponent')
        state = struct;
      end
    end
    
    function setState(this, state)
      % Set the current state.
      if this.Initialized
        mSetState(this, state)
      else
        % No effect on uninitialized components.
        ctrlMsgUtils.warning('Controllib:toolpack:UninitializedComponent')
      end
    end
  end
  
  % ----------------------------------------------------------------------------
  % Component data management
  methods (Sealed)
    function wksp = getWorkspace(this)
      % Return Workspace.
      wksp = this.Workspace_;
    end
    
    function setWorkspace(this, wksp)
      % Replace Workspace.  Overwrites existing data.
      this.Workspace_ = wksp;
    end
    
    function wksp_old = switchWorkspace(this, wksp_new)
      % Assign a new workspace while keeping existing data.
      wksp_old = this.getWorkspace;
      data = this.Database; % current data
      this.setWorkspace(wksp_new);
      % Restore existing data in new workspace.
      this.Database = data;
    end
  end
  
  methods
    function value = get.ChangeSet(this)
      % GET function for ChangeSet property.
      value = this.ChangeSet_;
      if isempty(value)
        value = struct; % default
      end
    end
    
    function set.ChangeSet(this, value)
      % SET function for ChangeSet property.
      if isempty(value)
        value = [];
      else
        if isstruct(value)
          props = this.getIndependentVariables;
          fields = fieldnames(value);
          idxs = ismember(fields, props);
          if ~all( idxs )
            fname = fields(idxs==0);
            ctrlMsgUtils.error('Controllib:toolpack:NotAnIndependentProperty', fname{1})
          end
        else
          ctrlMsgUtils.error('Controllib:toolpack:InvalidPropertyValue', 'ChangeSet')
        end
      end
      this.ChangeSet_ = value;
    end
    
    function value = get.Database(this)
      % GET function for Database property.
      value = this.Workspace_.Data;
      if isempty(value)
        value = struct; % default
      end
    end
    
    function set.Database(this, value)
      % SET function for Database property.
      if isempty(value)
        value = [];
      elseif ~isstruct(value)
        ctrlMsgUtils.error('Controllib:toolpack:InvalidPropertyValue', 'Database')
      end
      this.Workspace_.Data = value;
    end
    
    function set.Workspace_(this, wksp)
      % Set function for Workspace_ property.
      if ~(isempty(wksp) || isa(wksp, 'toolpack.Workspace'))
        ctrlMsgUtils.error('Controllib:toolpack:InvalidWorkspaceArgument')
      end
      this.Workspace_ = wksp;
    end
  end
  
  % ----------------------------------------------------------------------------
  % Serialization support
  methods
    function S = saveobj(obj)
      S.Version = obj.Version;
      S.Workspace_ = obj.Workspace_;
      % Unapplied data in obj.ChangeSet_ are not saved.
      S.Initialized = obj.Initialized;
    end
    
    function obj = reload(obj, S)
      obj.Version = S.Version;
      obj.Workspace_ = S.Workspace_;
      % Data in obj.ChangeSet_ is not modified from struct S.
      obj.Initialized = S.Initialized;
    end
  end
end
