function s = loadPreferences(this) %#ok<*INUSD>
% LOADPREFERENCES loads default settings for PID tuner

% Author(s): R. Chen
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:21:42 $

%%
h = cstprefs.tbxprefs;
s = h.PIDTunerPreferences;
                

        
