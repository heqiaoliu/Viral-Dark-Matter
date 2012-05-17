function [mag,ph,w,FocusInfo] = freqresp(D,~,wspec,isPlotted)
% Generates frequency response data (magnitude+phase) for
% MIMO LTI models. Used by BODE, NICHOLS, and NYQUIST.
%
%  [MAG,PHASE,W,FOCUSINFO] = FREQRESP(D,GRADE,WSPEC,ISPLOTTED) 
%  computes the frequency response of a single MIMO model D
%  over some user-defined or auto-generated frequency grid W
%  and returns the magnitude and phase data MAG and PH (in 
%  radians). MAG and PH are of size Nf-by-Ny-by-Nu.
%
%  GRADE should be set to 1 for NYQUIST, 2 for NICHOLS, and 
%  3 for BODE.
%
%  WSPEC specifies the frequency grid or range as follows:
%             [] :  none (auto-selected)
%    {fmin,fmax} :  user-defined frequency range (grid spans 
%                   this range)
%         vector :  user-defined frequency grid
%
%  ISPLOTTED is true when the data is used for plotting and false 
%  otherwise (interpolation is used only when ISPLOTTED=true).
%  See FREQFOCUS for details on the contents of FOCUSINFO.

%  Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/11/09 16:29:25 $

% Note: Output W can be empty
[w,Focus] = parseFreqSpec(D,wspec);

% Sort frequency vector (required by phase unwrapping)
[w,is] = sort(w);

% Remove I/O delays (handled separately for phase accuracy)
iod = getIODelay(D,'total');
if D.Ts>0
   iod = iod * D.Ts;
end
[ny,nu] = size(iod);
D.Delay = ltipack.utDelayStruct(ny,nu,false);

% Compute mag and phase data without delays
h = permute(fresp(D,w),[3 1 2]);
[mag,ph] = ltipack.getMagPhase(h,1,isPlotted);

% Add delay contribution
if norm(iod,1)>0
   ph = ph - reshape(w*reshape(iod,[1 ny*nu]),size(ph));
end

% Gather focus data
FocusInfo = ltipack.frddata.fSetFocus(Focus);

% Undo frequency sorting for [mag,ph] = xxx(sys,w) syntax
if ~isPlotted && any(diff(is)<0)
   w(is) = w;    mag(is,:,:) = mag;   ph(is,:,:) = ph;
end

