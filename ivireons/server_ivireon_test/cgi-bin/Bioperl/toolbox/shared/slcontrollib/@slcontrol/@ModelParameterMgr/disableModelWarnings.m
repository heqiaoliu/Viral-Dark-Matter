function disableModelWarnings(this)
% DISABLEMODELWARNINGS
 
% Author(s): John W. Glass 06-Feb-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1.10.1 $ $Date: 2010/06/28 14:19:31 $

if isempty(this.OrigConfigSet) && isempty(this.OrigDirty)
    models = this.getModels;
    isdirty = cell(size(models));
    activeConfig = handle(NaN(size(models)));
    for ct = numel(models):-1:1
        % Get the dirty flag
        isdirty{ct} = get_param(models{ct},'Dirty');
        % Get the old configuration set and turn off warnings
        activeConfig(ct) = setNonSimWarningOff(slcontrol.Utilities,models{ct});
    end
    this.OrigConfigSet = activeConfig;
    this.OrigDirty = isdirty;
end