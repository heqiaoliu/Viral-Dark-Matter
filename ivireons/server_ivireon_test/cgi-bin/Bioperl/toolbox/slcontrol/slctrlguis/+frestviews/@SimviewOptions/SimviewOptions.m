classdef SimviewOptions
% SCHEMA Class definition for @SimviewOptions (the option set for simview
% figure)

% Author(s): Erman Korkut 12-Mar-2009
% Revised:
% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.10.3 $ $Date: 2009/08/08 01:19:09 $

%% PUBLIC PROPERTIES
properties
    % Visibilities of main plots
    TimeVisible = 'on'
    SpectrumVisible = 'on'
    SummaryVisible = 'on'
    % Time Plot
    TimeGrid = 'off';
    % Spectryum Plot
    SpectrumGrid = 'off';
    SpectrumAmpUnits = 'abs'
    SpectrumAmpScale = 'linear'
    SpectrumFreqUnits = 'rad/s'   
    SpectrumFreqScale = 'linear'
    % Summary Plot
    SummaryGrid = 'off';
    SummaryMagVisible = 'on'
    SummaryPhaseVisible = 'off'
    SummaryMagUnits = 'dB'
    SummaryFreqUnits = 'rad/s'
    SummaryPhaseUnits = 'deg'             
    SummaryMagScale = 'linear'  
    SummaryPhaseScale = 'linear'
    SummaryFreqScale = 'log'
    SummaryPhaseWrapping = 'off'    
end

