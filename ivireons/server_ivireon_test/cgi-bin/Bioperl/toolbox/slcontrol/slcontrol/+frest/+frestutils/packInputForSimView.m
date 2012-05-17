function [src,cursel] = packInputForSimView(simout,in,sysest,sysComp) 
% PACKINPUTFORSIMVIEW  Pack the input for simView in a SimviewSource and
% determine the initial selection
%
 
% Author(s): Erman Korkut 16-Jul-2009
% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2009/11/09 16:35:02 $

% Simout should be a cell array of Simulink.Timeseries objects.
if ~iscell(simout)
    ctrlMsgUtils.error('Slcontrol:frest:SimViewSimoutNotCellArrayOfSimulinkTs') 
end
type = cellfun(@class,simout,'UniformOutput',false);
if ~all(strcmp('Simulink.Timeseries',type(:)))
    ctrlMsgUtils.error('Slcontrol:frest:SimViewSimoutNotCellArrayOfSimulinkTs') 
end
% In should be one of the offered types or a MATLAB timeseries
if ~(isa(in,'timeseries') || isa(in,'frest.Sinestream') ||...
        isa(in,'frest.Chirp') || isa(in,'frest.Random'))
    ctrlMsgUtils.error('Slcontrol:frest:SimViewInvalidInput')     
end

% Place input & output data in your the Source object
% Handle input dependent settings here
if isa(in,'frest.Sinestream')
    src = frestviews.SinestreamSource(in);
    cursel = round(numel(in.Frequency)/2);
    insig = generateTimeseries(in);
    numsamps = insig.Length;
    % Initialize the filter showing property based on ApplyFilteringInFESTIMATE
    src.ShowFilteredOutput = in.ApplyFilteringInFRESTIMATE;
else
    src = frestviews.SimviewSource;
    % Specify initial range to be between full input for non-sinestream
    if isa(in,'frest.Chirp') || isa(in,'frest.Random') 
        numsamps = in.NumSamples;
    else
        numsamps = in.Length;
    end
    % Select everything for random and custom
    cursel = [1 numsamps];
end
src.Input = in;
src.Output = frest.frestutils.flattenSimulationOutput(simout,numsamps);

% Check that there are as many samples in the output as in the input
for ct = 1:numel(src.Output)
    if numsamps ~= numel(src.Output{ct}.Time)
        ctrlMsgUtils.error('Slcontrol:frest:SimViewInputOutputSizeMismatch'); 
    end
end

% Check that sysest is an FRD-object
if ~isa(sysest,'frd')
    ctrlMsgUtils.error('Slcontrol:frest:SimViewInvalidSystem');   
end

% Make sure sysComp is an LTI or FRD.
if ~isempty(sysComp) && ~any(strcmp(class(sysComp),{'tf';'ss';'zpk';'frd'}))
    ctrlMsgUtils.error('Slcontrol:frest:SimViewInvalidSystemToCompare');
end

% Make sure system size of sysest and sys to compare against is compatible
if ~isempty(sysComp)
    sizeSysComp = size(sysComp);
    sizeSysEst = size(sysest);
    if ~isequal(sizeSysEst(1:2),sizeSysComp(1:2))
        ctrlMsgUtils.error('Slcontrol:frest:SimViewSystemSizeMismatch');        
    end
end
