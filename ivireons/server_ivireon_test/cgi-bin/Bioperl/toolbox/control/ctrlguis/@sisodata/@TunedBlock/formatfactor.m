function FF = formatfactor(this,TargetFormat)
%FORMATFACTOR  Computes format factor.
%
%   FF = FORMATFACTOR(TunedBlock) computes the format factor FF that links
%   the invariant gain to the formatted gain and ZPK model gain:
%   TargetForamt: zpk     
%           ZPK Gain = FF * Invariant Gain
%   TargetFormat: time-constant              
%           TC Gaing = FF * Invariant Gain
%
%   FF = FORMATFACTOR(TunedBlock,FORMAT) computes the format factor FF for
%   the specified format.

%   Author(s): P. Gahinet
%   Copyright 1986-2008 The MathWorks, Inc. 
%   $Revision: 1.1.8.4 $  $Date: 2008/09/15 20:36:35 $

if nargin==1
   TargetFormat = this.Format;
end

Ts = this.Ts;

% Initialize settings based on sample time
if isequal(Ts,0)
    % Continuous
    InvariantFreq = 1e-6;
    sz = 1j*InvariantFreq;
else
    % Discrete
    InvariantFreq = 1e-6/Ts*pi; % 1e-6 * Nyquist freq in rad/s
    sz = exp(1j*InvariantFreq*Ts);
end

% Get pole/zero data
[Z,P] = getPZ(this);

% Factor
Factor = abs( prod(sz-P(:)) / prod(sz-Z(Z~=sz,:)));

switch lower(TargetFormat(1))
    case 't'
        % Time constant formats
        if ~isequal(Ts,0), % discrete
            P = P-1;   Z = Z-1;
        end
        FF = abs(Factor * real(prod(-Z(Z~=0,:)))/prod(-P(P~=0,:)));

    case 'z'
        % Zero-pole-gain format
        if ~isequal(Ts,0), % discrete
            P = P-1;   Z = Z-1;
        end
        FF = Factor * sign(real(prod(-Z(Z~=0,:))/prod(-P(P~=0,:))));
end

    