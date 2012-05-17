function doEnablePlotBrowserListeners(fig,state)


if ~isprop(fig,'PlotBrowserListener') || isempty(fig.PlotBrowserListener) || ...
        ~isfield(fig.PlotBrowserListener,'Listener')
    return
end

% Handle udd vs MCOS listeners
if isobject(fig.PlotBrowserListener.Listener)
    fig.PlotBrowserListener.Listener.Enabled = state;
else
    set(fig.PlotBrowserListener.Listener,'Enabled',state);
end
    
