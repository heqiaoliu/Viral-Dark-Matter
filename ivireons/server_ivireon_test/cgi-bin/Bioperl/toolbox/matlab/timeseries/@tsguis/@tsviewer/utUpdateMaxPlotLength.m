function utUpdateMaxPlotLength(h)

% Copyright 2005 The MathWorks, Inc.

import com.mathworks.toolbox.timeseries.*;
import com.mathworks.services.*;

% Initialize MaxPlotLength from java Prefs
if Prefs.exists(tsPrefsPanel.PROPKEY_LARGETSOPEN)
   thisLength = Prefs.getIntegerPref(tsPrefsPanel.PROPKEY_LARGETSLEN);
else % If Prefs has not been initialized, default max length is 5000
   thisLength = 5000;
end

% Set java Prefs
Prefs.setIntegerPref(tsPrefsPanel.PROPKEY_LARGETSLEN,thisLength);

% Set udd
h.MaxPlotLength = thisLength;