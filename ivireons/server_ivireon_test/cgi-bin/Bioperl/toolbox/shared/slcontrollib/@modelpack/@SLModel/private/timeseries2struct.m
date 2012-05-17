function stdata = timeseries2struct(this, tsdata)
% TIMESERIES2STRUCT Creates a cell array of structures corresponding to the
% input data used when simulating the model.
%
% This format consists of a separate structure-with-time for each port.  Each
% port's input data structure has only one signals field.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2007/11/09 21:01:12 $

% Get the names of the current inport blocks
model  = this.getName;
inputs = this.getInputs;

% Create empty output structures.
stdata    = cell(1, length(inputs));
signals   = struct('values', [], 'dimensions', [], 'label', [], 'blockName', []);
stdata(:) = { struct('time', [], 'signals', signals) };

% Construct the I/O signals
for ct = 1:length(tsdata)
  h   = tsdata{ct};
  ID  = this.findInput(h.Name);

  if ~isempty(ID)
    idx = find( ID == inputs );
    if length(idx) > 1
      ctrlMsgUtils.error( 'SLControllib:modelpack:MultipleDataSetAssignment', h.Name );
    end
  else
    % Didn't find the corresponding input port id.
    idx = ct;
  end

  if ~isempty(idx)
    % Get input data from timeseries.
    h = tsdata{idx};
    time   = h.Time;
    values = h.Data;
    % dims   = getdatasamplesize(h);
    dims   = ID.getDimensions;
  else
    % No data for this port.
    time   = [];
    values = [];
    dims   = ID.getDimensions;

    % Top level input ports cannot inherit port dimensions
    if dims == -1
      dims = 1;
    end
  end

  % Set data structure
  stdata{ct}.time = time;
  stdata{ct}.signals.values     = values;
  stdata{ct}.signals.dimensions = dims;
  stdata{ct}.signals.label      = ID.getName;
  stdata{ct}.signals.blockName  = [model '/' ID.getFullName];

  % Initialize to zero if no data is specified
  if isempty(time) || isempty(values)
    stdata{ct}.time = 0;
    if length(dims) > 1
      stdata{ct}.signals.values = zeros(dims);
    else
      stdata{ct}.signals.values = zeros([1 dims]);
    end
  end
end
