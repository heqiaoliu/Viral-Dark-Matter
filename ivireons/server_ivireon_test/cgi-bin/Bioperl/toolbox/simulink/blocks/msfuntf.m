function msfuntf(block)
%MSFUNTF an MATLAB S-function which performs transfer function analysis using ffts.
%   This MATLAB file is designed to be used in a Simulink S-function block.
%   It stores up a buffer of input and output points of the system
%   then plots the frequency response of the system based on this information.
%
%   The input arguments are:
%     npts:        number of points to use in the fft (e.g. 128)
%     HowOften:    how often to plot the ffts (e.g. 64)
%     offset:      sample time offset (usually zeros)
%     ts:          how often to sample points (secs)
%     averaging:   whether to average the transfer function or not
%
%   The spectrum analyzer displays three plots: the time history,
%   the phase and magnitude of the transfer function.

%   Copyright 1990-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $
%   Andrew Grace 5-30-91.
%   Revised Wes Wang 4-28-93, 6-18-96.

setup(block);

%endfunction

function setup(block)

npts = block.DialogPrm(2).Data;
HowOften = block.DialogPrm(3).Data;
offset = block.DialogPrm(4).Data;
ts = block.DialogPrm(5).Data;

if (HowOften > npts)
      DAStudio.error('Simulink:blocks:numberOfBufferPointsGreaterThanPlotFreq');
end

% Register number of ports
block.NumInputPorts  = 1;
block.NumOutputPorts = 0;

% Override input port properties
block.InputPort(1).DirectFeedthrough = true;

% Register parameters
block.NumDialogPrms     = 6;
block.SampleTimes = [ts offset];
block.SetSimViewingDevice(true);

block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
block.RegBlockMethod('InitializeConditions', @InitializeConditions);
block.RegBlockMethod('Update', @Update);

%end setup

function DoPostPropSetup(block)
  block.NumDworks = 1;
  npts = block.DialogPrm(2).Data;
  fftpts = block.DialogPrm(1).Data;
  averaging = block.DialogPrm(6).Data;

  block.Dwork(1).Name            = 'vis';
  block.Dwork(1).Dimensions      = 2*npts+2+averaging*(2*round(fftpts/2))+2;
  block.Dwork(1).DatatypeID      = 0;      % double
  block.Dwork(1).Complexity      = 'Real'; % real
  block.Dwork(1).UsedAsDiscState = 0;


function InitializeConditions(block)
block.Dwork(1).Data(1,1) = 1; % initialize counter
%end InitializeConditions


