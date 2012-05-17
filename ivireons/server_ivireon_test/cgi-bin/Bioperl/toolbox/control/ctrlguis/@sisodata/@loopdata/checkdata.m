function [InitData,Ts] = checkdata(this,InitData)
%CHECKDATA  Check validity of imported data.

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.12.4.13 $  $Date: 2010/04/21 21:10:31 $
nC = length(InitData.Tuned);
nG = length(InitData.Fixed);

% G and C are nG-by-1 and nC-by-1 structures with fields Name and Value
FirstImport = isempty(this.Plant); % 1 if no data in yet

% Validate tuned models
for ct=1:nC
   Component = this.C(ct);
   CompID = InitData.Tuned{ct};
   CData = InitData.(CompID);
   % Check that ZPK2ParFcn and Par2ZPKFcn are valid g292839
   CData.utCheckParZPKFcn;
   if ~isequal(CData.Value,[])
      % Check validity of modified component
      % RE: [] indicates no change in value and avoids losing 
      %     complex & lead/lag groups in non-modified compensators
      %     (sisotool('nichols',1), add complex pair, change config)
      CData = LocalCheckCompensatorModelData(CData,Component.Identifier);
      InitData.(CompID) = CData;
   end
end

% Validate fixed models
if getconfig(this.Plant)>0
   % Built-in loop structure
   idx = 1;
   GFRD = {};
   GSize = [];
   wmin = -inf;
   wmax = inf;
   for ct=1:nG
      Component = this.Plant.G(ct);
      CompID = InitData.Fixed{ct};
      GData = InitData.(CompID);
      GSize(:,ct) = prod(size(GData.Value));
      if ~isempty(GData.Value)
          % Check validity of modified component
          GData = LocalCheckFixedModelData(GData,Component.Identifier);
          if isa(GData.Value,'frd')
              GFRD{idx} = GData.Value;
              idx = idx+1;
          end
      elseif FirstImport
         GData = struct('Name',sprintf('untitled%s',Component.Identifier),'Value',zpk(1));
      else
         GData = save(Component,GData);
      end
      InitData.(CompID) = GData;
   end
   % Ensure FRD models are compatible
   if ~isempty(GFRD)
       try
           LocalCheckFRDConsistency(GFRD);
       catch ME
           ctrlMsgUtils.error('Control:compDesignTask:LoopdataCheck13')
       end
   end
   % Ensure Arrays are compatible
   % Elements must be single model or vectors of same size
   if ~all((GSize == 1) | (GSize == max(GSize)))
       ctrlMsgUtils.error('Control:compDesignTask:LoopdataCheck16')
   end
   
   
else
   % Specifying augmented plant P
   if ~isempty(InitData.P.Value)
      % Check validity of P model
      InitData.P = LocalCheckP(InitData.P,length(this.C));
   elseif FirstImport
       ctrlMsgUtils.error('Control:compDesignTask:LoopdataCheck01')
   else
      InitData.P = save(this.Plant);
   end
end


% Check sample time consistency
% RE: May affect "unchanged" components
Ts = LocalCheckSampleTime(this,InitData);



%----------------- Local functions -----------------


function LocalCheckFRDConsistency(FRDList)
% Checks FRD models have compatible sampling time and frequency units
sys1 = FRDList{1};
freqs = sys1.Frequency;
units = sys1.FrequencyUnit;
Ts = sys1.Ts;

% Check sampling time consistency and determine common frequency vector and units
for j=2:length(FRDList)
   sysj = FRDList{j};
   if sysj.Ts~=Ts
      ctrlMsgUtils.error('Control:combination:SampleTimeMismatch')
   end
   [freqs,units] = FRDModel.mrgfreq(freqs,units,sysj.Frequency,sysj.FrequencyUnit);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalCheckFixedModelData %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Data = LocalCheckFixedModelData(Data,Component)
% Checks model data for plant, sensor, prefilter, and compensator.

% Check model class
sys = Data.Value;
if ~isa(sys,'frd')
    if isa(sys,'idfrd')
        sys = frd(sys);
    elseif ~isreal(sys)
        ctrlMsgUtils.error('Control:compDesignTask:LoopdataCheck03',Component)
    elseif isa(sys,'idmodel')
        % IDMODEL support
        % Check the number of inputs to the model
        nu = size(sys,'nu');
        if nu > 0
            % If the model is not a time series extract the
            % model from the input channels to output channels.
            sys = zpk(sys('measure'));
        else
            % If the model is a time series model error out.
            ctrlMsgUtils.error('Control:compDesignTask:LoopdataCheck04',Component)
        end
    elseif isnumeric(sys)
        % Double
        sys = zpk(sys);
    end
end

% Check dimensions
if any(iosize(sys)~=1)
    ctrlMsgUtils.error('Control:compDesignTask:LoopdataCheck06',Component)
end
sizes = size(sys);
if prod(sizes(3:end)) ~= max(sizes(3:end))
    ctrlMsgUtils.error('Control:compDesignTask:LoopdataCheck15',Component)
