function [h,InfResp] = fresp(D,w,units)
% Frequency response of FRD model.

%	 Author(s): P.Gahinet 
%   Copyright 1986-2009 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:29:26 $
if nargin==2
   units = 'rad/s';
end
InfResp = false;

% Convert incoming frequency to current units
if ~isreal(w)
   error('Control:analysis:freqresp1',...
      'The frequency points must be real valued for models of class "frd."')
elseif ~strcmp(D.FreqUnits,units)
   w = unitconv(w,units,D.FreqUnits);
end
[ny,nu,nf] = size(D.Response);

% Compute response at specified frequencies
h = nan(ny,nu,length(w));
if nf>0
   hw = ctrlMsgUtils.SuspendWarnings; %#ok<NASGU> % for log(0)
   % Find relative indices of frequencies W in D.Frequency
   iw = utInterp1(log(D.Frequency),1:nf,log(w));
   iwf = rem(iw,1);  % fractional part
   % Keep original values for exact matches (log interpolation introduces
   % small rounding errors)
   jExact = find(iwf==0);
   h(:,:,jExact) = D.Response(:,:,iw(jExact));
   % Interpolate log(h) = f(log(w)) between frequency points to avoid
   % asymptote distortions and to be consistent with visual interpolation
   % between data points in Bode or Nichols plots
   jInterp = find(iwf>0);
   if ~isempty(jInterp)
      h0 = log(D.Response);
      % Unwrap phase
      h0 = complex(real(h0),unwrap(imag(h0),[],3));
      for ct=1:length(jInterp)
         j = jInterp(ct);
         iwj = floor(iw(j));
         t = iwf(j);
         h(:,:,j) = exp((1-t) * h0(:,:,iwj) + t * h0(:,:,iwj+1));
      end
   end
end

% Factor in delays
if hasdelay(D)
   Ts = D.Ts;
   if Ts==0,
      h = getDelayResp(D,h,complex(0,w));
   else
      h = getDelayResp(D,h,exp(complex(0,w*Ts)));
   end
end
