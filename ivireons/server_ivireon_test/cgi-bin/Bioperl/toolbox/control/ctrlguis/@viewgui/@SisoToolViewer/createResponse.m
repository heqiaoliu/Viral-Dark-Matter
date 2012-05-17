function createResponse(this,View,Systems,Styles,varargin)
%CREATERESPONSE  Creates one response per system for a given plot.

%   Authors: Kamesh Subbarao
%   Copyright 1986-2010 The MathWorks, Inc. 
%   $Revision: 1.1.8.6 $  $Date: 2010/05/10 16:59:32 $

PlotType = View.Tag;
for ct=1:length(Systems)
   r = View.addresponse(Systems(ct));
   switch PlotType
      case {'step','impulse'}
         r.DataFcn = {@LocalTimeDataFcn Systems(ct) r PlotType this};
         r.Context = struct('Type',PlotType);
         if strcmpi(PlotType,'step')
             DefinedCharacteristics = Systems(ct).getCharacteristics('step');
             DefinedCharacteristics(end+1) = struct(...
            'CharacteristicLabel', ctrlMsgUtils.message('Control:compDesignTask:strMultiModelDisplay'), ...
            'CharacteristicID', 'MultipleModelView', ...
            'CharacteristicData', 'resppack.UncertainStepData', ...
            'CharacteristicView', 'resppack.UncertainTimeView', ...
            'CharacteristicGroup', 'MultiModel');
             r.setCharacteristics(DefinedCharacteristics); 

         else
             DefinedCharacteristics = Systems(ct).getCharacteristics('impulse');
             DefinedCharacteristics(end+1) = struct(...
                 'CharacteristicLabel', ctrlMsgUtils.message('Control:compDesignTask:strMultiModelDisplay'), ...
                 'CharacteristicID', 'MultipleModelView', ...
                 'CharacteristicData', 'resppack.UncertainImpulseData', ...
                 'CharacteristicView', 'resppack.UncertainTimeView', ...
                 'CharacteristicGroup', 'MultiModel');
             r.setCharacteristics(DefinedCharacteristics); 
         end
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
         DefinedCharacteristics = Systems(ct).getCharacteristics('initial');
         r.setCharacteristics(DefinedCharacteristics);
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
         DefinedCharacteristics = Systems(ct).getCharacteristics('bode');
         DefinedCharacteristics(end+1) = struct(...
             'CharacteristicLabel', ctrlMsgUtils.message('Control:compDesignTask:strMultiModelDisplay'), ...
             'CharacteristicID', 'MultipleModelView', ...
             'CharacteristicData', 'resppack.UncertainMagPhaseData', ...
             'CharacteristicView', 'resppack.UncertainBodeView', ...
             'CharacteristicGroup', 'MultiModel');
         r.setCharacteristics(DefinedCharacteristics);
         wchar = r.initializeCharacteristic('MultipleModelView');
         wchar.DataFcn = {@LocalMultiModelMagPhaseDataFcn wchar 'bode' this};
      case 'nichols'
         r.DataFcn = {@LocalMagPhaseDataFcn Systems(ct) r 'nichols' this};
         DefinedCharacteristics = Systems(ct).getCharacteristics('nichols');
         r.setCharacteristics(DefinedCharacteristics);
      case 'nyquist'
         r.DataFcn = {@LocalFreqDataFcn Systems(ct) r PlotType this};
         DefinedCharacteristics = Systems(ct).getCharacteristics('nyquist');
%          DefinedCharacteristics(end+1) = struct(...
%              'CharacteristicLabel', ctrlMsgUtils.message('Control:compDesignTask:strMultiModelDisplay'), ...
%              'CharacteristicID', 'MultipleModelView', ...
%              'CharacteristicData', 'resppack.UncertainMagPhaseData', ...
%              'CharacteristicView', 'resppack.UncertainNyquistView', ...
%              'CharacteristicGroup', 'MultiModel');
         r.setCharacteristics(DefinedCharacteristics);
      case 'sigma'
         r.DataFcn = {@LocalFreqDataFcn Systems(ct) r PlotType this};
         DefinedCharacteristics = Systems(ct).getCharacteristics('sigma');
         r.setCharacteristics(DefinedCharacteristics);
      case 'pzmap'
         r.DataFcn = {@LocalPZMapDataFcn 'pzmap' Systems(ct) r this};
