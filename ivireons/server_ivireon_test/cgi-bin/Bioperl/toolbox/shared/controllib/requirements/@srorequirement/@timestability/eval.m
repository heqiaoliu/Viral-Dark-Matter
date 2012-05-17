function c = eval(this,Response)
% Evaluates an estimation of the stability of a given signal. Note this
% requirement can be either an objective or constraint.
%
% Inputs:
%          this      - a srorequirement.timestability object.
%          Response  - An nxm vector with the signal to evaluate, the first 
%                      column is the time vector.
% Outputs: 
%          c - a mx1 double giving an estimate of the stability of each
%          signal(s), a zero value indicates a stable signal
 
% Author(s): A. Stothert 06-July-2006
% Copyright 2006-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:37:28 $

c = []; 
if isempty(Response) 
   return 
end

%Measured response
t   = Response(:,1);
idx = t >= this.getData('t0');  %Check stability from this time on 
t   = t(idx);
y   = Response(idx,2:end);
nS  = size(y,2);
c   = nan(nS,1);
for ctS = 1:nS;
   %Perform error estimate
   c(ctS,1) = 100*localErrorStability(this,t,y(:,ctS));
end

%% 
function sc = localErrorStability(this,t,y)

% Compute deviation from steady state asymptote
aSS      = this.getData('steadystatevalue');
absTol   = this.getData('absTol');
isStable = all(abs(y-aSS) < absTol); %Rough check for stability
dy       = (y-aSS).^2;               %Square error

% Scaling factor
Escale = aSS^2;
Escale(Escale==0) = 1;

% Compute energy E(t) of error signal dy
E = cumsum(diff(t).*(dy(1:end-1)+dy(2:end))/2);

% Constraint is E <= Emax where Emax is the max energy of a signal that
% stays within an absTol bound
Emax = sum(diff(t).*(absTol.^2/4));

% Delete points where E=0
idx = find(E>0);
E = E(idx);
t = t(1+idx);

% Fit linear model y = a*t+b to log(E(t)) and use this model to estimate
% e=log(E(t(end)))
if isempty(E)
   Ef = 0;
else
   ab = [t ones(size(t))]\log(E);
   Ef = exp([t(end) 1]*ab);
end
% sc = Ef-Emax;
sc = log(1+Ef/Escale)-log(1+Emax/Escale);

% Watch for NaN when goes unstable
if ~isfinite(sc)
   sc = 1e4 + i;
elseif isStable
   % Protect against inconsistent positive value due to errors on Ef estimate
   % (cf g200430)
    sc = min(sc,0);  
end





