classdef (SupportClassFunctions=true) lti < ltipack.SingleRateSystem & ltipack.SystemArray
   % Linear Time-Invariant System objects.
   %
   %   You can specify and manipulate linear time-invariant (LTI) systems in 
   %   transfer function, zero-pole-gain, or state-space form using the @tf, 
   %   @zpk, and @ss classes. You can also work directly with the frequency 
   %   response of LTI systems using the @frd class. Finally, you can use 
   %   the @pid or @pidstd classes to conveniently work with PID controllers
   %   in parallel or standard form.
   %
   %   All LTI model types derive from the @lti superclass. This class is  
   %   not user-facing and cannot be instantiated.
   %
   %   See also TF, ZPK, SS, FRD, PID, PIDSTD.
   
%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%	 $Revision: 1.1.8.2 $  $Date: 2010/03/31 18:37:39 $

%   The System Identification Toolbox extends these basic LTI model
%   structures to support estimation of the model parameters from time-
%   or frequency-domain data. You can identify any of the following LTI
%   structures: low-order process models (@idproc), polynomial models
%   (@idpoly), state-space models (@idss and @idgrey), and frequency
%   response models (@idfrd).
%
%   All LTI model types derive from the @lti base class. This class is
%   not user-facing and cannot be instantiated.
%
%   See also TF, ZPK, SS, FRD, IDPROC, IDPOLY, IDSS, IDGREY, IDFRD.

   
   % Public properties
   properties (Access = public, Dependent)
      % Input delays (numeric vector, default = all zeros).
      %
      % The "InputDelay" property specifies a time delay for each input 
      % channel. For continuous-time systems, specify input delays in
      % the time unit stored in the "TimeUnit" property. For discrete-
      % time systems, specify input delays as integer multiples of the
      % sampling period "Ts", for example, InputDelay=2 to mean a delay
      % of two sampling periods.
      %
      % Set "InputDelay" to a Nu-by-1 vector for a system with Nu inputs.
      % You can also set this property to a scalar value to apply the same
      % delay to all input channels.
      %
      % Example: sys.InputDelay = [0 ; 1.7] specifies a zero delay for 
      % the first input channel and a delay of 1.7 time units for the
      % second input channel.
      InputDelay
      % Output delays (numeric vector, default = all zeros).
      %
      % Counterpart of "InputDelay" for output channels. Type
      % "help lti.InputDelay" for details.
      OutputDelay
   end
   
   methods
      
      % REVISIT: FOR RCTB COMPATIBILITY, DELETE WHEN RCTB IS MCOS COMPLIANT
      function Ts = getTs(sys)
         Ts = getTs_(sys);
      end
      function sys = setTs(sys,Ts)
         sys = setTs_(sys,Ts);
      end
      % END REVISIT
            
      function Value = get.InputDelay(sys)
         % GET method for InputDelay property
         Nsys = numel(sys.Data_);
         Nu = sys.IOSize_(2);
         if Nsys==0
            Value = zeros(Nu,1);
         elseif Nsys==1
            Value = sys.Data_.Delay.Input;
         else
            Value = zeros([Nu,1,size(sys.Data_)]);
            if Nsys>1
               RefValue = sys.Data_(1).Delay.Input;
               isUniform = true;
               for ct=1:Nsys
                  Value(:,ct) = sys.Data_(ct).Delay.Input;
                  isUniform = isUniform && isequal(Value(:,ct),RefValue);
               end
               if isUniform
                  Value = Value(:,1);
               end
            end
         end
      end
      
      function Value = get.OutputDelay(sys)
         % GET method for InputDelay property
         Nsys = numel(sys.Data_);
         Ny = sys.IOSize_(1);
         if Nsys==0
            Value = zeros(Ny,1);
         elseif Nsys==1
            Value = sys.Data_.Delay.Output;
         else
            Value = zeros([Ny,1,size(sys.Data_)]);
            if Nsys>1
               Data = sys.Data_;
               RefValue = Data(1).Delay.Output;
               isUniform = true;
               for ct=1:Nsys
                  Value(:,ct) = Data(ct).Delay.Output;
                  isUniform = isUniform && isequal(Value(:,ct),RefValue);
               end
               if isUniform
                  Value = Value(:,1);
               end
            end
         end
      end
      
      function sys = set.InputDelay(sys,Value)
         % SET function for InputDelay property
         if hasFixedDelay(sys)
            ctrlMsgUtils.error('Control:ltiobject:ReadOnlyDelay','InputDelay',class(sys))
         elseif ~(isnumeric(Value) && isreal(Value) && all(isfinite(Value(:))) && all(Value(:)>=0)),
            ctrlMsgUtils.error('Control:ltiobject:setLTI1','InputDelay')
         else
            Value = double(full(Value));
         end
         % Check compatibility of RHS with model array sizes
         Data = ltipack.utCheckAssignValueSize(sys.Data_,Value,2);
         for ct=1:numel(Data)
            id = Value(:,:,min(ct,end));
            Data(ct).Delay.Input = id(:);
            if sys.CrossValidation_
               Data(ct) = checkDelay(Data(ct));
            end
         end
         sys.Data_ = Data;
      end
      
      function sys = set.OutputDelay(sys,Value)
         % SET function for OutputDelay property
         if hasFixedDelay(sys)
            ctrlMsgUtils.error('Control:ltiobject:ReadOnlyDelay','OutputDelay',class(sys))
         elseif ~(isnumeric(Value) && isreal(Value) && all(isfinite(Value(:))) && all(Value(:)>=0))
             ctrlMsgUtils.error('Control:ltiobject:setLTI1','OutputDelay')
         else
            Value = double(full(Value));
         end
         % Check compatibility of RHS with model array sizes
         Data = ltipack.utCheckAssignValueSize(sys.Data_,Value,2);
         for ct=1:numel(Data)
            od = Value(:,:,min(ct,end));
            Data(ct).Delay.Output = od(:);
            if sys.CrossValidation_
               Data(ct) = checkDelay(Data(ct));
            end
         end
         sys.Data_ = Data;
      end
         
   end
      
   %% ABSTRACT SUPERCLASS INTERFACES
   methods (Access=protected)

      function Ts = getTs_(sys)
         % Implementation of @SingleRateSystem:getTs_
         if isempty(sys.Data_)
            Ts = 0;
         else
            Ts = sys.Data_(1).Ts;
         end
      end
      
      function sys = setTs_(sys,Ts)
         % Implementation of @SingleRateSystem:setTs_
         Data = sys.Data_;
         for ct=1:numel(Data)
            Data(ct).Ts = Ts;
         end
         sys.Data_ = Data;
      end
      
   end      
      
      
   %% DATA ABSTRACTION INTERFACE
   methods (Access=protected)
      
      %% MODEL CHARACTERISTICS
      function sys = checkDataConsistency(sys)
         % Check data consistency
         % Note: Because there is no syntax for creating an array of LTI
         % models with different I/O sizes, this code assumes that if all
         % @ltidata objects are self-consistent, their I/O size is uniform
         % across the LTI array
         D = sys.Data_;
         for ct=1:numel(D)
            D(ct) = checkDelay(checkData(D(ct)));
         end
         sys.Data_ = D;
         % I/O size is derived from data to support I/O resizing
         if ~isempty(D)
            sys.IOSize_ = iosize(D(1));
         end
      end
      
      %% BINARY OPERATIONS    
      function [sys1,sys2] = matchAttributes(sys1,sys2)
         % Enforces matching attributes in binary operations (e.g.,
         % sampling time, variable,...). This function can be overloaded
         % by subclasses.
         [sys1,sys2] = matchSamplingTime(sys1,sys2);
      end
      
      %% INDEXING
      function sys = createLHS(rhs)
         % Creates LHS in assignment.
         % Returns 0x0 system of the same class as RHS and with the same sampling time
         if isa(rhs,'FRDModel')
            sys = FRDModel.cast(class(rhs),[],rhs);
         else
            sys = setTs_(feval(class(rhs)),getTs_(rhs));
         end
      end
                  
   end
   
   
   % UTILITIES
   methods (Access=protected)
      
      function boo = hasFixedDelay(~)
         % Subclasses can override this method to make delays read-only 
         % and fix their value to zero (see @pid)
         boo = false;
      end      
      
      %-------------
      function Value = getIODelay(sys)
         % Generic GET function for I/O delays in LTI models
         Data = sys.Data_;
         Nsys = numel(Data);
         [Ny,Nu] = iosize(sys);
         if Nsys==0
            Value = zeros(Ny,Nu);
         else
            Value = zeros([Ny,Nu,size(Data)]);
            isUniform = true;
            for ct=1:Nsys
               iod = getIODelay(Data(ct));
               if hasInfNaN(iod)
                  ctrlMsgUtils.error('Control:ltiobject:get3')
               end
               Value(:,:,ct) = iod;
               isUniform = isUniform && isequal(iod,Value(:,:,1));
            end
            if Nsys>1 && isUniform
               Value = Value(:,:,1);
            end
         end
      end
         
      %-------------
      function sys = setIODelay(sys,Value)
         % Generic SET function for I/O delays in LTI models
         if ~(isnumeric(Value) && isreal(Value) && all(isfinite(Value(:))) && all(Value(:)>=0)),
            ctrlMsgUtils.error('Control:ltiobject:setLTI1','ioDelay')
         else
            Value = double(full(Value));
         end
         Data = ltipack.utCheckAssignValueSize(sys.Data_,Value,2);
         for ct=1:numel(Data)
            % Modify I/O delays if there are no fractional delays
            iod = getIODelay(Data(ct));
            if hasInfNaN(iod)
               ctrlMsgUtils.error('Control:ltiobject:get3')
            end
            Data(ct) = setIODelay(Data(ct),Value(:,:,min(ct,end)));
            if sys.CrossValidation_
               Data(ct) = checkDelay(Data(ct));
            end
         end
         sys.Data_ = Data;
      end
      
      %-------------
      function sys = fastSet(sys,varargin)
         % Version of SET without consistency checks
         ni = nargin-1;
         if rem(ni,2)~=0,
            ctrlMsgUtils.error('Control:ltiobject:CompletePropertyValuePairs')
         end
         PublicProps = ltipack.allprops(sys);
         ClassName = class(sys);
         sys.CrossValidation_ = false;
         for ct=1:2:ni,
            sys.(ltipack.matchProperty(varargin{ct},PublicProps,ClassName)) = varargin{ct+1};
         end
         sys.CrossValidation_ = true;
      end
      
      %-----------
      function sys = reload(sys,s)
         % Restore data when loading object
         if isfield(s,'Version_')
            % Version 10- (MCOS)
         elseif isfield(s,'dynamicsys')
            % Versions 5-9 (LTI2)
            sys = reload@DynamicSystem(sys,s.dynamicsys);
            sys.Data_ = s.Data;
         else
            % Versions 1-4
            sys.Ts = s.Ts;
            
            % Collect metadata and delay settings
            MetaData = struct('Name',[]);
            MetaData.InputName = s.InputName;
            MetaData.OutputName = s.OutputName;
            MetaData.Notes = s.Notes;
            MetaData.UserData = s.UserData;
            DelaySettings = cell(1,0);
            
            % Flags to determine if repeated i/o channels and names are modified during load
            GInputChannelsModified = false;
            GInputNamesModified = false;
            GOutputChannelsModified = false;
            GOutputNamesModified = false;
            
            if s.Version==1
               % Copy properties specific to Version 1 object S to SYS
               % Note: Td was equivalent to InputDelay'
               DelaySettings = [DelaySettings , {'InputDelay',s.Td'}];
               MetaData.InputGroup = struct;
               MetaData.OutputGroup = struct;
            else
               % I/O groups
               [MetaData.InputGroup, GInputChannelsModified, GInputNamesModified]  = LocalGroupUpdate(s.InputGroup);
               [MetaData.OutputGroup, GOutputChannelsModified, GOutputNamesModified]  = LocalGroupUpdate(s.OutputGroup);
               % I/O delays
               DelaySettings = [DelaySettings , {'InputDelay',s.InputDelay,'OutputDelay',s.OutputDelay}];
               if s.Version==2 && any(s.ioDelayMatrix(:))  % g188500
                  DelaySettings = [DelaySettings , {'ioDelay',s.ioDelayMatrix}];
               elseif s.Version>2 && any(s.ioDelay(:))
                  DelaySettings = [DelaySettings , {'ioDelay',s.ioDelay}];
               end
            end
            
            % Display warnings if groups names or channels have been modified
            if GInputChannelsModified || GOutputChannelsModified
               ctrlMsgUtils.warning('Control:ltiobject:UpdateGroupIndex')
            end
            if GInputNamesModified || GOutputNamesModified
               ctrlMsgUtils.warning('Control:ltiobject:UpdateGroupName')
            end
            
            % Restore metadata and delays
            sys = reload@DynamicSystem(sys,MetaData);
            sys = set(sys,DelaySettings{:});
         end
      end
      
      %-------------
      function S = getSettings(sys)
         % Gets values of public LTI properties. Needed to support
         % obsolete syntax tf(num,den,LTI)
         S = struct(...
            'InputDelay',sys.InputDelay,...
            'OutputDelay',sys.OutputDelay,...
            'Ts',sys.Ts,...
            'TimeUnit',sys.TimeUnit_,...
            'InputName',{sys.InputName_},...
            'InputUnit',{sys.InputUnit_},...
            'InputGroup',sys.InputGroup,...
            'OutputName',{sys.OutputName_},...
            'OutputUnit',{sys.OutputUnit_},...
            'OutputGroup',sys.OutputGroup,...
            'Name',sys.Name,...
            'Notes',{sys.Notes},...
            'UserData',{sys.UserData});
      end
                  
   end
   
   
   methods (Static, Access=protected)
      
      function PVPairs = struct2pv(S)
         % Converts struct into property/value pair list
         f = fieldnames(S);
         n = length(f);
         PVPairs = cell(1,2*n);
         PVPairs(:,1:2:2*n) = f;
         PVPairs(:,2:2:2*n) = struct2cell(S);
      end
      
   end
   
   % STATIC METHODS
   methods(Static, Hidden)
      
      function sys = loadobj(s)
         % Load filter, needed to prevent warnings in LOADOBJ (see g582297)
         sys = s;
      end
      
      function [ConstructFlag,InputList] = parseConvertFcnInputs(F,InputList)
         % Helper function for input list parsing in converter F(sys,...).
         % Detects deprecated constructor syntax F(...,sys) for @lti objects.
         nsys = 0;
         for ct=1:numel(InputList)
            if isa(InputList{ct},'DynamicSystem'),
               nsys = nsys + 1;   isys = ct;
            end
         end
         if nsys>1,
            ctrlMsgUtils.error('Control:ltiobject:construct4',F)
         end
         % Look for syntax F(...,SYS) where SYS is an @lti model
         ConstructFlag = (isys>1);
         if ConstructFlag
            InputList{isys} = getSettings(InputList{isys});
         end
      end
      
   end
      
end

%----------------------- Local Functions ---------------------------------

function [g, GChannelsModified, GNamesModified]  = LocalGroupUpdate(g)
% Update groups to account for new restrictions with struct-based groups

% Boolean variables to determine if repeated i/o channels and names are
% modified during update
GChannelsModified = false;
GNamesModified  = false;

ng = size(g,1);
if isa(g,'struct')
   return
elseif ng==0
   % Migrate to struct when no group specified
   g = struct;
   return
elseif size(g,2)==1
   g(:,2) = {''};
end

% Remove multiplicity of group channels and spaces in group name
for cnt = 1:ng
    gcurrent = g{cnt,1};
    [gunique, gidx] = unique(gcurrent);
    if length(gunique) < length(gcurrent)
        gnew = gcurrent(sort(gidx));
        g{cnt,1} = gnew;
        GChannelsModified = true;
    end
    if ~isempty(findstr(g{cnt,2},' '))
        g{cnt,2} = regexprep(g{cnt,2},' ','_');
        GNamesModified  = true;
    end
end
    
idxNoName = find(cellfun('length',g(:,2))==0);
if ~isempty(idxNoName)
   % Clear names starting with group
   g(:,strncmp(g(:,2),'Group',5)) = {''};
   idxNoName = find(cellfun('length',g(:,2))==0);
end
for ct=1:length(idxNoName)
   g{idxNoName(ct),2} = sprintf('Group%d',ct);
end
end

