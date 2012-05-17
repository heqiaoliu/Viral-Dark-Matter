function addTs(h,ts,varargin)

%   Copyright 2004-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2008/08/20 23:00:04 $
import com.mathworks.toolbox.timeseries.*;

%% New time series require the xlimmode to be in auto to ensure that they
%% can be seen
h.AxesGrid.xlimmode = 'auto';

%% If the destination axes is not specied expand the number of axes by 1 to
%% accommodate the additional plot
s = size(ts.Data);
if nargin<=2 || isempty(varargin{1})
    numaxes = length(h.getaxes);
    if length(h.Waves)>0
        for k=1:length(h.Waves)
            if max(h.Waves(k).RowIndex)==numaxes
                h.addaxes;
                break;
            end
        end
    else
        h.addaxes;
    end
    axespos = h.axesgrid.size(1);
else
    axespos = varargin{1};
end

%% If multiple time series are being added, will need to suppress drawing
%% for all but the last
suppressDraw = (nargin>=4 && varargin{2});

%% Add the new waveform. Local function used to circumevent the behavior
%% of the @waveform localize method which will not allow a datasrc to
%% direct all components of a response to the same channel
r = h.addwave(tsguis.tssource('Timeseries',ts),axespos,@freqresp);

%% Add interval selection menus for each response
r.View.addMenu(h)

%% Add a listener to the @timeseries datachange event which fires the 
%% waveform datachanged event
r.addlisteners(handle.listener(r.DataSrc.Timeseries,'datachange', ...
    {@localDataChange r}));
%% Add a listener to the timeseries name property of the timePlot Data
%% to update the first column of the axes table
r.addlisteners(handle.listener(ts,ts.findprop('Name'),'PropertyPostSet',...
    {@localDataChange r}));
set(r,'Name',h.Parent.getRoot.trimPath(ts))
localDataChange([],[],r);

%% Update title
if length(h.Waves)==1 && ~suppressDraw
    if ismac
        h.axesgrid.Title = sprintf('Periodogram: %s',ts.Name);
    else
        h.axesgrid.Title = sprintf('Periodogram of %s',ts.Name);
    end
else
    if ismac
        h.axesgrid.Title = xlate('Multiple Periodograms');
    else
        h.axesgrid.Title = xlate('Periodogram of Multiple Time Series');
    end  
end

%% Remove additional empty axes
h.packAxes;

if ~suppressDraw
    S = warning('off','all'); % Disable "Some data is missing @resppack warn..."
    h.draw
    warning(S);       
end

%% Extend time focus if needed
if ~suppressDraw
    v = tsguis.tsviewer;
    if ts.TimeInfo.Length>v.MaxPlotLength
        msg = sprintf('Time series length exceeds the default display limit of %d. Restricting the plot to the first %d points. \n Use the Panning Tool or the Property Editor to display a different interval.',v.MaxPlotLength,v.MaxPlotLength);
        jf = tsguis.getJavaFrame(ancestor(h.axesgrid.parent,'figure'));      
        drawnow
        tsMsgBox.showMessageDialog1(javax.swing.SwingUtilities.getWindowAncestor(jf.getAxisComponent),...
                          msg,...
                          xlate('Time Series Tools'),...                   
                          tsPrefsPanel.PROPKEY_LARGETSOPEN,...
                          true);
    end
end

function localDataChange(eventSrc, eventData,r)

S = warning('off','all'); % Disable "Some data is missing ..."

thists = r.DataSrc.TimeSeries;
numcols = max(getdatasamplesize(thists));
% If the number of cols has changed replace the wave. Note that the new
% RowInds must be a subset of the old ones or extend them by repeting the 
% lats value
if numcols~=length(r.RowIndex)
   h = r.Parent;
   if numcols<=length(r.RowIndex)
       newRowInd = r.RowIndex(1:numcols);
   else % Add to the last row ind
       newRowInd = [r.RowIndex(:)' repmat(r.RowIndex(end),[1 numcols-length(r.RowIndex)])];
   end
   h.rmwave(r);
   h.addTs(thists,newRowInd,true);
else
   % Force plot to redraw
   r.DataSrc.send('SourceChanged')
   % Update viewnode and viewnodecontainer panels
   r.Parent.Parent.send('tschanged')
end

warning(S);