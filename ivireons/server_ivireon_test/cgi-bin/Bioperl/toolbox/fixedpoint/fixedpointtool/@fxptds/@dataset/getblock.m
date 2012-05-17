function [d, blk] = getblock(h, d) %#ok<INUSL>
%GETBLOCK   Get the block.
%find the daobject that this data or path belongs to. modify the path for
%Stateflow objects. they can contain '.' chars and we need to change them
%to '/' there are 4 cases (so far) that are handled here
% 1. dataID isempty and a Simulink block was found
% 2. dataID isempty and data is for a logged Stateflow signal.
% 3. dataID ~isempty and data is for a Stateflow object
% 4. nothing is found

%   Author(s): G. Taillefer
%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2010/05/20 02:18:11 $


dataID = [];
blk = [];

if(isfield(d, 'Block'))
  blk = d.Block;
  return;
end

if(isfield(d, 'dataID'))
  dataID = d.dataID;
end
%If this is not MinMaxOverflow data for Stateflow
if(isempty(dataID))
  %If this is a model reference signal we need to pass back a reference to
  %the model. The signal is pointing to the block.
  if(isfield(d,'isMdlRef') && d.isMdlRef)
    try
      blk = fxptds.getMdlrefObject(d);
      mdlref = get_param(d.ModelReference, 'Object');
      d.ModelReference = mdlref;
    catch fpt_exception %#ok<NASGU> % We do not want to throw this exception.
      %if the model is not open this section will error
    end
    return;
  end
  try
    %try finding Simulink object (get_param errors if path not found)
    blk = get_param(fxptds.getpath(d.Path), 'Object');
    %if this is a Stateflow masked subsystem get the Chart that it wraps
    if(fxptui.issfmaskedsubsystem(blk))
        %Find the SF object that the blk points to.
        blk = fxptui.sfchartnode.getSFChartObject(blk);
        return;
    end
  catch fpt_exception %#ok<NASGU> % We do not want to throw this exception.
    %if get_param errored this may be a Stateflow logged signal
    %try finding Stateflow object (logged Stateflow signal i.e. no dataID)
    [blk,pth,name] = fxptds.getSfObject(d);
    % array concat is much faster than strcat.
    d.Path = [pth '/' name];
  end
else
  % this is using the overloaded UDD find method and not the built-in
  % method
  blk = find(sfroot, '-isa', 'Stateflow.Object', 'ID', dataID); %#ok<GTARG> 
end

%--------------------------------------------------------------------------


% [EOF]
