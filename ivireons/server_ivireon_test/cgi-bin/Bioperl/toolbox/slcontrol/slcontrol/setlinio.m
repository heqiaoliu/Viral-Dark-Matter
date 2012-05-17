function [oldio,iovalid] = setlinio(model,ios,varargin)
%SETLINIO Assign I/O settings to Simulink model.
%
%   OLDIO=SETLINIO('sys',IO) assigns the settings in the vector of 
%   linearization I/O objects, IO, to the Simulink model, 'sys', where 
%   they are represented by annotations on the signal lines. You can save 
%   I/O objects to disk in a MAT-file and use them later to restore 
%   linearization settings in a model.
%
%   OLDIO=SETLINIO('sys/subsys/blk',IO) assigns the settings in the vector
%   of linearization I/O objects, IO, to the linear analysis check block,
%   'blk'.
%
%   Use the function GETLINIO or LINIO to create the linearization I/O objects. 
%
%   See also LINIO, GETLINIO

%  Author(s): John Glass
%  Revised:
%  Copyright 1986-2010 The MathWorks, Inc.
%  $Revision: 1.1.6.17 $ $Date: 2010/04/30 00:43:35 $

%Split input argument into model and block path
[mdl,block] = strtok(model,'/');

if ~isempty(ios) && ~isa(ios,'linearize.IOPoint')
   ctrlMsgUtils.error('Slcontrol:linearize:ErrorLINIOobject');
end

if isempty(block)
   % Set IOs on the model
   
   % Create the model parameter manager to ensure that all the models are
   % loaded.  Leave all models open since the port properties are being set.
   ModelParameterMgr = linearize.ModelLinearizationParamMgr.getInstance(model);
   ModelParameterMgr.loadModels
   models = ModelParameterMgr.getUniqueNormalModeModels;
   [oldio,iovalid] = linearize.setModelIOPoints(models,ios,varargin{:});
else
   %Set IOs on a model check block
   if isempty(find_system('SearchDepth',0,'CaseSensitive','off','Name',mdl))
      load_system(mdl)
   end
   %Make sure block has LinearizationIOs property
   try
      get_param(model,'LinearizationIOs');
   catch E
      ctrlMsgUtils.error('Slcontrol:linearize:ErrorNotFreqCheckBlock','setlinio(blkname,ios)')
   end
   %Check that passed IOs are valid
   localCheckIOs(mdl,ios);
   
   %Get the current IO settings to return as old values
   try
      oldio = getlinio(model);
   catch E %#ok<NASGU>
      oldio = [];
   end
   %Push the new ios to the block
   str = localSerializeIOs(mdl,ios);
   set_param(model,'LinearizationIOs',str);
   
   %If the block dialog is open update it
   hBlk = get_param(model,'Object');
   dlgs = hBlk.getDialogSource.getOpenDialogs;
   if ~isempty(dlgs)
      dlgs{1}.getSource.isIOModifiedByDlg = false; %Ensures dialog gest data from block not dialog cache
      dlgs{1}.refresh
   end
end
end

function str = localSerializeIOs(mdl,data)
%Helper function to serialize linio object for storage as a check block
%parameter.

str   = '{';
nrows = numel(data);
for ct = 1:nrows
   blkPath = data(ct).Block;
   blkPath = regexprep(blkPath,strcat('^',mdl),'');  %Store block path relative to model
   str = sprintf('%s''%s'', %d, ''%s'', ''%s''',str,...
      blkPath, data(ct).PortNumber, data(ct).Type, data(ct).OpenLoop);
   if ct < nrows
      str = sprintf('%s;',str);
   end
end
str = sprintf('%s}',str);
end

function localCheckIOs(model,ios)
% Helper function to check that the IOs specified by the block are valid

[~, invalidIO] = linearize.checkModelIOPoints({model},ios);
nIO = numel(invalidIO);
if nIO > 0
   str = sprintf('%s:%d', invalidIO(1).Block, invalidIO(1).PortNumber);
   for ct=2:nIO
     str = sprintf('%s, %s:%s', str, invalidIO(ct).Block, invalidIO(ct).PortNumber); 
   end
   ctrlMsgUtils.error('Slcontrol:linearize:ErrorSetlinioBlkIOs',str);
end
end