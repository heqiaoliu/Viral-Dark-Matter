function sys = chgunits(sys,newUnits)
%CHGUNITS  Change frequency units of a frequency domain IDDATA set.
%
%   DAT = CHGUNITS(DAT,UNITS) changes the units of the frequency
%   points stored in the IDDATA set DAT to UNITS, where UNITS
%   is either 'Hz or 'rad/<TimeUnit>'.  A 2*pi scaling factor is applied
%   to the frequency values and the 'Units' property is updated.
%   If the 'Units' field already matches UNITS, no action is taken.
%  
%   For Multiexperiment data UNITS should be a cell array of length
%   equal to the number of experiments. If 'Hz' or 'rad/s' is entered,
%   the same unit change is applied to all experiments.
%
%   See also IDFRD, FFT, IFFT.

%       Copyright 1986-2009 The MathWorks, Inc.
%       $Revision: 1.2.4.6 $  $Date: 2009/04/21 03:22:05 $

if strcmpi(sys.Domain,'time')
    ctrlMsgUtils.error('Ident:dataprocess:chgunitsTimeData')
end

Nexp = size(sys,'Ne');
if ischar(newUnits)
    newUnits = repmat({newUnits},1,Nexp);
end
tu = pvget(sys,'TimeUnit');

for kexp = 1:Nexp
    if ~strncmpi(sys.Tstart{kexp},newUnits{kexp},1)
        if strncmpi(newUnits{kexp},'h',1)
            sys.Tstart{kexp} = 'Hz';
            sys.SamplingInstants{kexp} = sys.SamplingInstants{kexp}/ (2*pi);
        elseif strncmpi(newUnits{kexp},'r',1)
            sys.Tstart{kexp} = sprintf('rad/%s',tu{kexp});
            sys.SamplingInstants{kexp} = sys.SamplingInstants{kexp} * (2*pi);
        else
            ctrlMsgUtils.error('Ident:dataprocess:chgunitsCheck2');
        end
    end
end

