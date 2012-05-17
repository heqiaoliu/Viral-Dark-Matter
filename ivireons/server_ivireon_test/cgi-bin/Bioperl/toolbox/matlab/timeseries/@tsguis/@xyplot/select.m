function select(h,ax,selected_rect)

% Copyright 2004-2005 The MathWorks, Inc.

%% 
set(h.axesgrid,'NextPlot','add');

%% Find curves on this axes
L = [];
for j=1:length(h.Responses.View.Curves(:))
    if isequal(ancestor(h.Responses.View.Curves(j),'Axes'),double(ax))
        L = [L;h.Responses.View.Curves(j)];
    end
end           
selected_rectangle = [min(selected_rect(:,1)),max(selected_rect(:,1)),...
    min(selected_rect(:,2)) max(selected_rect(:,2))];
for j=1:length(L)
    % Get the x,y data for each curve on this axes
    xdata = get(L(j),'xdata');
    ydata = get(L(j),'ydata');
    xdata = xdata(:);
    ydata = ydata(:); 
    
    % Find the indices of points in the selected rectangle
%     I = (xdata>=min(selected_rect(:,1)) & xdata<=max(selected_rect(:,1)) & ydata>=min(selected_rect(:,2)) & ...
%         ydata<=max(selected_rect(:,2)));
    
    % If necessary rebuild the selectedpoints array
%     s = size(h.Responses.View.selectedpoints);
%     if ~(isequal(size(h.Responses.View.Curves),s(1:2)) && s(3)==length(xdata))
%         h.Responses.View.selectedpoints = false([size(h.Responses.View.Curves),length(xdata)]);
%     end
    
    % Find the (x,y) position of this curve in the grid
    [idxrow,idxcol] = ind2sub(size(h.Responses.View.Curves),...
        find(L(j)==h.Responses.View.Curves));
    
    % Select points in the rectangle on the selected curve
    for row=1:length(idxrow)
        for col=1:length(idxcol)
            h.Responses.View.SelectedRectangles = [h.Responses.View.SelectedRectangles; ...
                [idxrow(row),idxcol(col),selected_rectangle]];
%             h.Responses.View.selectedpoints(idxrow(row),idxcol(col),:) = ...
%                 I | squeeze(h.Responses.View.selectedpoints(idxrow(row),idxcol(col),:));  
        end
    end
end

%% Refresh
h.AxesGrid.LimitManager='off';
h.draw;
h.AxesGrid.LimitManager='on';