function Update(block)
  % get dialog param values
  fftpts = block.DialogPrm(1).Data;
  npts = block.DialogPrm(2).Data;
  HowOften = block.DialogPrm(3).Data;
  ts = block.DialogPrm(5).Data;
  averaging = block.DialogPrm(6).Data;

   % input data
   u        = block.InputPort(1).Data;
   % Dwork values used for visualization
   x        = block.Dwork(1).Data;
   % current time
   t        = block.CurrentTime;
   
   nstates = (2*npts+2+averaging*(2*round(fftpts/2))+2)/2;
   sys = zeros(nstates,2);
   sys(:) = x;
   h_fig = sys(nstates, 2);
   if (h_fig <= 0)
      %
      % Graph initialization
      %
      sl_name = gcs;
      blocks = get_param(sl_name, 'CurrentBlock');
      n_b = size(blocks,1);
      if (n_b < 1)
         DAStudio.error('Simulink:blocks:cannotDeleteBlock'); 
      elseif (n_b > 1)
         DAStudio.error('Simulink:blocks:somethingWrongInGetParam')
      end
      %
      % Findout if the graphics window exist
      %
      ind = find(sl_name == char(10));
      for i = ind
         sl_name(i) = '_';
      end
      Figures = get(0,'Chil');
      new_figure = true;
      for i = 1:length(Figures)
         if (strcmp(get(Figures(i),'Type'),'figure') && strcmp(get(Figures(i),'Name'),sl_name))
            h_fig = Figures(i);
            handels = get(h_fig,'UserData');
            if (length(handels) == 9)
               new_figure = false;
               % handels = [h_sub311,h_plot1,h_plot2,h_sub312,h_plot1,h_plot2,h_sub313,h_plot1,h_plot2]
               for j = 1:3
                  set(handels(j*3-2),'Visible','off');
                  set(handels(j*3-1),'XData',0,'YData',0);
                  set(handels(j*3),  'XData',0,'YData',0);
                  xl = get(handels(j*3-2),'Xlabel');
                  set(xl, 'String','');
                  tl = get(handels(j*3-2),'Title');
                  set(tl, 'String','');
               end
               yl = get(handels(7), 'Ylabel');
               set(yl,'String','')
            end
         end
      end
      if (new_figure)
         h_fig = figure('Unit','pixel','Pos',[100,100,400,500],'Name',sl_name);
         set(0,'CurrentFigure',h_fig);
         %subplot311
         handels(1) = subplot(311);
         handels(2) = plot(0,0,'m');
         set(handels(1),'NextPlot','add');
         handels(3) = plot(0,0,'c');
         set(handels(1),'Visible','off');
         set(handels(1),'NextPlot','new');
         %subplot312
         handels(4) = subplot(312);
         handels(5) = plot(0,0);
         handels(6) = handels(5);
         set(handels(4),'Visible','off');
         %subplot313
         handels(7) = subplot(313);
         handels(8) = plot(0,0);
         handels(9) = handels(8);
         set(handels(7),'Visible','off');
      end
      tl = get(handels(4),'Title');
      set(tl,'String','Working - Please Wait');
      set(h_fig,'UserData',handels);
      set(h_fig,'NextPlot','new')
      sys(nstates,2) = h_fig;
      drawnow;
   end
   block.Dwork(1).Data(1,1) = round(block.Dwork(1).Data(1,1));

   block.Dwork(1).Data(1,1)  = block.Dwork(1).Data(1,1) + 1;
   x(1,1) = block.Dwork(1).Data(1,1);
   sys(x(1,1),:) = u(:)';
   div = x(1,1)/HowOften;
   if ((div == round(div)) && ishghandle(h_fig))
      ya = [sys(x(1,1)+1:npts+1,1);sys(2:x(1,1),1)];
      yb = [sys(x(1,1)+1:npts+1,2);sys(2:x(1,1),2)];
      n = fftpts/2;
      freq = 2*pi*(1/ts);                                   % Multiply by 2*pi to get radians
      w = freq*(0:n-1)./(2*(n-1));
      %
      % Hanning window to remove transient effects at the beginning
      % and end of the time sequence.
      %
      nw = min(fftpts,npts);
      win = (1-cos(2*pi*(1:nw)'/(nw+1)))/2;
      ga = fft(win.*ya(1:nw),fftpts);
      gb = fft(win.*yb(1:nw),fftpts);
      %
      % Perform averaging with overlap if number of fftpts is less than buffer
      %
      ng = fftpts;
      %
      % Averaging without overlap
      %
      while (ng <= (npts-fftpts))
         ga = (ga+fft(win.*ya(ng+1:ng+nw),fftpts))/2;
         gb = (gb+fft(win.*yb(ng+1:ng+nw),fftpts))/2;
         % For no overlap set: ng = ng + fftpts;
         ng = ng+n;
      end
      g = gb(1:n)./ga(1:n);                                 % Divide
      phase = (180/pi)*unwrap(atan2(imag(g),real(g)));
      mag  = abs(g);
      %
      % Averaging
      %
      if (averaging)
         cnt = sys(1,2);
         sys(npts+2:npts+1+n,1) = cnt/(cnt+1)*sys(npts+2:npts+1+n,1)+mag/(cnt+1);
         sys(npts+2:npts+1+n,2) = cnt/(cnt+1)*sys(npts+2:npts+1+n,2)+phase/(cnt+1);
         sys(1,2) = sys(1,2)+1;
         mag = sys(npts+2:npts+1+n,1);
         phase = sys(npts+2:npts+1+n,2);
      end
      h_fig = sys(nstates,2);
      handels = get(h_fig,'UserData');
      if (averaging)
         tmp = 'Averaged Transfer Function ';
      else
         tmp = 'Transfer Function ';
      end
      tvec = t-ts*npts+ts*(1:npts);
      yvec = [ya;yb];
      set(handels(1),'Visible','on', ...
                     'XLim',[min(tvec),max(tvec)], ...
                     'YLim',[0.99*min(yvec),1.01*max(yvec)+eps]);
      set(handels(2),'XData',tvec,'YData',ya);
      set(handels(3),'XData',tvec,'YData',yb);
      tl = get(handels(1),'Title');
      set(tl,'String','Time history (1st: magenta; 2nd: cyan)');
      xl = get(handels(1), 'Xlabel');
      set(xl,'String','Time (secs)')
      ysc = phase(~isnan(phase));
      if (isempty(ysc))
         ysc=[0,1];
      else
         ysc = [0.99*min(ysc),1.01*max(ysc)+eps];
      end
      set(handels(7),'Visible','on','XLim',[min(w),max(w)],'YLim',ysc)
      set(handels(8),'XData',w,'YData',phase)
      tl = get(handels(7),'Title');
      set(tl,'String',cat(2,tmp,'(phase)'));
      xl = get(handels(7),'Xlabel');
      set(xl,'String','Frequency (rads/sec)')
      yl = get(handels(7),'Ylabel');
      set(yl,'String','Degrees')
      ysc = mag(~isnan(mag));                               % Filter out NaNs.
      ysc = ysc(~isinf(ysc));                               % Filter out Infs. 
      if (isempty(ysc))
         ysc=[0,1];
      else
         ysc = [0.99*min(ysc),1.01*max(ysc)+eps];
      end
      set(handels(4),'Visible','on','XLim',[min(w),max(w)],'YLim',ysc)
      set(handels(5),'XData',w,'YData',mag)
      xl = get(handels(4),'Xlabel');
      set(xl,'String','Frequency (rads/sec)')
      tl = get(handels(4),'Title');
      set(tl,'String',cat(2,tmp,'(magnitude)'))
      drawnow;
   end
   if sys(1,1) == npts
      block.Dwork(1).Data(1,1) = 1;
   end
   sys(1,1) = block.Dwork(1).Data(1,1);

   % resaving back to DWork
   block.Dwork(1).Data = sys(:);
   
%end Update

