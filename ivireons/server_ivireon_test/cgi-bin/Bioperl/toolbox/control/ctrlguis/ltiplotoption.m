function p = ltiplotoption(PlotType,OptionsObject,Pref,NewRespPlot,h)
%LTIPLOTOPTION creates an appropriate plot options object.
%
%  The plotoption p returned is based on the state of NewRespPlot.
% 
%  Inputs:
%   PlotType = Plot type such as bode, etc.
%   OptionsObject = [] or a PlotOptions object
%   Pref = Preference object (tbxprefs or viewprefs)
%   NewRespPot = boolean true if plot is a new respplot
%   h = respplot handle or empty
%
%  Outputs:
%  p = PlotOptions Object
%  NewPlot = true if ax nexplot property is replace
%  h = [] or handle to resppack object

%  Copyright 1986-2006 The MathWorks, Inc.
%  $Revision: 1.1.6.6 $   $Date: 2006/11/17 13:24:18 $

% Create Options Object
if NewRespPlot
    % New respplot
    updateflag = true;
    switch PlotType
        case 'bode'
            if isa(OptionsObject,'plotopts.BodePlotOptions')
                p = OptionsObject;
                updateflag = false;
            else
                p = plotopts.BodePlotOptions;
            end
        case 'hsv'
            if isa(OptionsObject,'plotopts.HSVPlotOptions')
                p = OptionsObject;
                updateflag = false;
            else
                p = plotopts.HSVPlotOptions;
            end
        case 'impulse'
            if isa(OptionsObject,'plotopts.TimePlotOptions')
                p = OptionsObject;
                updateflag = false;
            else
                p = plotopts.TimePlotOptions;
                p.Title.String = xlate('Impulse Response');
            end
        case 'initial'
            if isa(OptionsObject,'plotopts.TimePlotOptions')
                p = OptionsObject;
                updateflag = false;
            else
                p = plotopts.TimePlotOptions;
                p.Title.String = xlate('Response to Initial Conditions');
            end
        case 'iopzmap'
            if isa(OptionsObject,'plotopts.PZMapOptions')
                p = OptionsObject;
                updateflag = false;
            else
                p = plotopts.PZMapOptions;
            end
        case 'lsim'
            if isa(OptionsObject,'plotopts.TimePlotOptions')
                p = OptionsObject;
                updateflag = false;
            else
                p = plotopts.TimePlotOptions;
                p.Title.String = xlate('Linear Simulation Results');
            end
        case 'nichols'
            if isa(OptionsObject,'plotopts.NicholsPlotOptions')
                p = OptionsObject;
                updateflag = false;
            else
                p = plotopts.NicholsPlotOptions;
            end
        case 'nyquist'
            if isa(OptionsObject,'plotopts.NyquistPlotOptions')
                p = OptionsObject;
                updateflag = false;
            else
                p = plotopts.NyquistPlotOptions;
            end
        case 'pzmap'
            if isa(OptionsObject,'plotopts.PZMapOptions')
                p = OptionsObject;
                updateflag = false;
            else
                p = plotopts.PZMapOptions;
            end
        case 'rlocus'
            if isa(OptionsObject,'plotopts.PZMapOptions')
                p = OptionsObject;
                updateflag = false;
            else
                p = plotopts.PZMapOptions;
                p.Title.String = xlate('Root Locus');
            end
        case 'sigma'
            if isa(OptionsObject,'plotopts.SigmaPlotOptions')
                p = OptionsObject;
                updateflag = false;
            else
                p = plotopts.SigmaPlotOptions;
            end
        case 'step'
            if isa(OptionsObject,'plotopts.TimePlotOptions')
                p = OptionsObject;
                updateflag = false;
            else
                p = plotopts.TimePlotOptions;
                p.Title.String = xlate('Step Response');
            end

    end

    % Update default options object 
    if updateflag
        mapCSTPrefs(p,Pref);
        if ~isempty(OptionsObject)
            p = copyPlotOptions(p,OptionsObject);
        end
    end

else
    % Not a new respplot
    % get current plotoptions
    p = getoptions(h);
end
