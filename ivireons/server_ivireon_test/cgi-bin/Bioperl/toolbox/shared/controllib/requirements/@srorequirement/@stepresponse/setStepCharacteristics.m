function OK = setStepCharacteristics(this,StepChar)
% SETSTEPCHARACTERISTICS  method to set constraint segments based on step
% characteristics like overshoot, rise time etc.
%
% this.setStepCharacteristics(StepChar)
% 
% Inputs: 
% StepChar an optional structure with fields:
%           InitialValue
%           FinalValue
%           StepTime
%           RiseTime
%           PercentRise
%           SettlingTime
%           PercentSettling
%           PercentOvershoot
%           PercentUndershoot
% If omitted the values in the object are used
%
% Outputs:
%   OK - a logical indicating that the characteristics were successfully
%   translated into constraint segments

% Author(s): A. Stothert 07-Jan-2009
% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:37:16 $

if nargin == 2
    %Passed structure with field values, use to update the characteristics.
    %Later we use the characteristics to update the constraint edges.
    flds = {'InitialValue','FinalValue','StepTime','RiseTime','PercentRise', ...
        'SettlingTime','PercentSettling','PercentOvershoot','PercentUndershoot'};
    for ct = 1:numel(flds)
        fld = flds{ct};
        if isfield(StepChar,fld)
            this.(fld) = getfield(StepChar,fld);
        end
    end
end

%Extract data
u0 = this.InitialValue;
uf = this.FinalValue;
T0 = this.StepTime;
Tr = this.RiseTime;
Ts = this.SettlingTime;
pR = this.PercentRise/100;
pS = this.PercentSettling/100;
pO = this.PercentOvershoot/100;
pU = this.PercentUndershoot/100;

%Error check characteristics
bOK = (T0<Tr) && (Tr<Ts);
bOK = bOK && (pS<=pO);       %Settling less than overshoot
bOK = bOK && (pR <= 1-pS);  %Rise less than settling
bOK = bOK && (pU >= 0) && (pS >=0) && (pO >= 0) && (pR >= 0);
if nargout > 0, OK = bOK; end
if ~bOK
   %Quick exit, don't update
   return
end

%'Upperbound'
xU = [...
   T0, Ts; ...
   Ts, Ts*(1+0.5*sign(Ts))];
yU = [ ...
   uf+(uf-u0)*pO, uf+(uf-u0)*pO; ...
   uf+(uf-u0)*pS, uf+(uf-u0)*pS];
%'Lowerbound'
xL = [ ...
   T0, Tr; ...
   Tr, Ts; ...
   Ts, Ts*(1+0.5*sign(Ts))];
yL = [ ...
   u0-(uf-u0)*pU, u0-(uf-u0)*pU; ...
   u0+(uf-u0)*pR, u0+(uf-u0)*pR; ...
   uf-(uf-u0)*pS, uf-(uf-u0)*pS];

%Set requirement characteristics
%set(this.Listeners,'Enable','off');
this.setData('xData',[xU; xL],'yData',[yU; yL]);
%set(this.Listeners,'Enable','on');