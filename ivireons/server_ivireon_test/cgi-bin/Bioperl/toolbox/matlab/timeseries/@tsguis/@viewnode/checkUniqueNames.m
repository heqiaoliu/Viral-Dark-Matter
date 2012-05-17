function ts = checkUniqueNames(h,ts)

% Copyright 2006 The MathWorks, Inc.

%% Check that there is no name conflict between the added time series
%% and time series currently in the view. Return a list of time series
%% with unque names.
existingTs = h.Plot.getTimeSeries;
if ~isempty(existingTs)
    I = false(length(ts),1);
    nonunqueNames =  {};
    for k = 1:length(ts)
        for j=1:length(existingTs)
            if isequal(ts{k},existingTs{j})
                I(k) = true;
                nonunqueNames = [nonunqueNames; {ts{k}.Name}];
                break
            end
        end
    end
    if any(I)
          nonunqueNames = unique(nonunqueNames);
          nonunqueNamesStr = nonunqueNames{1};
          for j=2:length(nonunqueNames)
              nonunqueNamesStr = sprintf('%s,%s',nonunqueNamesStr,nonunqueNames);
          end
          errordlg(sprintf('Time series %s are already displayed in the plot.',...
            nonunqueNamesStr),'Time Series Tools','modal')
          ts(I) = [];
    end
end