%          DefinedCharacteristics = Systems(ct).getCharacteristics('pzmap');
         DefinedCharacteristics(1) = struct(...
             'CharacteristicLabel', ctrlMsgUtils.message('Control:compDesignTask:strMultiModelDisplay'), ...
             'CharacteristicID', 'MultipleModelView', ...
             'CharacteristicData', 'resppack.UncertainPZData', ...
             'CharacteristicView', 'resppack.UncertainPZView', ...
             'CharacteristicGroup', 'MultiModel');
         r.setCharacteristics(DefinedCharacteristics);
         wchar = r.initializeCharacteristic('MultipleModelView');
         wchar.DataFcn = {@LocalMultiModelPZDataFcn wchar [] this};
      case 'iopzmap'
         r.DataFcn = {@LocalPZMapDataFcn 'pzmap' Systems(ct) r 'io' this};
         DefinedCharacteristics = Systems(ct).getCharacteristics('iopzmap');
         r.setCharacteristics(DefinedCharacteristics);
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

sw = warning('off','Control:analysis:ScalingIssue');[lw,lwid] = lastwarn;
if iscell(f)
   % Frequency range specified
   fc = unitconv([f{:}],this.Preferences.FrequencyUnits,'rad/s');
   magphaseresp(src,PlotType,r,{fc(1) fc(2)})
else
   % f is [] or a vector
   magphaseresp(src,PlotType,r,unitconv(f,this.Preferences.FrequencyUnits,'rad/s'));
end
warning(sw); lastwarn(lw,lwid);



%%%%%%%%%%%%%%%%%%%%
% LocalFreqDataFcn %
%%%%%%%%%%%%%%%%%%%%
function LocalFreqDataFcn(src,r,PlotType,this)
% Data function for Frequency Response plots
f = this.Preferences.FrequencyVector;
sw = warning('off','Control:analysis:ScalingIssue');[lw,lwid] = lastwarn;
if iscell(f)
   % Frequency range specified
   fc = unitconv([f{:}],this.Preferences.FrequencyUnits,'rad/s');
   feval(PlotType,src,r,{fc(1) fc(2)});
else
   % f is [] or a vector
   feval(PlotType,src,r,unitconv(f,this.Preferences.FrequencyUnits,'rad/s'));
end
warning(sw); lastwarn(lw,lwid);


%%%%%%%%%%%%%%%%%%%%
% LocalPZMapDataFcn %
%%%%%%%%%%%%%%%%%%%%
function LocalPZMapDataFcn(PlotType,Src,r,this)
PadeOrder = this.Parent.Preferences.PadeOrder;
sw = warning('off','Control:transformation:StateSpaceScaling');[lw,lwid] = lastwarn;
feval(PlotType,Src,r,[],PadeOrder);
warning(sw); lastwarn(lw,lwid);

function LocalIOPZMapDataFcn(PlotType,Src,r,ioflag,this)
PadeOrder = this.Parent.Preferences.PadeOrder;
sw = warning('off','Control:transformation:StateSpaceScaling');[lw,lwid] = lastwarn;
feval(PlotType,Src,r,ioflag,PadeOrder);
warning(sw); lastwarn(lw,lwid);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalMultiModelMagPhaseDataFcn %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalMultiModelMagPhaseDataFcn(wchar,PlotType,this)
sw = warning('off','Control:analysis:ScalingIssue');[lw,lwid] = lastwarn;
wf = wchar.Parent; % parent waveform
for ct=1:length(wchar.Data)
   % Propagate exceptions
   wchar.Data(ct).Exception = wf.Data(ct).Exception;
   if ~wchar.Data(ct).Exception
      getUncertainMagPhaseData(wf.DataSrc,PlotType,wf,wchar.Data,this.Parent.Preferences.getMultiModelFrequency);
   end
end
warning(sw); lastwarn(lw,lwid);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalMultiModelPZDataFcn       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalMultiModelPZDataFcn(wchar,ioflag,this)

PadeOrder = this.Parent.Preferences.PadeOrder;
wf = wchar.Parent; % parent waveform
for ct=1:length(wchar.Data)
   % Propagate exceptions
   wchar.Data(ct).Exception = wf.Data(ct).Exception;
   if ~wchar.Data(ct).Exception
      getUncertainPZData(wf.DataSrc,wf,wchar.Data,ioflag,PadeOrder);
   end
end

