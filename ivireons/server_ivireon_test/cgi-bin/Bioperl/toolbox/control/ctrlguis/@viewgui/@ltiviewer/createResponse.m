function createResponse(this,View,Systems,Styles,varargin)
%CREATERESPONSE  Creates one response per system for a given plot.

%   Authors: Kamesh Subbarao
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.6.6 $  $Date: 2005/11/15 00:54:07 $

PlotType = View.Tag;
for ct=1:length(Systems)
   r = View.addresponse(Systems(ct));
   switch PlotType
      case {'step','impulse'}
         r.DataFcn = {@LocalTimeDataFcn Systems(ct) r PlotType this};
         r.Context = struct('Type',PlotType);
      case 'initial'
         r.DataFcn = {@LocalTimeDataFcn Systems(ct) r PlotType this};
         r.Context = struct('Type',PlotType,'IC',[]);
         % The new initial state must match the systems size to be added
         if nargin>=6 && isStateSpace(Systems(ct).Model)
            x0 = varargin{2};
            order = size(Systems(ct).Model,'order');
            if isscalar(order) && order==length(x0)
               r.Context.IC = x0;
            end
         end
      case 'lsim'
         r.DataFcn = {'lsim' Systems(ct) r};
         r.Context = struct('InputIndex',[],'IC',[]);
         % The size of the new initial state must match the # of states in the added
         % systems
         if nargin>=6 && isStateSpace(Systems(ct).Model)
            order = size(Systems(ct).Model,'order');
            x0 = varargin{2};
            if isscalar(order) && order==length(x0)
               r.Context = struct('InputIndex',[],'IC',x0);
            end
         end
      case {'bode','bodemag'}
         r.DataFcn = {@LocalMagPhaseDataFcn Systems(ct) r 'bode' this};
      case 'nichols'
         r.DataFcn = {@LocalMagPhaseDataFcn Systems(ct) r 'nichols' this};
      case {'nyquist','sigma'}
         r.DataFcn = {@LocalFreqDataFcn Systems(ct) r PlotType this};
      case 'pzmap'
         r.DataFcn = {'pzmap' Systems(ct) r};
      case 'iopzmap'
         r.DataFcn = {'pzmap' Systems(ct) r 'io'};
   end
   % Styles and preferences
   initsysresp(r,PlotType,View.Options)
   r.Style = Styles(ct);
end

%%%%%%%%%%%%%%%%%%%%
% LocalTimeDataFcn %
%%%%%%%%%%%%%%%%%%%%
function LocalTimeDataFcn(src,r,PlotType,this,varargin)
% Data function for time plots
timeresp(src,PlotType,r,this.Preferences.TimeVector,varargin{:})

%%%%%%%%%%%%%%%%%%%%%%%%
% LocalMagPhaseDataFcn %
%%%%%%%%%%%%%%%%%%%%%%%%
function LocalMagPhaseDataFcn(src,r,PlotType,this)
% Data function for Frequency Mag, Phase plots
f = this.Preferences.FrequencyVector;
if iscell(f)
   % Frequency range specified
   fc = unitconv([f{:}],this.Preferences.FrequencyUnits,'rad/s');
   magphaseresp(src,PlotType,r,{fc(1) fc(2)})
else
   % f is [] or a vector
   magphaseresp(src,PlotType,r,unitconv(f,this.Preferences.FrequencyUnits,'rad/s'));
end

%%%%%%%%%%%%%%%%%%%%
% LocalFreqDataFcn %
%%%%%%%%%%%%%%%%%%%%
function LocalFreqDataFcn(src,r,PlotType,this)
% Data function for Frequency Response plots
f = this.Preferences.FrequencyVector;
if iscell(f)
   % Frequency range specified
   fc = unitconv([f{:}],this.Preferences.FrequencyUnits,'rad/s');
   feval(PlotType,src,r,{fc(1) fc(2)});
else
   % f is [] or a vector
   feval(PlotType,src,r,unitconv(f,this.Preferences.FrequencyUnits,'rad/s'));
end