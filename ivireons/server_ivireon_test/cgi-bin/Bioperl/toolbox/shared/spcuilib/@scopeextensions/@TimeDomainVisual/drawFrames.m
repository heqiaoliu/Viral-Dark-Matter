function drawFrames(this, allData)
%DRAWFRAMES Draw when the input is in frames.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2010/05/20 03:08:03 $

hLines  = this.Lines;
source  = this.Application.DataSource;

startTime = this.TimeOffset;

tdo = this.TimeDisplayOffset;

% Keep track of all lines plotted.
lineCount = 0;
yExtents  = this.YExtents;
for indx = 1:numel(allData)
    
    d = allData(indx);
    
    sampleTime    = getSampleTimes(source, indx);
    maxDimensions = getMaxDimensions(source, indx);
    
    % When we are viewing frames, we need to know the sample time so that
    % we can calculate where the values after the first are placed.
    % Add the offset to each of the time values.  Use MESHGRID to get time
    % and offset to be of the same dimensions, and then RESHAPE to get them
    % back into a single vector.
    [TIME, OFFSET] = meshgrid(d.time-startTime, ...
        0:(sampleTime/maxDimensions(1)):(sampleTime-sampleTime/maxDimensions(1)));
    TIME = TIME+OFFSET;
    time = TIME(:);
    
    % The number of channels is equal to the product of all dimensions
    % after the first.  The first is the actual values of the channels.
    nChannels = prod(maxDimensions(2:end));
    
    % Reshape the data column vector back out so that channels are in the
    % 2nd dimension and time in the 3rd.
    d.values = reshape(d.values, maxDimensions(1), nChannels, numel(d.time));
    
    % Loop over the channel count.
    for jndx = 1:nChannels
        
        % Pull the frames out of the 2nd dimension.
        values = d.values(:,jndx,:);
        
        % Reshape to align the time down the rows and get a single column
        % to be passed to YData.
        values = reshape(values, numel(values), 1);
        
        lineCount = lineCount+1;
        
        if isscalar(tdo)
            itdo = tdo;
        elseif numel(tdo) >= lineCount
            
            % Each element in the time display offset vector corresponds to
            % a line/signal, not an input.
            itdo = tdo(lineCount);
        else
            
            % Extra lines will have 0 offset.
            itdo = 0;
        end
        set(hLines(lineCount), 'XData', time+itdo, 'YData', values);
    end
    if ~isempty(d.values)         
        if any(isinf(d.values(:)))
            % throw away the elements with inf value            
            d.values = d.values(~isinf(d.values(:)));
            if ~isempty(d.values)  
                yExtents = [min(yExtents(1), min(d.values(:))) max(yExtents(2), max(d.values(:)))];
            end
        else
            yExtents = [min(yExtents(1), min(d.values(:))) max(yExtents(2), max(d.values(:)))];
        end
    end
end

this.YExtents = yExtents;

% [EOF]
