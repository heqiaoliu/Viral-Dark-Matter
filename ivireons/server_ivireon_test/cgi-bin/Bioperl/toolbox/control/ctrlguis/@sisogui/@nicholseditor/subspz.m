function [mag, phase] = subspz(Editor,PZold,PZnew,w,mag,phase)
% Updates frequency response by swapping pole/zero groups.
%
%   H = SUBSPZ(EDITOR,PZold,PZnew,W,H) returns the updated frequency
%   response when swapping the pole/zero group PZOLD for PZNEW.
%
%   [MAG,PHASE] = SUBSPZ(EDITOR,PZold,PZnew,W,MAG,PHASE) returns the
%   updated MAG,PHASE data when swapping the pole/zero group PZOLD 
%   for PZNEW.

%   Author(s): P. Gahinet, Bora Eryilmaz
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.2 $  $Date: 2005/12/22 17:43:20 $

% RE: MAG, PHASE is associated to a (normalized) ZPK model and the 
%     update is therefore independent of the format.
Ts = Editor.LoopData.Ts;

% Construct corrective factor
zcorr = [PZold.Pole ; PZnew.Zero];
pcorr = [PZold.Zero ; PZnew.Pole];

% S or Z vectors
s = 1i*w(:).';
if Ts,
  s = exp(Ts * s);
end
ls = length(s);

% Compute correction. Corrective term is prod(s-zj)/prod(s-pj)
sz = s(ones(1, length(zcorr)),:) - zcorr(:, ones(1, ls));
sp = s(ones(1, length(pcorr)),:) - pcorr(:, ones(1, ls));
a = prod(sz, 1);
b = prod(sp, 1);
Correction = ones(size(a));
nzb = find(b);
Correction(:, nzb) = a(:, nzb) ./ b(:, nzb);

% Update mag and phase
Correction = reshape(Correction,length(Correction),1);
if nargin==5
   % Complex frequency response
   mag = mag .* Correction;
else
   mag = mag .* abs(Correction);
   phase = phase + (180/pi) * unwrap(angle(Correction)); % phase in degrees
end
