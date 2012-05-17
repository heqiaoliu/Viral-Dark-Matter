function timeresp(src,r)
%FREQRESP  Updates @timedata objects.
%  Author(s):  
%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.6.8 $ $Date: 2006/11/17 13:45:43 $
 
%% Look for visible+cleared responses in response array
if isempty(r.Data.Amplitude) && strcmp(r.View.Visible,'on')
  % Find the conversion factor from the @timeseries time units to
  % the view units
  timeunitconv = tsunitconv(r.Parent.TimeUnits,src.Timeseries.TimeInfo.Units);
 
 % Update the time (relative or absolute) 
  if strcmp(r.Parent.Absolutetime,'on') % Absolute time vector displayed
      % If this response has no absolute time reference do not draw
      if isempty(src.Timeseries.TimeInfo.StartDate)
         return 
      end
      % If the @timeplot startdate has not been added set it to the
      % startdate for this response. This will happen if the @timeseries
      % has been converted to an absolute time vector from the @tsnode
      % panel
      if isempty(r.Parent.StartDate)
          r.Parent.StartDate = src.Timeseries.TimeInfo.StartDate;
      end
      refdateshift = tsunitconv(r.Parent.TimeUnits,'days')*...
              (datenum(src.Timeseries.TimeInfo.StartDate)-datenum(r.Parent.StartDate));
  else % Relative time only
      refdateshift = 0;
  end
  
  % Use stairs for zoh interp
  if strcmpi(src.Timeseries.DataInfo.Interpolation.Name,'zoh')
      r.Data.Ts = -1; % Use discrete plotting styles
  else
      r.Data.Ts = 0; % Use continuous line plotting styles
  end
  
  % Restrict the computation of data beyond the a max range
  % for performance and memory reasons.
  time = src.Timeseries.Time*timeunitconv;
  v = tsguis.tsviewer;
  if length(time)>v.MaxPlotLength
      if strcmp(r.View.AxesGrid.xlimmode,'manual')
          xlims = r.View.AxesGrid.getxlim{1}; 
      else
          xlims = [time(1) time(v.MaxPlotLength)]+refdateshift;      
      end
      xfocus = [time(1) time(v.MaxPlotLength)]+refdateshift;
      extent = xlims(2)-xlims(1);    
      [junk,L] = min(abs(time+refdateshift-xlims(1)+extent/2));
      [junk,U] = min(abs(time+refdateshift-xlims(2)-extent/2));
      time = time(L(1):U(1));
  else
      L = 1;
      U = length(time);
      if U>=2
          xfocus = [time(1) time(end)]+refdateshift;
      else
          xfocus = [0 1];
      end
  end
      
  if strcmp(r.View.AxesGrid.xlimmode,'manual')
      if isempty(time)
          set(r.Data,'Time',[],'Amplitude',zeros(size(src.Timeseries.Data)),'Reference',[]);
      else
          set(r.Data,'Time',refdateshift+time,...
                'Amplitude',src.Timeseries.Data(L(1):U(1),:),'Reference',L(1));
      end
  else
       set(r.Data,'Time',time+refdateshift,'Amplitude',...
           src.Timeseries.Data(L(1):U(1),:),'Reference',L(1));
  end
   % Update the focus - prevent trivial intervals or the @plot axes will not
   % display correctly      
   if xfocus(2)-xfocus(1)>eps  
       set(r.Data,'Focus',xfocus)
   else
       set(r.Data,'Focus',[xfocus(1) - 1e-6, xfocus(1) + 1e-6])
   end
  
  % Update the list of eventChars in case the events attached to this time
  % series have changed
  localRefreshEventChar(r)
end


function localRefreshEventChar(wf)

%% If the list of events has changed in the time series shown by this wave,
%% then this function will refresh the event characteristics
if ~isempty(wf.Characteristics)
    c = wf.Characteristics(strcmp('events',get(wf.Characteristics,{'Identifier'})));
else
    c =[];
end
currentEventNames = cell(length(c),1);
for k=1:length(c)
    currentEventNames{k} = c(k).Data.EventName;
end
newEventNames = get(wf.DataSrc.Timeseries.Events,{'Name'});

%% Identify chars for deleted events
[junk,deletedEventPos] = setdiff(currentEventNames,newEventNames);
deletedChars = c(deletedEventPos);

%% Create new chars for new events
[junk,newEventPos] = setdiff(newEventNames,currentEventNames);
newChar = [];
for k=1:length(newEventPos)
    newChar = [newChar(:); ...
        wf.addchar('events','tsguis.eventCharData','tsguis.eventCharView')];
    newChar(end).Data.EventName = wf.DataSrc.Timeseries.Events(newEventPos(k)).Name;
end

%% Remove and delete chars marked for deletion
[junk,I] = ismember(wf.Characteristics,deletedChars);
I = find(I>0);
if ~isempty(I)
   wf.Characteristics(I) = [];
   delete(deletedChars);
end