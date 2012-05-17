function write(h)

% Copyright 2004-2010 The MathWorks, Inc.

%% Find and open the file
if length(h.Filename)<3
    return
end
mfilepath = fullfile(h.Path,h.Filename);
[fid,msg] = fopen(mfilepath,'w');
if ~isempty(msg)
    error('recorder:write:noopen','Cannot open file')
end

%% Write the file header
fprintf(fid,'%s','function ');
fprintf(fid,'%s','[');
for k=1:length(h.TimeseriesOut)
    fprintf(fid,'%s',sprintf('%s,',h.TimeseriesOut(k).Name));
end
for k=1:length(h.TimeseriesIn)-1
    fprintf(fid,'%s',sprintf('%s,',h.TimeseriesIn(k).Name));
end
if ~isempty(h.TimeseriesIn)
    fprintf(fid,'%s',sprintf('%s] = ',h.TimeseriesIn(end).Name));
else
    fprintf(fid,'%s',sprintf('] = '));  
end
fprintf(fid,'%s',h.Filename(1:end-2));
if ~isempty(h.TimeseriesIn)
    fprintf(fid,'%s','(');
    for k=1:length(h.TimeseriesIn)-1
        fprintf(fid,'%s,',h.TimeseriesIn(k).Name);
    end
    fprintf(fid,'%s)',h.TimeseriesIn(end).Name);
end
fprintf(fid,'\n\n%s',sprintf('%s Time Series Tool generated code: %s\n',...
    '%%',datestr(now)));

%% If any of the input time series are Simulink time series they must be
%% cast as base OOP timeseries
simulinkTimeSeriesFlag = false;
for k=1:length(h.TimeseriesIn)
    if isa(h.TimeseriesIn(k).Timeseries,'Simulink.Timeseries')
        if ~simulinkTimeSeriesFlag
            fprintf(fid,'%s\n','%% Converting Simulink time series objects to base time series');
            simulinkTimeSeriesFlag = true;
        end
        fprintf(fid,'%s\n',sprintf('%s = simulinkts2ts(%s);',h.TimeseriesIn(k).Name,h.TimeseriesIn(k).Name));
    end
end

%% Loop through the undo stack and write the contents of each transaction
%% buffer to the logged M file
for k=1:length(h.Undo)
    thistrans = h.Undo(k);
    for j=1:length(thistrans.Buffer)
        fprintf(fid,'%s',sprintf('%s\n',thistrans.Buffer{j}));
    end
    % Clear buffer
    thistrans.Buffer = {};
end

%% Clear in/out time series names
h.TimeseriesIn = [];
h.TimeseriesOut = [];

%% Close the file and update the path
fclose(fid);

%% Edit the file
try %#ok<TRYNC>
    edit(mfilepath);
end
