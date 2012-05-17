function ios = getlinio(model)
%GETLINIO Get linearization I/O settings for Simulink model.
%
%   IO = GETLINIO('sys') Finds all linearization annotations in a Simulink
%   model, 'sys'.  The vector of objects returned from this function call
%   has an entry for each linearization annotation in a model.
%
%   IO = getlinio('sys/subsys/blk') Finds the linearization ports used by
%   the linear analysis check block 'blk'. The vector of objects returned
%   from this function call has an entry for each linearization port used
%   by the block.
%
%   Usage:
%   1. Right click on the lines of a Simulink model to specify linearization
%      I/O points including loop openings.
%   2. At the command line run the function:
%      >> io = getlinio('f14')
%   3. A formatted display of the linearization I/Os can be obtained by the
%      following syntax
%      >> io
%
%       Linearization IOs:
%   --------------------------
%   Block f14/u, Port 1 is marked with the following properties:
%    - No Loop Opening
%    - An Input Perturbation
%
%   Block f14/Gain5, Port 1 is marked with the following properties:
%    - An Output Measurement
%    - No Loop Opening
%
%   4. There is the ability to adjust the linearization points by setting object
%      properties.
%      >> set(io(1),'Type','out');
%
%   I/O Object properties:
%
%   Active ('on','off')   - Flag to set if this I/O will be used for
%                           linearization.
%   Block  (string)       - The block that this I/O is referenced.
%   OpenLoop ('on','off') - Flag to set if this I/O has a loop opening.
%   PortNumber (int)      - The output port that this I/O is referenced.
%   Type                  - Sets the linearization I/O type. See the
%                           available types below.
%   Description           - String description of the I/O object
%
%   Available linearization I/O types are:
%       'in', linearization input point
%       'out', linearization output point
%       'inout', linearization input then output point
%       'outin', linearization output then input point
%       'none', no linearization input/output point
%
%   You can edit this I/O object to change its properties. Alternatively,
%   you can change the properties of io using the set function. To upload
%   an edited I/O object to the Simulink model diagram, use the SETLINIO
%   function. Use I/O objects with the function linearize to create linear
%   models.
%
%   See also LINIO, SETLINIO

%  Author(s): John Glass
%  Revised:

%   Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.6.15.2.1 $ $Date: 2010/06/17 14:13:50 $

%Split input argument into model and block path
[mdl,block] = strtok(model,'/');

if isempty(block)
   % Make sure that the models are open
   ModelParameterMgr = linearize.ModelLinearizationParamMgr.getInstance(model);
   ModelParameterMgr.loadModels;
   models = getUniqueNormalModeModels(ModelParameterMgr);
   ios = linearize.getModelIOPoints(models);

   % Close the models that have not been loaded.
   ModelParameterMgr.closeModels;
else
   %Looking for IOs defined in a model check block
   if isempty(find_system('SearchDepth',0,'CaseSensitive','off','Name',mdl))
      load_system(mdl)
      loadedModel = true;
   else
      loadedModel = false;
   end
   try
      ioStr = get_param(model,'LinearizationIOs');
   catch E
      ctrlMsgUtils.error('Slcontrol:linearize:ErrorNotFreqCheckBlock','getlinio(blkname)')
   end
   try
      ios = slResolve(ioStr,model);
   catch E
      ctrlMsgUtils.error('Slcontrol:linearize:ErrorInvalidCheckBlockIOs',model)
   end
   if ~isa(ios,'linearize.IOPoint')
      %Should have a cell array describing IO points
      try
         ioData = ios;
         ios = [];
         for ct = 1:size(ioData,1)
            blkPath = ioData{ct,1};
            if ~strncmp(blkPath,mdl,length(mdl))
               blkPath = sprintf('%s%s',mdl,blkPath);
            end
            ios = vertcat(ios, ...
               linio(blkPath,ioData{ct,2},ioData{ct,3}, ioData{ct,4}));
         end
      catch E
         ctrlMsgUtils.error('Slcontrol:linearize:ErrorInvalidCheckBlockIOs',model)
      end
   end
   if loadedModel
      close_system(mdl);
   end
end