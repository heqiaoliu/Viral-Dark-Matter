function updateVirtualProperties(this)
% UPDATEVIRTUALPROPERTIES for Notch

%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date:  

if isempty(this.Pole) || isempty(this.Zero)
    this.VirtualProperties = [NaN; NaN; NaN; NaN; NaN];
else
    Ts = this.Parent.Ts;
    [Wn, Zz] = damp(this.Zero(1), Ts);
    [Wn, Zp] = damp(this.Pole(1), Ts);

    % Calculate notch width and depth
    ndepth = Zz/Zp;
    nwidth = Localnotchwidth(ndepth, Zp);

    this.VirtualProperties = [Wn; Zz; Zp; ndepth; nwidth];
end


% ------------------------------------------------------------------------%
% Function: Localnotchwidth
% Purpose:  Calculates log notch width
% ------------------------------------------------------------------------%
function width = Localnotchwidth(depth,zeta2)
% Calculate notch width at percent depth p
%      s^2 + (2*Zeta1^2)*s + wn^2
% G(s)--------------
%      s^2 + (2*Zeta2^2)*s + wn^2
%
% Depth = Zeta1/Zeta2

p=.25; % percent depth for width calculation
alpha = depth^p;
if alpha == 1
    % alpha = 1 -> G(s)=1 Pole/Zero Cancelation
    width = NaN;
else
    % Calculate log width
    Beta =sqrt(zeta2^2*(alpha^2-depth^2)/(1-alpha^2));
    width = log10(1 + 2*Beta^2 + 2*Beta*sqrt(1+Beta^2));
end