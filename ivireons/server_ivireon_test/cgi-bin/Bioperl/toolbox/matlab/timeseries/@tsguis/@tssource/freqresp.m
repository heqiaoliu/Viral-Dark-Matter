function freqresp(src, r)
%FREQRESP  Updates @specdata objects.
%  Author(s):  
%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.6.6 $ $Date: 2005/11/27 22:44:09 $
 
%% Get new data from the @timeseries object.
[data,Ts] = tsToRegular(src);

%% Look for visible+cleared responses in response array
if isempty(r.Data.Response) && strcmp(r.View.Visible,'on')
    
  if isempty(data)
        set(r.Data,'Response',[],'Frequency',...
          [],'SoftFocus',false,'Focus',[0 1]);
        return
  end
      
  % Get frequency response data from the fft of the time series data  
  pspec = abs(fft(detrend(data,0))).^2;
  M = mean(pspec);
  for k=1:length(M)
      if M(k)>eps
         pspec(:,k) = pspec(:,k)/M(k)*std(data(:,k))^2;
      end
  end
    
  % Find the cumulative sum is this is a cumulative spectrum
  if strcmp(r.Parent.Cumulative,'on')
      pspec = cumsum(pspec)/size(pspec,1);
      set(r.Data,'Accumulated','on')
  else
      set(r.Data,'Accumulated','off')
  end
  
  
  % Define the freq vector
  N = size(pspec,1);
  freq = linspace(0,1,N)'/Ts;
 
  % Find the conversion factor from the @timeseries time units to
  % the view units
  r.Data.FreqUnits = r.Parent.AxesGrid.XUnits;
  frequnitconv = 1/tsunitconv(sprintf('%ss',r.Data.FreqUnits(5:end)),...
      src.Timeseries.TimeInfo.Units);
  r.Data.NyquistFreq = frequnitconv*0.5/Ts;
  freq = freq*frequnitconv;

  % Nan out masked columns
  if ~isempty(src.Mask) && length(src.Mask)==size(pspec,2)
      pspec(:,src.Mask) = NaN*ones([size(pspec,1) sum(src.Mask)]);
  end
  
  %% Throw away negative freq
  pspec = pspec(1:ceil(N/2),:);
  freq = freq(1:ceil(N/2));
  
  % Restrict the computation of data beyond the a max range
  % for performance and memory reasons.
  v = tsguis.tsviewer;
  if length(freq)>v.MaxPlotLength
      if strcmp(r.View.AxesGrid.xlimmode,'manual')
          xlims = r.View.AxesGrid.getxlim{1}; 
      else
          xlims = [freq(1) freq(v.MaxPlotLength)];
          xfocus = [freq(1) freq(v.MaxPlotLength)];
      end      
      extent = xlims(2)-xlims(1); 
      [junk,L] = min(abs(freq-xlims(1)+extent/2));
      [junk,U] = min(abs(freq-xlims(2)-extent/2));  
      freq = freq(L(1):U(1));
      pspec = pspec(L(1):U(1),:);
  else
      L = 1;
      U = length(freq);
      xfocus = [freq(1) freq(end)];
  end
  
  % Update the data with the power spec
  set(r.Data,'Response',pspec,'Frequency',...
          freq,'SoftFocus',false);
      
  if ~strcmp(r.View.AxesGrid.xlimmode,'manual')  
      % Update the focus
      if xfocus(2)-xfocus(1)>eps*100  
         set(r.Data,'Focus',xfocus)
      else
         set(r.Data,'Focus',[xfocus(1) - 1e-6, xfocus(1) + 1e-6])
      end
  end
end

%% The response name should match the time series name
%r.Name = src.Timeseries.Name;
