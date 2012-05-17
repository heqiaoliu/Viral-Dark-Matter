function s = loadPreferences(this) %#ok<*INUSD>
% LOADPREFERENCES loads default settings for PID tuner

% Author(s): R. Chen
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2010/03/26 17:54:04 $

h = cstprefs.tbxprefs;
s = h.PIDTunerPreferences;
% backward compatibility
if ~isnumeric(s.TunedColor)
    s.TunedColor = [s.TunedColor.getRed/256 s.TunedColor.getGreen/256 s.TunedColor.getBlue/256];
end
if ~isnumeric(s.BlockColor)
    s.BlockColor = [s.BlockColor.getRed/256 s.BlockColor.getGreen/256 s.BlockColor.getBlue/256];
end
