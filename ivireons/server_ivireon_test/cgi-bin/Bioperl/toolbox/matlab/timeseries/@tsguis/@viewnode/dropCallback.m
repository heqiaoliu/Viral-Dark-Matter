function dropCallback(h, varargin)

% Copyright 2004-2005 The MathWorks, Inc.


%% Find selected axes
thisaxespos = [];
if ~isempty(h.Plot) && ishandle(h.Plot) && nargin>=3    
    % Get current fig pos in normalized units
    figunits = get(ancestor(h.Plot.AxesGrid.Parent,'figure'),'Units');
    %Y = HGCONVERTUNITS(FIG, X, SRCUNITS, DESTUNITS, REF)
    uipanelpos = hgconvertunits(ancestor(h.Plot.AxesGrid.Parent,'figure'),...
        get(h.Plot.AxesGrid.Parent,'Position'),get(h.Plot.AxesGrid.Parent,'Units'),...
        'Normalized',ancestor(h.Plot.AxesGrid.Parent,'figure'));
    % Get current position in normalized units
    thispos = hgconvertunits(ancestor(h.Plot.AxesGrid.Parent,'figure'),...
        [0 0 varargin{1} varargin{2}],'Pixels',...
        'Normalized',ancestor(h.Plot.AxesGrid.Parent,'figure'));
    thispos = [thispos(3) 1-thispos(4)];

    % Loop through each axes to see if it's the one
    theseaxes = h.plot.axesgrid.getaxes;
    for k=1:length(theseaxes)
        % Compute axes pos in fig coorrdinates
        thisaxescoord = [theseaxes(k).Position(1:2).*uipanelpos(3:4)+...
            uipanelpos(1:2), theseaxes(k).Position(3:4).*uipanelpos(3:4)];
            
        if thispos(1)>=thisaxescoord(1) && ...
                thispos(2)>=thisaxescoord(2) && ...
                thispos(1)<=thisaxescoord(1)+thisaxescoord(3) && ...
                thispos(2)<=thisaxescoord(2)+thisaxescoord(4)
            thisaxespos = k;
            break
        end
    end
end

%% Drop action callback - common to all view nodes
selNodes = getSelectedNodes(handle(h.Tree));
if length(selNodes)==1
    figure(double(h.Figure));
    tsNode = handle(selNodes(1).getValue);
    % Bring the view figure to the front
    
    tsList = tsNode.getTimeSeries;
    if isempty(thisaxespos)
        h.addTs(tsList);
    else
        h.addTs(tsList,thisaxespos);
    end
    
    % Bring the current plot into focus
    figure(ancestor(h.Plot.AxesGrid.Parent,'figure'));
end

