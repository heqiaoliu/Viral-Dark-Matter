function sys = chgunits(sys,newUnits,conv)
%CHGUNITS  Change frequency units of an IDFRD model.
%
%   SYS = CHGUNITS(SYS,UNITS) changes the units of the frequency
%   points stored in the IDFRD model SYS to UNITS. New units should be one
%   of: 'rad/TimeUnit', '1/TimeUnit', 'cycle/TimeUnit' or 'Hz', where
%   TimeUnit refers to a single-line string representing the time unit (for
%   example, in 'rad/hour', the unit of time is 'hour').
%
%   The default change is between angular frequency (rad/TimeUnit) and
%   cycles per TimeUnit (Hz, 1/TimeUnit or cycles/TimeUnit). A 2*pi scaling
%   factor is applied to the frequency values and the 'Units' property is
%   updated. If the 'Units' field already matches UNITS, no action is taken.
%
%   SYS = CHGUNITS(SYS,UNITS,CONV) allows more general conversion, letting
%   the frequencies be multiplied by CONV. Example: Suppose SYS has
%   frequency unit rad/sec, which should be changed to rad/min. Then apply
%   SYS = CHGUNITS(SYS,'rad/min',60).
%
%   See also IDFRD/SET, IDFRD/GET, SPA, ETFE, IDDATA/FFT.

%       Author: L. Ljung
%       Copyright 1986-2008 The MathWorks, Inc.
%       $Revision: 1.5.2.5 $  $Date: 2008/10/02 18:47:15 $

if nargin<3
    conv=2*pi;
else
    sys.Units = newUnits;
    sys.Frequency = sys.Frequency * conv;
    return
end
if ~ischar(newUnits)
    ctrlMsgUtils.error('Ident:transformation:chgunitsCheck1')
elseif ~strncmpi(sys.Units,newUnits,1)
    if strncmpi(newUnits,'h',1)
        sys.Units = 'Hz';
        sys.Frequency = sys.Frequency /conv;
    elseif strncmpi(newUnits,'1',1) || strncmpi(newUnits,'c',1)
        sys.Units = newUnits;
        sys.Frequency = sys.Frequency /conv;
    elseif strncmpi(newUnits,'r',1)
        sys.Units = newUnits;
        sys.Frequency = sys.Frequency * conv;
    else
        ctrlMsgUtils.error('Ident:transformation:chgunitsCheck2')
    end
end

