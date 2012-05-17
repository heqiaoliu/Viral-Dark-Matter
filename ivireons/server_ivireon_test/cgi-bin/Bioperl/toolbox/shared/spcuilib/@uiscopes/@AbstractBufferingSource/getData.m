function data = getData(this, startingTime, endingTime)
%GETDATA  Get the data from the data buffer.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:43:39 $

dataBuffer = this.DataBuffer;

if nargin < 2
    startingTime = getTimeOfDisplayData(this);
end
if nargin < 3
    endingTime = startingTime;
end

nInputs = length(dataBuffer);

data = repmat(struct('values', {[]}, ...
    'time', [], ...
    'dimensions', []), 1, nInputs);

for indx = 1:length(dataBuffer)
    en = dataBuffer(indx).end;
    st = en+1;
    if st > dataBuffer(indx).length || ~dataBuffer(indx).isFull
        st = 1;
    end
    time = dataBuffer(indx).time;
    
    % Search for the ending index first.  It is very likely that the user
    % is requesting the last time stamp.  This will be much faster than
    % looking for the starting index first by narrowing down the search for
    % the first index.
    endIndex = find(time(1:en) <= endingTime, 1, 'last');
    
    if isempty(endIndex)
        endIndex = find(time(st:end) <= endingTime, 1, 'first');
        
        if isempty(endIndex)
            startIndex = [];
        else
            
            % The starting index is definitely after the "start" of the
            % circular buffer.  If not this means that the startingTime is
            % below all values of time we still have in the buffer.  In
            % this case, just get the first value greater than the starting
            % time.
            startIndex = find(time(st:endIndex) >= startingTime, 1, 'first')+st-1;
        end
    else
        startIndex = find(time(1:endIndex) <= startingTime, 1 , 'last');
        if isempty(startIndex)
            startIndex = find(time(st:end) >= startingTime, 1, 'first')+st-1;
        end
    end
    
    if isempty(endIndex)
        % NO OP, return the empty values and time.
    elseif endIndex >= startIndex
        % No need to realign the data for time.
        data(indx).values     = dataBuffer(indx).values(:, startIndex:endIndex);
        data(indx).time       = time(startIndex:endIndex);
        data(indx).dimensions = dataBuffer(indx).dimensions(:, startIndex:endIndex);
    else
        % Need to realign the data for time.
        data(indx).values = [dataBuffer(indx).values(:, startIndex:end) ...
            dataBuffer(indx).values(:, 1:endIndex)];
        data(indx).time = [time(startIndex:end) time(1:endIndex)];
        data(indx).dimensions = [dataBuffer(indx).dimensions(:, startIndex:end) ...
            dataBuffer(indx).dimensions(:, 1:endIndex)];
    end
end

% [EOF]
