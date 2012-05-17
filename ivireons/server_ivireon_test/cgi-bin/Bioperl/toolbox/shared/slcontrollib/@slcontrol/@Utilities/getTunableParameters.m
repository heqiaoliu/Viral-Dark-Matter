function TunablePars = getTunableParameters(this, model) %#ok<INUSL>
% GETTUNABLEPARAMETERS Gets the list of tunable parameters in the model and
% the blocks that refer to them.
%
% Returns a struct array with fields Name, Type, and ReferencedBy.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.6.8 $ $Date: 2010/01/25 22:41:28 $


%Get all base and model workspace variables used by model
Vars = vertcat(...
   Simulink.findVars(model,'WorkspaceType','base'), ...
   Simulink.findVars(model,'WorkspaceType','model'));
%Find the class of each variable, tackle base workspace first
S = evalin('base', 'whos');
idx = strcmp({Vars.WorkspaceType},'base');

TunablePars = struct(...
   'Name', {Vars(idx).Name}, ...
   'Type', [], ...
   'WorkspaceType', 'base', ...
   'Workspace', {Vars(idx).Workspace}, ...
   'ReferencedBy', {Vars(idx).UsedByBlocks});

[~, ia, ib] = intersect( {S.name}, {TunablePars.Name} );
for ct = 1:length(ia)
   TunablePars(ib(ct)).Type = S(ia(ct)).class;
end

%Tackle model workspace variables
idx = strcmp({Vars.WorkspaceType},'model');
mwksp = unique({Vars(idx).Workspace});
for ctWksp = 1:numel(mwksp)
   wksp = get_param(mwksp{ctWksp},'ModelWorkspace');
   S = whos(wksp);
   idx =strcmp({Vars.Workspace},mwksp{ctWksp});

   TP = struct(...
      'Name', {Vars(idx).Name}, ...
      'Type', [], ...
      'WorkspaceType', 'model', ...
      'Workspace', mwksp{ctWksp}, ...
      'ReferencedBy', {Vars(idx).UsedByBlocks});
   
   [~, ia, ib] = intersect( {S.name}, {TP.Name});
   for ct = 1:length(ia)
      TP(ib(ct)).Type = S(ia(ct)).class;
   end
   TunablePars = horzcat(TunablePars,TP); %#ok<AGROW>
end
end
