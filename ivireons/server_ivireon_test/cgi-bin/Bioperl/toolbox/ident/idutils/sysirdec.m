function [sys, sysname, PlotStyle, T, Tdata, Tsdemand] = sysirdec(na, Imp, varargin)
%SYSIRDEC  Decodes the input list for IMPULSE and STEP.
%Imp: 0 for impulse and 1 for step

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.10.4.8 $  $Date: 2009/11/09 16:23:47 $

if Imp==0
    command = 'impulse';
else
    command = 'step';
end

% Basic initializations.
ni = length(varargin);
newarg = [];
inpn = [];
T = [];
Tdata = [];
Tsdemand = [];

% First find desired time span, if specified. That is a double, not
% preceded by 'pw' or 'sd'.
for j = 1:ni
    if isa(varargin{j}, 'double')
        if (j == 1)
            ctrlMsgUtils.error('Ident:utility:sysirdec1',command)
        end
        tst = varargin{j-1};
        if ~(ischar(tst) && (strcmpi(tst, 'pw') || strcmpi(tst, 'sd')))
            T = varargin{j};
        end
    end
end

% Parse input list.
for j = 1:ni
    if isa(varargin{j}, 'lti')
        newarg = [newarg {idss(varargin{j})}];
        inpn = [inpn {inputname(j+1)}];
    elseif (isa(varargin{j}, 'frd') || isa(varargin{j}, 'idfrd'))
        varargin{j}=iddata(idfrd(varargin{j}));
        % error('Frequency responses cannot be used in IMPULSE  and STEP.')
        model = impulse(varargin{j}, 'pw', na, T);
        ut = pvget(model, 'Utility');
        Tdata = ut.impulse.time;
        newarg = [newarg {model}];
        inpn = [inpn {inputname(j+1)}];
    elseif isa(varargin{j}, 'iddata');
        model = impulse(varargin{j}, 'pw', na, T);
        ut = pvget(model, 'Utility');
        Tdata = ut.impulse.time;
        newarg = [newarg {model}];
        inpn = [inpn {inputname(j+1)}];
    else
        newarg = [newarg varargin(j)];
        inpn = [inpn {inputname(j+1)}];
    end
end
varargin = newarg;
ni = length(varargin);
inputname1 = inpn;
nsys = 0;      % Counts LTI systems.
nstr = 0;      % Counts plot style strings.
sys = cell(1, ni);
sysname = cell(1, ni);
PlotStyle = cell(1, ni);
lastsyst = 0;
lastplot = 0;

for j = 1:ni
    argj = varargin{j};
    if (isa(argj, 'idmodel') || isa(argj, 'idnlmodel'))
        if ~isempty(argj)
            if (isa(argj, 'idmodel') && (isaimp(argj)))
                ut = pvget(argj, 'Utility');
                Tdata = ut.impulse.time;
            end
            if isnan(argj)
                if strcmp(command,'step')
                    ctrlMsgUtils.warning('Ident:utility:sysirdec2a')
                else
                    ctrlMsgUtils.warning('Ident:utility:sysirdec2b')
                end
                lastsyst = j;
            else
                nsys = nsys+1;
                sys{nsys} = argj;
                sysname{nsys} = inputname1{j};
                lastsyst = j;
            end
        end
    elseif (isa(argj, 'char') && (j > 1) && (isa(varargin{j-1}, 'idmodel') || isa(varargin{j-1}, 'idnlmodel')))
        % if ~any(strcmp(lower(argj(1)),{'s','a','p'})) % to cut off a/p and 'same'
        nstr = nstr+1;
        PlotStyle{nsys} = argj;
        lastplot = j;
        % end
    end
end

if (lastplot == lastsyst+1)
    lastsyst = lastsyst+1;
end
kk = 1;
newarg = [];
if (ni > lastsyst)
    for j = lastsyst+1:ni
        newarg{kk}= varargin{j};
        kk = kk+1;
    end
else
    newarg = {};
end
sys = sys(1:nsys);
sysname = sysname(1:nsys);
PlotStyle = PlotStyle(1:nsys);

% Now dissect newarg.
if (length(newarg) > 1)
    ctrlMsgUtils.error('Ident:general:InvalidSyntax',command,['idmodel/',command])
elseif (length(newarg) == 1)
    T = newarg{1};
    if ~isa(T,'double') || (ndims(T) ~= 2) || any(~isfinite(T)) || ~isreal(T)
        ctrlMsgUtils.error('Ident:utility:sysirdec3',command)
    elseif (length(T) > 2)
        Tsdemand = T(2)-T(1);
        if ~all(abs(diff(T)-Tsdemand)<Tsdemand/1000)
            ctrlMsgUtils.error('Ident:utility:sysirdec4')
        end
    end
else
    T = [];
end