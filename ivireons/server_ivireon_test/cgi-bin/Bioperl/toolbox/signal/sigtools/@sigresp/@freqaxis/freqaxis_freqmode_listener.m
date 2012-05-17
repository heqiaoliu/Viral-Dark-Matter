function freqaxis_freqmode_listener(this, eventData)
%FREQAXIS_FREQMODE_LISTENER   

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:28:52 $

units = getsettings(getparameter(this, 'freqmode'), eventData);

% normstr = 'pi rad/sample';

if strcmpi(units, 'on')
    
    % If the parameter isn't already disabled, make sure that we cache the
    % current value and put up "pi rad/sample".
    if disableparameter(this, 'frequnits'),
%         hdlg = getcomponent(this, '-class', 'siggui.parameterdlg');
%         if isempty(hdlg),
%             val = get(this, 'FrequencyUnits');
%         else
%             val = getvaluesfromgui(hdlg, 'frequnits');
%         end
%         set(this, 'CachedFrequencyUnits', val);
        
%         % Set this information without sending any external events.
%         setvalue(getparameter(this, 'frequnits'), normstr, 'noevent');
    end
else
    if enableparameter(this, 'frequnits'),
%         setvalue(getparameter(this, 'frequnits'), get(this, 'CachedFrequencyUnits'), 'noevent');
    end
end

% [EOF]
