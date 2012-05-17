function lblstr = getDisplayLabel(h)
%GETDISPLAYLABEL

%   Author(s): G. Taillefer
%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4.2.1 $  $Date: 2010/06/14 14:27:06 $

lblstr = '';
if(isa(h.daobject, 'DAStudio.Object') || isa(h.daobject, 'Simulink.ModelReference'))
    try
        lblstr = h.daobject.getDisplayLabel;
        logstr = getlogstr(h);
        dtostr = getdtostr(h);
        lblstr = getlblstr(lblstr, logstr, dtostr);
    catch e
    end
end
%--------------------------------------------------------------------------
function logstr = getlogstr(h)
logstr = '';
if(~h.isdominantsystem('MinMaxOverflowLogging'))
    return;
end
logvalue = h.daobject.MinMaxOverflowLogging;
% Use a switchyard instead of ismember() to improve performance.
switch logvalue
  case 'UseLocalSettings'
    logstr = '';
  case 'MinMaxAndOverflow'
    logstr = 'mmo'; 
  case 'OverflowOnly'
    logstr = 'o'; 
  case 'ForceOff'
    logstr = 'fo'; 
  otherwise
    %do nothing;
end

%--------------------------------------------------------------------------
function dtostr = getdtostr(h)
dtostr = '';
if(~h.isdominantsystem('DataTypeOverride'))
    return;
end
dtovalue = h.daobject.DataTypeOverride;
% Use a switchyard instead of ismember() to improve performance.
switch dtovalue
  case 'UseLocalSettings'
    dtostr = '';
  case {'ScaledDoubles', 'ScaledDouble'}
    dtostr = 'scl'; 
  case {'TrueDoubles', 'Double'}
    dtostr = 'dbl'; 
  case {'TrueSingles', 'Single'}
    dtostr = 'sgl'; 
  case {'ForceOff', 'Off'}
    dtostr = 'off';
  otherwise
    %do nothing;
end

%--------------------------------------------------------------------------
function lblstr = getlblstr(lblstr, logstr, dtostr)
if(isempty(logstr) && isempty(dtostr))
    return;
end
dash = '';
lblstr = [lblstr ' (' logstr];
if(~isempty(dtostr))
    if(~isempty(logstr))
        dash = '-';
    end
    %append the dto string to the label
    lblstr = [lblstr dash dtostr];
end
lblstr = [lblstr ')'];

% [EOF]