methods
    % Constructor
    function obj = SimviewOptions(varargin)
        for ct = 1:length(varargin)/2
            try
                obj.(varargin{2*ct-1}) = varargin{2*ct};
            catch Me
                if strcmp(Me.identifier,'MATLAB:noPublicFieldForClass')
                    % Invalid parameter specified
                    ctrlMsgUtils.error('Slcontrol:frest:InvalidParameterSimviewOptions',varargin{2*ct-1});
                else
                    rethrow(Me)
                end
            end
        end
        LocalCheckConsistencyBetweenMagUnitsAndScale(obj);
    end
    % Display and disp
    function display(this)
        disp(' ');
        if usejava('Swing') && desktop('-inuse') && feature('hotlinks')
            disp(ctrlMsgUtils.message('Slcontrol:frest:SimviewOptionsWithHelpLink'));
        else
            disp(ctrlMsgUtils.message('Slcontrol:frest:SimviewOptions'));
        end
        disp(' ');
        disp(ctrlMsgUtils.message('Slcontrol:frest:SimviewOptionsForTime'));
        fprintf('      TimeVisible (on/off)            : %s\n', this.TimeVisible);
        fprintf('      TimeGrid    (off/on)            : %s\n', this.TimeGrid);
        disp(ctrlMsgUtils.message('Slcontrol:frest:SimviewOptionsForSpectrum'));
        fprintf('      SpectrumVisible (on/off)        : %s \n',this.SpectrumVisible);
        fprintf('      SpectrumAmpUnits (abs,dB)       : %s\n',this.SpectrumAmpUnits);
        fprintf('      SpectrumFreqUnits (rad/s,Hz)    : %s\n',this.SpectrumFreqUnits);
        fprintf('      SpectrumAmpScale (linear,log)   : %s\n',this.SpectrumAmpScale);
        fprintf('      SpectrumFreqScale (linear,log)  : %s\n',this.SpectrumFreqScale);
        fprintf('      SpectrumGrid (off/on)           : %s\n', this.SpectrumGrid);
        disp(ctrlMsgUtils.message('Slcontrol:frest:SimviewOptionsForSummary'));
        fprintf('      SummaryVisible (on/off)         : %s\n', this.SummaryVisible);
        fprintf('      SummaryMagVisible (on/off)      : %s\n', this.SummaryMagVisible);
        fprintf('      SummaryPhaseVisible (off/on)    : %s\n', this.SummaryPhaseVisible);
        fprintf('      SummaryMagUnits (abs,dB)        : %s\n',this.SummaryMagUnits);
        fprintf('      SummaryFreqUnits (rad/s,Hz)     : %s\n',this.SummaryFreqUnits);
        fprintf('      SummaryPhaseUnits (deg,rad)     : %s\n',this.SummaryPhaseUnits);
        fprintf('      SummaryMagScale (linear,log)    : %s\n',this.SummaryMagScale);
        fprintf('      SummaryFreqScale (log,linear)   : %s\n',this.SummaryFreqScale);
        fprintf('      SummaryPhaseWrapping (off/on)   : %s\n',this.SummaryPhaseWrapping);
        fprintf('      SummaryGrid (off/on)            : %s\n', this.SummaryGrid);
        disp(' ');
    end
    % matchFreqUnitsWithInput
    function obj = matchFreqUnitsWithInput(obj,in)        
        % MATCHFREQUNITSWITHINPUT updates the FreqUnits in the simview options
        % object according to the input signal in.
        if isa(in,'frest.Sinestream') || isa(in,'frest.Chirp')
            % Set frequency units accordingly.
            obj.SpectrumFreqUnits = in.FreqUnits;
            obj.SummaryFreqUnits = in.FreqUnits;
        end
    end
    function disp(this)
        display(this)
    end
    %% Get methods for dependent properties
    
    %% Set methods of properties for individual error checking
    % All on/off properties go through LocalSetOnOff
    function obj = set.SpectrumVisible(obj,val)
        LocalCheckOnOff(obj,'SpectrumVisible',val);
        obj.SpectrumVisible = val;
    end
    function obj = set.TimeVisible(obj,val)
        LocalCheckOnOff(obj,'TimeVisible',val);
        obj.TimeVisible = val;
    end
    function obj = set.SummaryVisible(obj,val)
        LocalCheckOnOff(obj,'SummaryVisible',val);
        obj.SummaryVisible = val;
    end
    function obj = set.SummaryMagVisible(obj,val)
        LocalCheckOnOff(obj,'SummaryMagVisible',val);
        obj.SummaryMagVisible = val;
    end
    function obj = set.SummaryPhaseVisible(obj,val)
        LocalCheckOnOff(obj,'SummaryPhaseVisible',val);
        obj.SummaryPhaseVisible = val;
    end
    % Grids
    function obj = set.TimeGrid(obj,val)
        LocalCheckOnOff(obj,'TimeGrid',val);
        obj.TimeGrid = val;
    end
    function obj = set.SpectrumGrid(obj,val)
        LocalCheckOnOff(obj,'SpectrumGrid',val);
        obj.SpectrumGrid = val;
    end
    function obj = set.SummaryGrid(obj,val)
        LocalCheckOnOff(obj,'SummaryGrid',val);
        obj.SummaryGrid = val;
    end    
    % All scale properties go through LocalSetScale
    function obj = set.SpectrumAmpScale(obj,val)
        LocalCheckScale(obj,'SpectrumAmpScale',val);
        obj.SpectrumAmpScale = val;
        LocalCheckConsistencyBetweenMagUnitsAndScale(obj);
    end
    function obj = set.SpectrumFreqScale(obj,val)
        LocalCheckScale(obj,'SpectrumFreqScale',val);
        obj.SpectrumFreqScale = val;
    end
    function obj = set.SummaryMagScale(obj,val)
        LocalCheckScale(obj,'SummaryMagScale',val);
        obj.SummaryMagScale = val;
        LocalCheckConsistencyBetweenMagUnitsAndScale(obj);
    end
    function obj = set.SummaryFreqScale(obj,val)
        LocalCheckScale(obj,'SummaryFreqScale',val);
        obj.SummaryFreqScale = val;
    end
    function obj = set.SummaryPhaseScale(obj,val)
        LocalCheckScale(obj,'SummaryPhaseScale',val);
        obj.SummaryPhaseScale = val;
    end
    % FreqUnits
    function obj = set.SpectrumFreqUnits(obj,val)
        if ~any(strcmp(val,{'rad/s','Hz'}))
            ctrlMsgUtils.error('Slcontrol:frest:InvalidFreqUnitsSimviewoptions');
        end
        obj.SpectrumFreqUnits = val;
    end
    function obj = set.SummaryFreqUnits(obj,val)
        if ~any(strcmp(val,{'rad/s','Hz'}))
            ctrlMsgUtils.error('Slcontrol:frest:InvalidFreqUnitsSimviewoptions');
        end
        obj.SummaryFreqUnits = val;
    end
    % MagUnits
    function obj = set.SummaryMagUnits(obj,val)
        if ~any(strcmp(val,{'abs','dB'}))
            ctrlMsgUtils.error('Slcontrol:frest:InvalidMagUnitsSimviewoptions');
        end
        obj.SummaryMagUnits = val;
        LocalCheckConsistencyBetweenMagUnitsAndScale(obj);
    end
    function obj = set.SpectrumAmpUnits(obj,val)
        if ~any(strcmp(val,{'abs','dB'}))
            ctrlMsgUtils.error('Slcontrol:frest:InvalidMagUnitsSimviewoptions');
        end
        obj.SpectrumAmpUnits = val;
        LocalCheckConsistencyBetweenMagUnitsAndScale(obj);
    end
    % PhaseUnits
    function obj = set.SummaryPhaseUnits(obj,val)
        if ~any(strcmp(val,{'deg','rad'}))
            ctrlMsgUtils.error('Slcontrol:frest:InvalidPhaseUnitsSimviewoptions');
        end
        obj.SummaryPhaseUnits = val;
    end
    % Phase Unwrapping
    function obj = set.SummaryPhaseWrapping(obj,val)
        LocalCheckOnOff(obj,'SummaryPhaseUnwrapping',val);
        obj.SummaryPhaseWrapping = val;
    end
    
    
end
    
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalCheckOnOff
%  Error check for on/off properties
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obj = LocalCheckOnOff(obj, field, val)
if ~any(strcmp(val,{'on','off'}))
    ctrlMsgUtils.error('Slcontrol:frest:InvalidOnOffSimviewoptions',field)
end
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalCheckScale
%  Error check for scale properties: linear/log
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obj = LocalCheckScale(obj,field,val)
if ~any(strcmp(val,{'linear','log'}))
    ctrlMsgUtils.error('Slcontrol:frest:InvalidScaleSimviewoptions',field)
end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalCheckConsistencyBetweenMagUnitsAndScale
%  Error check for setting log scale when units is abs already
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalCheckConsistencyBetweenMagUnitsAndScale(obj)
% Check for spectrum
if strcmp(obj.SpectrumAmpUnits,'dB') && strcmp(obj.SpectrumAmpScale,'log')
    ctrlMsgUtils.error('Slcontrol:frest:InvalidSpectrumAmpScaleMismatch')
end
% Check for summary    
if strcmp(obj.SummaryMagUnits,'dB') && strcmp(obj.SummaryMagScale,'log')
    ctrlMsgUtils.error('Slcontrol:frest:InvalidSummaryMagScaleMismatch')
end
end