end

Data.Value = sys;


%%%%%%%%%%%%%%%%%%%%%%%
% LocalCheckCompensatorModelData %
%%%%%%%%%%%%%%%%%%%%%%%
function Data = LocalCheckCompensatorModelData(Data,Component)
% Checks model data for plant, sensor, prefilter, and compensator.

% Check model class
sys = Data.Value;
if isa(sys,'frd') || isa(sys,'idfrd')
    ctrlMsgUtils.error('Control:compDesignTask:LoopdataCheck02',Component)
elseif ~isreal(sys)
    ctrlMsgUtils.error('Control:compDesignTask:LoopdataCheck03',Component)
elseif isa(sys,'idmodel')
    % IDMODEL support 
    % Check the number of inputs to the model
    nu = size(sys,'nu');
    if nu > 0
        % If the model is not a time series extract the
        % model from the input channels to output channels.
        sys = zpk(sys('measure'));
    else 
        % If the model is a time series model error out.
        ctrlMsgUtils.error('Control:compDesignTask:LoopdataCheck04',Component)
    end    
elseif isnumeric(sys)
   % Double
   sys = zpk(sys);
end

% Check for delays
if hasdelay(sys),
   if sys.Ts,
       % Map delay times to poles at z=0 in discrete-time case
       sys = delay2z(sys);
   else
       ctrlMsgUtils.error('Control:compDesignTask:LoopdataCheck14',Component)
   end
end

% Check dimensions
sizes = size(sys);
if prod(sizes(3:end))~=1
    ctrlMsgUtils.error('Control:compDesignTask:LoopdataCheck05')
elseif any(sizes~=1)
    ctrlMsgUtils.error('Control:compDesignTask:LoopdataCheck06',Component)
end

% Convert to zpk
sw = warning('off'); [lw,lwid] = lastwarn;
Data.Value = zpk(sys);
warning(sw); lastwarn(lw,lwid);



%%%%%%%%%%%%%%%
% LocalCheckP %
%%%%%%%%%%%%%%%
function P = LocalCheckP(P,nC)
% Checks model data for plant, sensor, prefilter, and compensator.

% Check model class
sys = P.Value;
if ~isa(sys,'ss')
    ctrlMsgUtils.error('Control:compDesignTask:LoopdataCheck07')
elseif ~isreal(sys)
    ctrlMsgUtils.error('Control:compDesignTask:LoopdataCheck08')
end

% Check dimensions
sizes = size(sys);
if prod(sizes(3:end))~=1
    ctrlMsgUtils.error('Control:compDesignTask:LoopdataCheck05')
elseif any(sizes<=nC)
    ctrlMsgUtils.error('Control:compDesignTask:LoopdataCheck09',nC+1)
end
   

%%%%%%%%%%%%%%%%%%%%%%%%
% LocalCheckSampleTime %
%%%%%%%%%%%%%%%%%%%%%%%%
function Ts = LocalCheckSampleTime(this,InitData)
% Checks sample time consistency

% Reconcile plant/sensor/prefilter/compensator sample times
% RE: The overall sample time is stored as this.Compensator.Ts
nG = length(InitData.Fixed);
nC = length(InitData.Tuned);
AllTs = zeros(nG+nC,1);
StaticFlags = zeros(nG+nC,1);
for ct=1:nG
   G = InitData.(InitData.Fixed{ct}).Value;
   AllTs(ct) = get(G,'Ts');
   StaticFlags(ct) = isstatic(G);
end
for ct=1:nC
   C = InitData.(InitData.Tuned{ct}).Value;
   if isequal(C,[])
      C = this.C(ct).ss; % use current value
   end
   AllTs(nG+ct) = get(C,'Ts');
   StaticFlags(nG+ct) = isstatic(C);
end
Ts = max(abs(AllTs(nG+1:nG+nC))); 

if any(AllTs~=Ts),
    % Sample time discrepancy
    DefTs = AllTs(~StaticFlags);  % Unambiguous sample times
    
    if isempty(DefTs)
        % All models are static
        Ts = max(AllTs);
    elseif ~any(diff(DefTs,[],1))
        % Unambiguous sample times match
        Ts = DefTs(1);
    else
        % Resolve mismatch
        if any(~DefTs)
            % Mix continuous/discrete
            ctrlMsgUtils.error('Control:compDesignTask:LoopdataCheck10')
        elseif any(diff(DefTs(DefTs>0,:),[],1))
            % Positive sample time mismatch
            ctrlMsgUtils.error('Control:compDesignTask:LoopdataCheck11')
        else
            Ts = max(DefTs);
        end
    end
    % RE: Make sure sample time is positive
    Ts = abs(Ts);
end


function boo = utCheckFRDData(this)
% Returns TRUE if frddata is compatible.


numPlants = length(this.G);

for cnt = 1:numPlants
    boo(cnt) = isstatic(this.G(cnt).ModelData);
end
