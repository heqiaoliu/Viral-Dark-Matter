function sys = linearize(this,Oppoint,Ports,Linoptions)
% LINEARIZE  method to return a linear model (defined by the ports 
% argument) from a SISOTOOL model object
%
% sys = this.linearize(Oppoint,Ports,LinOptions)
%
% Input:
%    Oppoint    - an operating point object, as SISOTOOL only supports linear
%                 systems this input is ignored and a zero-point operating point 
%                 assumed.
%    Ports      - an optional vector of linearizationID objects that define the linear
%                 system. This vector must contain at least one input and one output 
%                 port. If omitted the full SISOTOOL closed loop model is
%                 returned.
%    Linoptions - an optional linoptions object, as SISOTOOL only supports
%                 linear systems this input is ignored.
%
 
% Author(s): A. Stothert 25-Jul-2005
% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2009/04/21 04:28:32 $

%Check number of arguments
if nargin < 2 || nargin > 4
   ctrlMsgUtils.error('SLControllib:modelpack:errNumArguments','1 to 3')
end

%Check input argument types
if (nargin > 2) 
   if ~isempty(Ports) && ~isa(Ports,'modelpack.STPortID');
      ctrlMsgUtils.error('SLControllib:modelpack:errArgumentType','Ports','modelpack.STLinearizationID')
   end
else
   Ports = [];
end

%Find the ports & path defining the linear model
if isempty(Ports)
   %No ports defined, default to returning whole system
   Path     = '';
   namesIn  = {};
   namesOut = {};
else
   %Find input and output ports
   Paths = Ports.getPath;
   %Make sure have consistent port paths
   if ~all(strcmp(Paths,Paths{1}))
      ctrlMsgUtils.error('SLControllib:modelpack:stErrorLinearizePortPaths')
   else
      Path = Paths{1};
   end
   Names = Ports.getName;
   Names = regexprep(Names,':1$',''); %Remove port number as always 1
   Type  = Ports.getType;
   idxI  = strcmp(Type,'Input')  | strcmp(Type,'OutIn');
   idxO  = strcmp(Type,'Output') | strcmp(Type,'OutIn');
   namesIn  = {Names{idxI}};
   namesOut = {Names{idxO}};
   
   %Check that have at least one input and one output
   if isempty(namesIn) || isempty(namesOut)
      ctrlMsgUtils.error('SLControllib:modelpack:stErrorInputOutputPort')
   end
end

if ~isempty(Path)
   %Want system from TunedLoop or TunedBlock, can ignore port names
   idx = strcmp(get(this.Model.C,'Identifier'),Path);
   if any(idx)
      obj = this.Model.C(idx).zpk;
   else
      %Check TunedLoop as no TunedBlock found
      idx = strcmp(get(this.Model.L,'Identifier'),Path);
      if any(idx)
         obj = this.Model.L(idx).getModel;
      end
   end
else
   %Want base level system, need to use port names
   obj = this.Model.getclosedloop(namesOut,namesIn);
end

if isempty(obj)
   ctrlMsgUtils.error('SLControllib:modelpack:stErrorLinearizePortDetails');
else
   %Convert ssdata object into state-space model
   sys = utCreateLTI(obj);
end

