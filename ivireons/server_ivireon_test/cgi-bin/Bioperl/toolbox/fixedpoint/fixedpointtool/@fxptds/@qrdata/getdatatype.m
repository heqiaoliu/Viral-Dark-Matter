function [simdt, specdt, dt_max, dt_min, blkstatus] = getdatatype(s)
%GETDATATYPE   Get the datatype.

%   Author(s): G. Taillefer
%   Copyright 2006-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/11/17 21:49:04 $

simdt = '';
specdt = '';
blkstatus = '';
dt_min = [];
dt_max = [];
if(isa(s, 'fxptui.abstractresult'))
  s = struct(s);
end
if(isfield(s, 'SignedSpecified') && isfield(s, 'WordLengthSpecified'))
  specdt = fixdt(fixdt(s.SignedSpecified, s.WordLengthSpecified));
end

% if(isfield(s, 'DataTypeName'))
%   specdt = fixdt(fixdt(s.DataTypeName));
% end

if isfield(s,'DataTypeName') || isfield(s,'DataType')
  if ~isfield(s,'DataTypeName')
    s = SimulinkFixedPoint.Legacy.appendFixPtSimRangeDataTypeName(s);
  end
  simdt = s.DataTypeName;
  switch simdt
    case { 'double','single','boolean' }
      % do nothing
    otherwise
      [DataTypeObj,IsScaledDouble] = fixdt( simdt );
      simdt = fixdt(DataTypeObj);
      if IsScaledDouble
        %
        % XXX andyb 25 April 2006
        % ask Tom Bryan if a constructor for scaled doubles already
        % exists
        simdt = ['Scaled Double of ' simdt];
      end
      if SimulinkFixedPoint.DataType.isFixedPointType(DataTypeObj)
        [dt_min,dt_max] = ...
          SimulinkFixedPoint.DataType.getFixedPointRepMinMaxRwvInDouble(DataTypeObj);
      end
  end

  if(isfield(s, 'MinValue') && isfield(s, 'MinValue'))
    if s.MinValue > s.MaxValue
      blkstatus = 'Did Not Execute';
    elseif s.MinValue == s.MaxValue
      blkstatus = 'Static';
    end
  end
  if(isfield(s, 'SimMin') && isfield(s, 'SimMax'))
    if s.SimMin > s.SimMax
      blkstatus = 'Did Not Execute';
    elseif s.SimMin == s.SimMax
      blkstatus = 'Static';
    end
  end

end

% [EOF]
