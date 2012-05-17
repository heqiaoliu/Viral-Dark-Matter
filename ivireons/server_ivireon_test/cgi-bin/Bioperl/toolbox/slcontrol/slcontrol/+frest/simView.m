function varargout = simView(simout,in,sysest,varargin)
% SIMVIEW views the simulation results of FRESTIMATE command simout
% obtained with the input signal in.
%
%   frest.simView(simout,in,sysest) takes the simulation results of FRESTIMATE
%   command simout, the input signal used in FRESTIMATE in and the
%   estimated system results of FRESTIMATE command sysest and the plots them 
%   in simview figure. If the input signal is a frest.Sinestream or
%   frest.Chirp object, the figure has a summary view which shows estimated
%   system in a bode plot and gives the ability to interactively select
%   frequencies or a frequency range to view the results. The results are
%   shown both in time domain and frequency domain.
%
%   frest.simView(simout,in,sysest,sys) shows the LTI system sys in summary
%   pane bode plot against the estimation result sysest if the input signal
%   in is either a frest.Sinestream or a frest.Chirp input signal.
%
%
%   See also frest.simViewOptions, frestimate, frest.Sinestream

%  Author(s): Erman Korkut 05-Mar-2009
%  Revised:
%  Copyright 2003-2009 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2009/08/08 01:18:36 $

% Error checking
% Check number of input & output arguments
error(nargchk(3,5,nargin));
error(nargoutchk(0,1,nargout));

% Parse optional inputs
plotopts = [];sysComp = [];
for ct = 1:numel(varargin)
    var = varargin{ct};
    if isa(var,'frestviews.SimviewOptions')
        plotopts = var;
    elseif any(strcmp(class(var),{'tf';'ss';'zpk';'frd'}))
        sysComp = var;
    else
        % Error
        ctrlMsgUtils.error('Slcontrol:frest:SimViewInvalidSystemToCompare');
    end
end
% Create options if not specified
if isempty(plotopts)
    plotopts = matchFreqUnitsWithInput(frest.simViewOptions,in);    
elseif ~any(strcmp(class(in),{'frest.Sinestream','frest.Chirp'})) && ...
        strcmp(plotopts.SummaryVisible,'on')
    % Throw the warning that some options will be ignored
    ctrlMsgUtils.warning('Slcontrol:frest:SimviewOptionsIgnored');    
end

% Pre-process the inputs
[src,cursel] = frest.frestutils.packInputForSimView(simout,in,sysest,sysComp);

% Create the new figure
hfig = figure('IntegerHandle','off',...
    'NumberTitle','off',...
    'HandleVisibility','callback',...
    'Toolbar','none',...
    'Menu','none',...
    'Units','pixels',...
    'Visible','off',...
    'Name',ctrlMsgUtils.message('Slcontrol:frest:SimviewFigureTitle'));

% Make the figure 50 pixels taller than default size
set(hfig,'Position',get(hfig,'Position')+[0 -50 0 50]);

% Create the simView GUI
p = frestviews.SimviewPlot(hfig,sysest,src,plotopts,cursel,sysComp);

% Add toolbar
toolbar(p);

% Pack the input arguments to be used with <current> tag in Import dialog.
p.InputVariables = struct('SimulationOutput',{simout},...
                          'SimulationInput',in,...
                          'EstimationResult',sysest,...
                          'SysToCompareAgainst',sysComp);
% Return the handle if requested                                                
if nargout > 0
    varargout{1} = p;
end

end