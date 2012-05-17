classdef Workspace < handle
  % Named workspace for custom data storage.
  
  % Author(s): Bora Eryilmaz
  % Revised:
  % Copyright 2009 The MathWorks, Inc.
  % $Revision: 1.1.8.1 $ $Date: 2009/12/22 18:57:36 $
  
  % ----------------------------------------------------------------------------
  properties (Dependent, GetAccess = public, SetAccess = private)
    % Workspace name (read-only string, default = '')
    Name
  end
  
  properties (Dependent, Access = public)
    % Workspace data (any MATLAB data type, default = []).
    Data
  end
  
  properties (Access = protected)
    % Version
    Version = toolpack.ver();
  end
  
  properties (Access = private)
    % Any MATLAB data type.
    Data_
    % String or [] for default value ''.
    Name_
  end
  
  % ----------------------------------------------------------------------------
  methods (Access = public)
    function this = Workspace(name)
      % Creates a named workspace.
      %
      % Example: obj = toolpack.Workspace('my_wkspc')
      if nargin < 1
        % Default argument
        name = '';
      end
      this.Name = name;
    end
  end
  
  % ----------------------------------------------------------------------------
  methods
    function value = get.Data(this)
      % GET function for Data property.
      value = this.Data_;
    end
    
    function set.Data(this, value)
      % SET function for Data property.
      this.Data_ = value;
    end
    
    function value = get.Name(this)
      % GET function for Name property.
      value = this.Name_;
      if isempty(value)
        value = ''; % default
      end
    end
    
    function set.Name(this, value)
      % SET function for Name property.
      if isempty(value)
        value = [];
      else
        if ~ischar(value)
          ctrlMsgUtils.error('Controllib:toolpack:StringArgumentNeeded')
        elseif ~isvarname(value)
          ctrlMsgUtils.error('Controllib:toolpack:ArgumentNotVariableName', value)
        end
      end
      this.Name_ = value;
    end
  end
end
