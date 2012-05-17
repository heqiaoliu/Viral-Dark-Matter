function histresp(src,r,hplot)
%FREQRESP  Updates @histdata objects 
%  Copyright 2004-2008 The MathWorks, Inc.
%  $Revision: 1.1.6.6 $ $Date: 2008/08/20 23:00:29 $

%% Get new data from the @timeseries object if necessary converting them to
%% uniform
data = src.Timeseries.Data;

%% Look for visible+cleared responses in response array
if isempty(r.Data.YData) && strcmp(r.View.Visible,'on')
      % Expand any bin counts to a full bin vector
      binvec = hplot.expandScalarBins;
      if size(data,1)>1
          [N,bins] = hist(data,binvec);
      elseif size(data,1)==1
          [N,bins] = hist([data;NaN*ones(size(data))],binvec); 
      else
          bins = binvec;
          N = zeros([length(bins) size(data,2)]);
      end
      % Expand end points to conform to hist habavior in MATLAB and
      % guarantee that the entire range is covered
      if length(bins)>=3
          datavec = data(:);
          datavec = datavec(~isnan(datavec));
          if ~isempty(datavec)
              mindatavec = min(datavec);
              maxdatavec = max(datavec);
              if maxdatavec>mindatavec
                  bins(1) = min(min(datavec),bins(1));
                  bins(end) = max(max(datavec),bins(end));
              end
          end
      end    
      N = reshape(N,[length(bins) size(data,2)]);
      bins = bins(:);
      % Nan out masked columns
      if ~isempty(src.Mask) && length(src.Mask)==size(N,2)
          N(:,src.Mask) = NaN*ones([size(N,1) sum(src.Mask)]);
      end
      % Update the data with the power spec
      if length(bins)>=2
          set(r.Data,'YData',N,'XData',bins,'Focus',[1.5*bins(1)-0.5*bins(2) ...
              1.5*bins(end)-0.5*bins(end-1)]);
      elseif length(bins)==1
          set(r.Data,'YData',N,'XData',bins)
      end
end
