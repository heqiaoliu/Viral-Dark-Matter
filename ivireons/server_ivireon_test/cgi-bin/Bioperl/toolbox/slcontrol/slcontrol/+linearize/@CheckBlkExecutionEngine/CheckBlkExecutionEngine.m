classdef CheckBlkExecutionEngine < hgsetget
   
   % Author(s): A. Stothert 20-Oct-2009
   % Copyright 2009-2010 The MathWorks, Inc.
   % $Revision: 1.1.8.5.2.2 $ $Date: 2010/07/26 15:40:18 $
   
   % CHECKBLKEXECUTIONENGINE manage linearization for a Simulink model with
   % model check blocks
   %
   
   properties(Dependent = true, GetAccess = public, SetAccess = private)
      %Model - string with the name of the model being linearized
      Model
   end % Dependent Read only properties
   
   properties(GetAccess = private, SetAccess = private)
      %hMdl - handle to the Simulink model
      %
      hMdl
      
      %PortData - structure array with linio objects and pre-linearization
      %           settings for the specified ports
      PortData
      
      %MPMgr - structure array with a slcontrol.ModelParameterMgr object and
      %        flag indicating manager has been initialized
      MPMgr
      
      %MdlDirtyState - string indicating the model dirty state before
      %                linearization
      MdlDirtyState
      
      %RequestedLin - a structure array with fields for block handles and
      %simulation times indicating that a linearization has been requested
      %for the block at the specified simulation time
      RequestedLin
      
      %LoggingNames - array of block and block savename properties, primarily
      %               used to confirm there is no logging name conflicts
      LoggingNames
      
      %ModelStartListener - listener to model start events
      ModelStartListener
      
      %ModelStopListener -listener to model stop events
      ModelStopListener 
   end % Private properties
   
   methods
      function obj = CheckBlkExecutionEngine(model)
         % CHECKBLKEXECUTIONENGINE constructor
         %
         % obj = CheckBlkExecutionEngine(model)
         
         if nargin < 1 || ~ischar(model)
            ctrlMsgUtils.error('Controllib:general:UnexpectedError','The CheckBlkExecutionEngine constructor requires a model name argument');
         end
         obj.MdlDirtyState = 'unset';
         obj.hMdl          = get_param(model,'Object');
         
         %Create listener to prepare the model for linearization. Do this
         %after library links are resolved but before model compilation has
         %got too far. Need to wait for library links to get resolved because 
         %of Simulink library lazy loading. 
         L = handle.listener(obj.hMdl,'EngineSimStatusInitializing', @(hSrc,hData) obj.enableLinParamManager);
         obj.ModelStartListener = L;
      end
      function  enablePorts(this,ports)
         % ENABLEPORTS prepare model ports for linearization
         %
         % this.enablePorts(ports)
         %
         % ports - vector of linio objects
         %
         
         %Add ports to the model SCDPotentialLinearizationIOs
         %property. Need to determine which model to add the potential
         %linearization IOs to.
         newPort  = linearize.createSCDPotentialLinearizationIOsStructure(ports);
         mdl = bdroot(newPort(1).Block); %ports cannot span multiple models.
         currPort = get_param(mdl,'SCDPotentialLinearizationIOs');
         if isempty(currPort)
            %No ports currently defined, safe to add all the new ones
            addPort = newPort;
         else
            %Some ports already defined, only add newPort if it is not
            %already in currPort.
            addPort  = [];
            for ctP=1:numel(newPort)
               %Is this port already in the potential linearization ios list?
               havePort = false;
               ct = 1;
               while ~havePort && ct <= numel(currPort)
                  if isequal(newPort(ctP),currPort(ct))
                     havePort = true;
                  else
                     ct = ct + 1;
                  end
               end
               if ~havePort
                  %Add port to the potential linearization ios list
                  addPort = horzcat(addPort,newPort(ctP));
               end
            end
         end
         if ~isempty(addPort)
            %Locally store the io ports we added (must be  row vector)
            if isfield(this.PortData,'Mdls') && ~any(strcmp(this.PortData.Mdls,mdl))
               this.PortData.Mdls  = horzcat(this.PortData.Mdls,{mdl});
            else
               this.PortData.Mdls = {mdl};
            end
            if isfield(this.PortData,'Ports')
               this.PortData.Ports = horzcat(this.PortData.Ports,addPort);
            else
               this.PortData.Ports = addPort;
            end
            set_param(mdl,'SCDPotentialLinearizationIOs',horzcat(currPort,addPort))
         end
      end
      function scheduleLinearization(this,block,BlkLinData)
         % SCHEDULELINEARIZATION schedule a linearization
         %
         
         if isempty(this.MPMgr)
            %Block is executing but we've no configured parameter manager,
            %return quickly. This can happen when the model is being run as
            %part of a command-line linearize call
            return
         end
         
         if ~this.haveRequestedLinAtTime(block,BlkLinData.CurrentTime)
            %Prevent recursive calls because graph_jacobian fires block
            %output call
            this.RequestedLin = vertcat(this.RequestedLin,...
               struct('Block',block,'Time',BlkLinData.CurrentTime));
            spec = [];
            for ct=1:numel(BlkLinData.hPorts)
               hPort = BlkLinData.hPorts(ct);
               newSpec = struct(...
                  'Block', hPort.Block, ...
                  'Port', hPort.PortNumber, ...
                  'Type', hPort.Type, ...
                  'OpenLoop', strcmp(hPort.OpenLoop,'on'));
               spec = horzcat(spec, newSpec);
            end
            block.RequestLinearization(@localProcessJacobian,{spec, this, BlkLinData});
         end
      end
      function restoreModel(this)
         % RESTOREMODEL return model to pre-linearization state
         %
         
         % Note that this method will be called by all check blocks in the
         % model and should protect against repeatedly restoring the model.
         
         % Restore port settings
         if ~isempty(this.PortData)
            mdls = unique(this.PortData.Mdls);
            for ctM = 1:numel(mdls);
               mdl = mdls{ctM};
               currPort = get_param(mdl,'SCDPotentialLinearizationIOs');
               idxC  = [];  %Index into currPort of ports we added
               idxP = [];   %Index into PortData of ports we identify
               for ctP = 1:numel(this.PortData.Ports)
                  found = false;
                  ct = 1;
                  while ~found && ct <= numel(currPort)
                     if isequal(currPort(ct),this.PortData.Ports(ctP))
                        idxC = vertcat(idxC,ct);
                        idxP = vertcat(idxP,ctP);
                        found = true;
                     else
                        ct = ct + 1;
                     end
                  end
               end
               %Remove the potential linearization IOs we added
               currPort(idxC) = [];
               set_param(mdl,'SCDPotentialLinearizationIOs',currPort);
               %Clear the locally stored set of ios
               this.PortData.Ports(idxP) = [];
            end
            %Clear the locally stored set of ios
            this.PortData = [];
         end
         
         %Restore and linearization model parameter changes
         if ~isempty(this.MPMgr)
            this.MPMgr.Mgr.restoreModels
            this.MPMgr = [];
            %Disable the Model stop listener
            set(this.ModelStopListener,'Enabled','off')
         end
         
         %Clear any stored Execution data
         if ~isempty(this.RequestedLin)
            this.RequestedLin = [];
         end
         
         %Clear any stored logging data
         this.LoggingNames = {};
      end
      
      function enableLogging(this,blk)
         %ENABLELOGGING register block for logging
         %
         
         savename = get_param(blk,'SaveName');
         if ~isvarname(savename)
            %Invalid variable name, restore model settings and throw an error
            this.restoreModel;
            ctrlMsgUtils.error('Slcontrol:linearize:ErrorCheckBlockInvalidSaveName', ...
               savename, blk);
         end
         
         hBlk = get_param(blk,'Object');
         if isempty(this.LoggingNames)
            this.LoggingNames = {hBlk, savename};
         else
            %Check to see if we've already registered logging for this
            %block
            found = false;
            ct = 1;
            while ~found && ct <= size(this.LoggingNames,1)
               if isequal(this.LoggingNames{ct,1},hBlk)
                  found = true;
               end
               ct = ct + 1;
            end
            if ~found
            this.LoggingNames = vertcat(this.LoggingNames, {hBlk, savename});
         end
      end
      end
      
      function checkLogging(this)
         %CHECKLOGGING checks logging settings for all frequency domain check
         %blocks
         %
         
         %This method is potentially called by the start callback of all check
         %blocks, for performance only perform check once.
         if(isempty(this.LoggingNames))
            return
         end
         
         [ok, badname, src] = utctrlCheckLogNames(this.Model, this.LoggingNames, 'Checks_');
         
         if ~ok
            %Name conflict, need to restore model to pre-simulation status and
            %throw an error.
            this.LoggingNames = {};
            error('Simulink:SLG_DupDataLogVarName2',...
               ctrlMsgUtils.message('Slcontrol:linearize:ErrorCheckBlockConflictingSaveName',badname,src{1},src{2}));
         end
         
         %Clear logging names property, prevents multiple logging checks
         this.LoggingNames = {};
      end
   end % public methods
   
   methods
      function model = get.Model(this)
         %Get model name from model handle
         %
         model = this.hMdl.Name;
      end
   end %Property access methods
   
   methods(Access = private)
      function enableLinParamManager(this)
         % ENABLELINPARAMMANAGER prepare a linearization parameter
         % manager for the model
         %
         
         % Fire this callback with the EngineSimStatusInitializing event.
         % This ensures that we can change the configuration set before it
         % is locked for simulation.  If the configuration set is locked
         % then we know that the model is being compiled for code
         % generation.  In this case we rely on the block to error.
         cs = getActiveConfigSet(this.Model);
         if ~strcmp(get_param(this.Model,'SimulationMode'),'normal') || cs.isObjectLocked
            %Quick return, blocks will throw an error
            return
         end
         
         if isempty(this.MPMgr) || ~this.MPMgr.haveInitialized
            %Setup model for linearization. Be careful of case where the
            %model is a normal model reference instance and has been
            %initialized by the top level model. We'll know this because
            %the ModelReferenceNormalModeCallback will have been set by the
            %top level model.
            MdlRefCpy = get_param(this.Model,'ModelReferenceNormalModeCallback');
            if isempty(MdlRefCpy)
               Mgr = linearize.ModelLinearizationParamMgr.getInstance(this.Model);
               [ConfigSetParameters,ModelParams] = createLinearizationParams(linutil,true,true,[],[],linoptions,false);
               ModelParams.UseAnalysisPorts = 'on';
               Mgr.ModelParameters = ModelParams;
               Mgr.ConfigSetParameters = ConfigSetParameters;
               Mgr.loadModels;  %Make sure the model hierarchy is loaded
               Mgr.prepareModels;
               this.MPMgr = struct('Mgr', Mgr, 'haveInitialized', true);
               
               %Create a listener to restore model on simulation stop
               if isempty(this.ModelStopListener) || ~ishandle(this.ModelStopListener)
                  L = handle.listener(this.hMdl,'EngineSimStatusStopped', @(hSrc,hData) this.restoreModel);
                  this.ModelStopListener = L;
               else
                  set(this.ModelStopListener,'Enabled','on');
               end
            end
            
            %Clear LoggingNames cache
            this.LoggingNames = {};
         end
      end
      function cacheMdlDirtyState(this)
         % CACHEMDLDIRTYSTATE caches the model dirty state if it has not already
         % been cached
         
         if strcmp(this.MdlDirtyState,'unset')
            this.MdlDirtyState = get_param(this.Model,'Dirty');
         end
      end
      function processJacobian(this,J,BlkLinData)
         % PROCESSJACOBIAN function to construct linear system from
         % the Jacobian
         %
         
         LinData = struct('op',[],'block',[],'StoreJacobianData',false,...
            'opt',linoptions,'StateOrder',[],'FoldFactors',true,...
            'ReturnOperatingPoint',nargout>1,...
            'BlockSubs',struct('Name',cell(0,1),'Value',zeros(0,1)));
         
         %Prepare the Jacobian to extract the block linearization
         J = postProcessJacobian(linutil,J);
         
         %Set linearization options for this block
         set(LinData.opt,BlkLinData.Options);
         
         iofcn = @(J) utGetIOStruct(this.MPMgr.Mgr,J,LinData.opt,...
            BlkLinData.hPorts,'iopoints');
         sys= utProcessJacobian(linutil,this.MPMgr.Mgr,J,LinData,iofcn);
         if ~isempty(sys)
            sys.Name = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtLinearizedAtTime',...
               sprintf('%g',BlkLinData.CurrentTime));
         end
         
         %Evaluate the block requirements and set the block's cached output
         %value
         hReqs = BlkLinData.hReqs;
         nReq = numel(hReqs);
         if nReq > 0
            passed = true;
            ctR = 1;
            while passed && ctR <= numel(hReqs)
               c = hReqs(ctR).evalRequirement(sys,0,true);
               passed = all(c(:) <= 0);
               ctR = ctR+1;
            end
            BlkLinData.CachedOutput = double(passed);
         end
         
         %If there is an open view, update with the computed linearization
         hViewData = BlkLinData.hViewData;
         if isa(hViewData,'checkpack.checkblkviews.CheckBlockScopeVisData')
            hViewData.NewData = sys;
            hViewData.NewTime = BlkLinData.CurrentTime;
            hViewData.notify('DataChanged')
         end
         
         %Check whether we need to log the linearized system
         if strcmp(BlkLinData.SaveInfo.SaveToWorkspace,'on')
            %Stack the new system with systems that have the same
            %sampling time
            nLog = numel(BlkLinData.SaveInfo.Log);
            idx  = 1;
            cont = true;
            while idx <= nLog && cont
               if ~isequal(BlkLinData.SaveInfo.Log(idx).values.Ts,sys.Ts)
                  idx = idx + 1;
               else
                  cont = false;
               end
            end
            if idx > nLog
               newLog = struct(...
                  'time', BlkLinData.CurrentTime, ...
                  'values', sys, ...
                  'blockName', BlkLinData.SaveInfo.BlkName);
               BlkLinData.SaveInfo.Log = vertcat(BlkLinData.SaveInfo.Log,newLog);
            else
               BlkLinData.SaveInfo.Log(idx).time = vertcat(BlkLinData.SaveInfo.Log(idx).time, ...
                  BlkLinData.CurrentTime);
               BlkLinData.SaveInfo.Log(idx).values = stack(1,...
                  BlkLinData.SaveInfo.Log(idx).values, sys);
            end
            
         end
      end
      function yes = haveRequestedLinAtTime(this,block,cTime)
         %HAVEREQUESTEDLINATTIME function to check whether we've already
         %requested a linearization for a specific block at the specified
         %time.
         
         %Workaround g633330
         feature('scopedAccelEnablement','off');
                  
         if isempty(this.RequestedLin)
            yes = false;
         else
            blks  = [this.RequestedLin.Block];
            times = [this.RequestedLin.Time];
            yes = any((blks==block) & (times==cTime));
         end
      end
   end % private methods
end % classdef

function iostruct = utGetIOStruct(ModelParameterMgr,J,opt,io,lintypeflag,varargin)
% UTGETIOSTRUCT

% Get the port handles
inports = J.Mi.InputPorts;
outports = J.Mi.OutputPorts;
inname = J.Mi.InputName;
outname = J.Mi.OutputName;

% Logic to get the proper names and dimensions for each IO.
truncatename = strcmp(opt.UseFullBlockNameLabels,'off');
useBus   = strcmp(opt.UseBusSignalLabels,'on');
iostruct = getioindices(linutil,ModelParameterMgr,io,inports,...
   outports,inname,outname,lintypeflag,truncatename,useBus,varargin{:});
end

function localProcessJacobian(J,var)
%Helper function to process Jacobian returned by linearization

this = var{2};
BlkLinData = var{3};
this.processJacobian(J,BlkLinData)
end