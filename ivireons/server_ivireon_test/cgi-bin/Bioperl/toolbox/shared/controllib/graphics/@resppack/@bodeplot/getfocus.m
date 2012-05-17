function xfocus = getfocus(this,xunits)
%GETFOCUS  Computes optimal X limits for Bode plots.
% 
%   XFOCUS = GETFOCUS(PLOT) merges the frequency ranges of all 
%   visible responses and returns the frequency focus in the current
%   frequency units (X-focus).  XFOCUS controls which portion of the
%   frequency response is displayed when the x-axis is in auto-range
%   mode.
%
%   XFOCUS = GETFOCUS(PLOT,XUNITS) returns the X-focus in the 
%   frequency units XUNITS.


%  Author(s): P. Gahinet, B. Eryilmaz
%  Copyright 1986-2010 The MathWorks, Inc.
%  $Revision: 1.1.8.2 $ $Date: 2010/05/10 17:37:35 $

if nargin==1
   xunits = this.AxesGrid.XUnits;
end

if isempty(this.FreqFocus)
   % No user-defined focus.
   % Collect individual focus for all visible MIMO responses
   xfocus     = cell(0,1);
   softfocus  = false(0,1);
   sampletime = zeros(0,1);
   for ct=1:length(this.Responses)
      r = this.Responses(ct);
      % For each visible response...
      if r.isvisible
         [xf,sf,ts] = LocalGetFocus(r.Data(strcmp(get(r.View,'Visible'),'on')), this);
         xfocus = [xfocus ; xf];
         softfocus  = [softfocus ; sf];
         sampletime = [sampletime ; ts];
      end
   end
   
   %Collect focus for any requirements displayed on the plot
   xf        = getconstrfocus(this,'rad/sec');
   xfocus    = vertcat(xfocus,{xf});
   softfocus = vertcat(softfocus,false);
   
   % Merge into single focus (in rad/sec)
   xfocus = mrgfocus(xfocus,softfocus);
   
   % Extend focus to Nyquist frequency for discrete systems if focus is empty
   if isempty(xfocus)
      if any(sampletime > 0)
         xfocus = [0.1 1] * pi / max(sampletime(sampletime>0));
      else
         xfocus = [1 10];
      end
   end
   
   % Unit conversion
   xfocus = unitconv(xfocus,'rad/sec',xunits);
   
   % Round up x-bounds to entire decades
   if ~isempty(xfocus) 
      lxf = log10(xfocus);
      lxfint = [floor(lxf(1)),ceil(lxf(2))];
      %  RE: scheme below may clip out Nyquist frequency
      %    if lxfint(2)-lxfint(1)>3  % more than 3 decades
      %       % Shrink range when focus far from end points
      %       lxfint(1) = lxfint(1) + (lxf(1)>lxfint(1)+0.7);
      %       lxfint(2) = lxfint(2) - (lxf(2)<lxfint(2)-0.7);
      %    end
      xfocus = 10.^lxfint;
   end
else
   xfocus = unitconv(this.FreqFocus,'rad/sec',xunits);
end

% Protect against Xfocus = [a a] (g182099)
if xfocus(2)==xfocus(1)
   xfocus = xfocus .* [0.1,10] + [0 (xfocus(2)==0)];
end

%-------------------Local Functions ------------------------

%-----------------------------------
% LocalGetFocus
function [xf,sf,ts] = LocalGetFocus(data, this)

if isfield(this.Options,'MinGainLimit')
    MinGainLimitPref = this.Options.MinGainLimit;
else
    MinGainLimitPref = struct('Enable','off','MinGain',0);
end

n = length(data);
xf = cell(n,1);
sf = false(n,1);
ts = zeros(n,1);
for ct=1:n
    if strcmp(MinGainLimitPref.Enable,'on') %Check for Min Gain option
        minlvl = unitconv(MinGainLimitPref.MinGain, this.AxesGrid.YUnits{1}, data(ct).MagUnits);
        xmgf = LocalMinGainFocus(data(ct), minlvl);
        xf{ct} = unitconv(xmgf,data(ct).FreqUnits,'rad/sec');
    else
        xf{ct} = unitconv(data(ct).Focus,data(ct).FreqUnits,'rad/sec');
    end
   sf(ct) = data(ct).SoftFocus;
   ts(ct) = abs(data(ct).Ts);
end


%-----------------------------------
% LocalMinGainFocus
function xf = LocalMinGainFocus(data,minlvl)
% Min gain focus calculation, Calculates the x range subject to a lower
% magnitude constraint

if isempty(data.Focus)
    xf = data.Focus;
    return
end

Freq = data.Frequency;
Mag = data.Magnitude;
MagSize = size(Mag);
IOSize = prod(MagSize(2:end));

Mag = reshape(Mag,[MagSize(1), IOSize]);

% Find all freqpoints below minlvl
boo = all((Mag <= minlvl),2);

if all(boo)
    xf = [];
else
    Freqmin = data.Focus(1);
    Freqmax = data.Focus(2);
    if boo(1)
        xminidx = find(boo==0,1,'first');
        Freqmin = max(Freq(xminidx-1),data.Focus(1));
    else
        idx = find(boo==1,1,'first');
        Freqi = Freq(idx);
        if Freqi < data.Focus(1)
            Freqmin = Freqi/10;
        end
    end
    if boo(end)
        xmaxidx = MagSize(1) - find(flipud(boo)==0,1,'first') + 1;
        Freqmax = min(Freq(xmaxidx+1),data.Focus(2));
    end
    xf = [Freqmin,Freqmax];
end


