function drawSamples(this, allData)
%DRAWSAMPLES Draw when the input is in samples.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2010/04/21 21:49:25 $

hLines  = this.Lines;

startTime = this.TimeOffset;

lineCount = 0;
tdo       = this.TimeDisplayOffset;
yExtents  = this.YExtents;
for indx = 1:numel(allData)
    
    d = allData(indx);
    
    % Calculate the shown time, based on the time offset and the time
    % display offset.
    time = d.time-startTime;
    
    % Each element in the raw data is a channel.  In the buffered data each
    % row is a channel with the columns representing time.
    for jndx = 1:size(d.values, 1)
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
        set(hLines(lineCount), 'XData', time+itdo, 'YData', d.values(jndx, :));
    end
    if ~isempty(d.values)
        yExtents = [min(yExtents(1), min(d.values(:))) max(yExtents(2), max(d.values(:)))];
    end
end

this.YExtents = yExtents;

% [EOF]
