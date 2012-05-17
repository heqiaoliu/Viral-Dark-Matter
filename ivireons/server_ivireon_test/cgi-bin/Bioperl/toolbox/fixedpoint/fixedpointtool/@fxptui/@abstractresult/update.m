function update(h, runtime, run, data)
%UPDATE   update the data in this result

%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2010/04/05 22:16:51 $

h.Run = fxptui.run2str(run);
h.isVisible = 1;
%set the signal if data has one
if(isfield(data, 'Signal'))
  h.SignalRunTime = runtime;
  h.setsignal(data.Signal);
end

if(~isempty(h.Signal))
  if(h.SignalRunTime ~= runtime)
    h.setsignal([]);
    h.SignalRunTime = 0;
  end
end

if (h.RunTime ~= runtime)
    h.SimDT = '';
    h.SpecifiedDT = '';
    h.SimMin = [];
    h.SimMax = [];
    h.SimDTRange = '';
    h.OvfWrap = [];
    h.OvfSat = [];
    h.ParamSat = [];
    h.DivByZero = [];
    h.ProposedFL = [];
    h.Comments = {};
    h.ReplaceOutDataType = [];
    h.NumericTypeSpecified = [];
    h.ReplacementOutDTName = '';
    h.Owner = '';
    h.Parents = [];
    h.isUnderLibraryLink = [];
    h.isUnderMaskWorkspace = [];
    h.Parameters = [];
    h.dataID = [];
    h.dataName = '';
    h.isStateflow = [];
    h.isSigned = [];
    h.DataType = '';
    h.DataTypeName = '';
    h.Alert = '';
    h.CompiledInputDT  = {};
    h.CompiledOutputDT  = {};
    h.CompiledInputComplex = {};
    h.CompiledOutputComplex = {};
end

h.RunTime = runtime;

if(isfield(data, 'SimDataType'))
  h.SimDT = data.SimDataType;
end

if(isfield(data, 'SpecDataType'))
  h.SpecifiedDT = data.SpecDataType;
end

if(isfield(data, 'MinValue'))
  h.SimMin  = data.MinValue;
end

if(isfield(data, 'MaxValue'))
  h.SimMax = data.MaxValue;
end

if(isfield(data, 'RangeMin') && isfield(data, 'RangeMin'))
  rangestr = fxptui.createrangestring(data.RangeMin, data.RangeMax);
  h.SimDTRange = rangestr;
end

if(isfield(data, 'OverflowOccurred'))
  h.OvfWrap = data.OverflowOccurred;
end

if(isfield(data, 'SaturationOccurred'))
  h.OvfSat = data.SaturationOccurred;
end

if(isfield(data, 'ParameterSaturationOccurred'))
  h.ParamSat = data.ParameterSaturationOccurred;
end

if(isfield(data, 'DivisionByZeroOccurred'))
  h.DivByZero = data.DivisionByZeroOccurred;
end

if(isfield(data, 'FractionLengthProposed'))
  h.ProposedFL = data.FractionLengthProposed;
end

if(isfield(data, 'doScaling'))
  h.Accept = data.doScaling;
end

if(isfield(data, 'scalingComments'))
  h.Comments = data.scalingComments;
end

if(isfield(data, 'ReplaceOutDataType') && ~isempty(data.ReplaceOutDataType))
  h.ReplaceOutDataType = data.ReplaceOutDataType;
end

if(isfield(data, 'ReplacementOutDTName') && ~isempty(data.ReplacementOutDTName))
  h.ReplacementOutDTName = data.ReplacementOutDTName;
end

if(isfield(data, 'Owner') && ~isempty(data.Owner))
  h.Owner = data.Owner;
end

if(isfield(data, 'NumericTypeSpecified') && ~isempty(data.NumericTypeSpecified))
  h.NumericTypeSpecified = data.NumericTypeSpecified;
end

if(isfield(data, 'Parents') && ~isempty(data.Parents))
  h.Parents = data.Parents;
end

if(isfield(data, 'isUnderLibraryLink') && ~isempty(data.isUnderLibraryLink))
  h.isUnderLibraryLink = data.isUnderLibraryLink;
end

if(isfield(data, 'isUnderMaskWorkspace') && ~isempty(data.isUnderMaskWorkspace))
  h.isUnderMaskWorkspace = data.isUnderMaskWorkspace;
end

if(isfield(data, 'Parameters') && ~isempty(data.Parameters))
  h.Parameters = data.Parameters;
end

if(isfield(data, 'dataID') && ~isempty(data.dataID))
  h.dataID = data.dataID;
end

if(isfield(data, 'dataName') && ~isempty(data.dataName))
  h.dataName = data.dataName;
end

if(isfield(data, 'isStateflow') && ~isempty(data.isStateflow))
  h.isStateflow = data.isStateflow;
end

if(isfield(data, 'isSigned') && ~isempty(data.isSigned))
  h.isSigned = data.isSigned;
end

if(isfield(data, 'DataType') && ~isempty(data.DataType))
  h.DataType = data.DataType;
end

if(isfield(data, 'DataTypeName') && ~isempty(data.DataTypeName))
  h.DataTypeName = data.DataTypeName;
end

if(isfield(data, 'Alert') && ~isempty(data.Alert))
  h.Alert = data.Alert;
end

if(isfield(data, 'CompiledInputDT') && ~isempty(data.CompiledInputDT))
  h.CompiledInputDT = data.CompiledInputDT;
end

if(isfield(data, 'CompiledOutputDT') && ~isempty(data.CompiledOutputDT))
  h.CompiledOutputDT = data.CompiledOutputDT;
end

if(isfield(data, 'CompiledInputComplex') && ~isempty(data.CompiledInputComplex))
    h.CompiledInputComplex =  data.CompiledInputComplex;
end

if(isfield(data, 'CompiledOutputComplex') && ~isempty(data.CompiledOutputComplex))
    h.CompiledOutputComplex = data.CompiledOutputComplex;
end

% [EOF]
