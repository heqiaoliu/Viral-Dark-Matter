classdef (ConstructOnLoad) ComponentEventData < event.EventData
  % Event data associated with ComponentChanged events.
  
  % Author(s): Bora Eryilmaz
  % Revised:
  % Copyright 2009 The MathWorks, Inc.
  % $Revision: 1.1.8.1 $ $Date: 2009/12/22 18:57:35 $
  
  % ----------------------------------------------------------------------------
  properties (Dependent, GetAccess = public, SetAccess = private)
    % Describes what has changed (read-only string, default = '').
    ChangeName
  end
  
  properties (Access = protected)
    % Version
    Version = toolpack.ver();
  end
  
  properties (Access = private)
    % String or [] for default value ''.
    ChangeName_
  end
  
  % ----------------------------------------------------------------------------
  methods
    function this = ComponentEventData(name)
      % Creates an event data object describing the component change.
      %
      % Example: obj = toolpack.ComponentEventData('xlimits')
      if nargin < 1
        % Default argument
        name = '';
      end
      this.ChangeName = name;
    end
  end
  
  % ----------------------------------------------------------------------------
  methods
    function value = get.ChangeName(this)
      % GET function for ChangeName property.
      value = this.ChangeName_;
      if isempty(value)
        value = ''; % default
      end
    end
    
    function set.ChangeName(this, value)
      % SET function for ChangeName property.
      if isempty(value)
        value = [];
      else
        if ~ischar(value)
          ctrlMsgUtils.error('Controllib:toolpack:StringArgumentNeeded')
        end
      end
      this.ChangeName_ = value;
    end
  end
end
