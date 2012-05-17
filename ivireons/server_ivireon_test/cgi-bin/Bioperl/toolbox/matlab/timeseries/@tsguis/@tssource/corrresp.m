function corrresp(src, r, hplot)
%FREQRESP  Updates @xydata objects for @corrplots
%  Author(s):  
%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.6.4 $ $Date: 2005/07/14 15:27:21 $
 
%% Get new data from the @timeseries object.
if src.Timeseries==src.Timeseries2 % Autocorrelation
    [data,Ts] = tsToRegular(src);
    data2 = data;
else % Cross correlation
    try
        [data,Ts,data2] = tsToRegular(src);
    catch
        %errordlg(lasterr,'Time Series Tools','modal');
        return
    end    
end

%% Look for visible+cleared responses in response array
if isempty(r.Data.CData) && strcmp(r.View.Visible,'on')
  
  % get lag number
  numlag= hplot.Lags;
  
  %% Detrend 
  data = detrend(data,0);
  data2 = detrend(data2,0);
  
  %% Scale
  for k=1:size(data,2)
      scale = sqrt(data(:,k)'*data(:,k));
      if scale>eps
          data(:,k) = data(:,k)/scale;
      else
          data(:,k) = 0;
      end
  end
  for k=1:size(data2,2)
      scale = sqrt(data2(:,k)'*data2(:,k));
      if scale>eps
          data2(:,k) = data2(:,k)/scale;
      else
          data2(:,k) = 0;
      end
  end  
  %% Correlate
  c = zeros([length(numlag),size(data,2),size(data2,2)]);
%   c(numlag+1,:,:) = data'*data2;
%   for lag=1:numlag
%       c(numlag+1+lag,:,:) = data(1+lag:end,:)'*data2(1:end-lag,:);
%   end
%   for lag=1:numlag
%       c(numlag+1-lag,:,:) = data(1:end-lag,:)'*data2(1+lag:end,:);
%   end
    if numlag(1)>=0
        for i=1:length(numlag)
            c(i,:,:) = data(1+numlag(i):end,:)'*data2(1:end-numlag(i),:);
        end
    elseif numlag(end)<0
        for i=1:length(numlag)
            c(i,:,:) = data(1:end+numlag(i),:)'*data2(1-numlag(i):end,:);
        end
    else
        zero=find(numlag==0);
        for i=zero:length(numlag)
            c(i,:,:) = data(1+numlag(i):end,:)'*data2(1:end-numlag(i),:);
        end
        for i=1:zero-1
            c(i,:,:) = data(1:end+numlag(i),:)'*data2(1-numlag(i):end,:);
        end
    end
  
  % TO DO: Nan out masked columns
  
  % Update the data with the correlation
  set(r.Data,'Cdata',c,'Lags',numlag);%,'Focus',[-10 10],'SoftFocus',false);
end

