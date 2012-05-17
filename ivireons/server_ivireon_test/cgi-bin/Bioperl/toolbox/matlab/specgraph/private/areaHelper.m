function varargout = areaHelper(functionName,varargin)
    % This function is undocumented and may change in a future release.
    
    %   Copyright 2009 The MathWorks, Inc.
    
    % Switchyard for helper functions used by the AREA command.
    %   Function name may be one of:
    %      addListeners - Sets up the necessary callbacks to mimic having peers
    %      of an Area object.
    %      computeCoords - Computes the x and y coordinates for a stacked
    %      area.
    
    error(nargchk(1,inf,nargin,'struct'));
    
    if ~ischar(functionName)
        error('MATLAB:barHelper:firstInputString','The first input argument must be a string.');
    end
    
    switch(functionName)
        case 'addListeners'
            localAddListeners(varargin{:});
        case 'computeCoords'
            [varargout{1}, varargout{2}] = localComputeCoords(varargin{:});
    end
    
end

function localAddListeners(h)
    if ~isempty(h)
        addlistener(h,{'XData','YData','XDataMode','BaseValue'},'PostSet',@localRecomputeLayout);
    end
end

function localRecomputeLayout(~,evd)
    hArea = evd.AffectedObject;
    baseValue = get(hArea,'BaseValue');
    
    hPeers = findobj(hArea.Parent,'-class','matlab.graphics.chart.primitive.Area');
    hPars = get(hPeers,'Parent');
    
    if iscell(hPars)
        hPeers = hPeers(cellfun(@(x)(isequal(x,hArea.Parent)),hPars));
    end
    
    xData = get(hPeers,'XData');
    yData = get(hPeers,'YData');
    
    n = numel(hPeers);
    
    if n > 1
        % create a single matrix from all the vectors, adjusting for lengths
        ylen = max(cellfun('length',yData));
        xlen = max(cellfun('length',xData));
        maxlen = max(ylen,xlen);
        ydatafull = zeros(maxlen,n);
        ydatafull(:,1) = baseValue;
        xdatafull = ydatafull;
        for k = 1:n
            d = yData{k};
            ydatafull(1:length(d),k) = d(:);
            d = xData{k};
            xdatafull(1:length(d),k) = d(:);
            for j = (length(d)+1):maxlen
                xdatafull(j,k) = d(end)+j*10*eps;
            end
        end
        xData = xdatafull;
        yData = ydatafull;
    end
    
    [msg,x,y] = xychk(xData,yData,'plot');
    if ~isempty(msg)
        return;
    end
    if min(size(x))==1, x = x(:); end
    if min(size(y))==1, y = y(:); end
    n = size(y,2);
    
    [xCoords, yCoords] = localComputeCoords(x, y, baseValue);
    
    for k=1:n
        xCoordsVal = [];
        if ~isempty(xCoords)
            xCoordsVal = xCoords(:,k);
        end
        set(hPeers(k),'XCoords_I',xCoordsVal);
        yCoordsVal = [];
        if ~isempty(yCoords)
            yCoordsVal = yCoords(:,k);
        end
        set(hPeers(k),'YCoords_I',yCoordsVal);
        set(hPeers(k),'CCoords_I',k);
        set(hPeers(k),'BaseValue_I',baseValue);
    end
end

function [xCoords, yCoords] = localComputeCoords(x, y, baseValue)
    % Assumes that x and y are the result of a successful call to xychk
    % of the form [msg,x,y] = xychk(xdata,ydata,'plot');
    if min(size(y))==1, y = y(:); x = x(:); end
    [m,n] = size(y);
    
    if n>1,
        % Check for the same x spacing
        if all(all(abs(diff(x,2)) < eps(class(x)))),
            y = cumsum(y,2); % Use fast calculation
            % Check for duplicated x columns
        elseif ~any(any(diff(x,1,2))),
            y = cumsum(y,2); % Use fast calculation
        else
            xi = sort(x(:));
            yi = zeros(length(xi),size(y,2));
            for i=1:n,
                yi(:,i) = interp1(x(:,i),y(:,i),xi);
            end
            d = find(isnan(yi(:,1)));
            if ~isempty(d), yi(d,1) = baseValue(ones(size(d))); end
            d = find(isnan(yi));
            if ~isempty(d), yi(d) = zeros(size(d)); end
            x = xi(:,ones(1,n));
            y = cumsum(yi,2);
            m = size(y,1);
        end
        xCoords = [x(1,:);x;flipud(x)];
        yCoords = [baseValue(ones(m,1)) y];
        yCoords = [yCoords(1,1:end-1);yCoords(:,2:end);flipud(yCoords(:,1:end-1))];
    else
        xCoords = [x(1,:);x;flipud(x)];
        yCoords = [baseValue;y;baseValue(ones(m,1))];
    end
end