function hmenu = lticharmenu(hplot, mChar, plotType)
% LTICHARMENU   Adds response characteristic menus for LTI plots.
%
% Create a group of characteristic submenu items appropriate for the plotType.
% Parent these menus to the previously created context menu mChar. Note hplot
% is a @respplot object.

% Author(s): James Owen
% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.25.4.5 $ $Date: 2006/09/30 00:16:52 $

% Add classes to be included for compiler for CST plots
%#function resppack.TimeFinalValueData
%#function resppack.TimeFinalValueView
%#function resppack.StepPeakRespData
%#function resppack.StepPeakRespView
%#function resppack.SettleTimeView
%#function resppack.StepRiseTimeData
%#function resppack.StepRiseTimeView
%#function resppack.StepSteadyStateView
%#function wavepack.TimePeakAmpData 
%#function wavepack.TimePeakAmpView
%#function resppack.SettleTimeData
%#function resppack.SimInputPeakView
%#function wavepack.FreqPeakGainData
%#function wavepack.FreqPeakGainView
%#function resppack.MinStabilityMarginData
%#function resppack.BodeStabilityMarginView
%#function resppack.AllStabilityMarginData
%#function resppack.BodeStabilityMarginView
%#function resppack.NicholsPeakRespView
%#function resppack.NyquistStabilityMarginView
%#function resppack.SigmaPeakRespData
%#function resppack.SigmaPeakRespView
%#function resppack.NyquistPeakRespView
%#function resppack.FreqPeakRespData
switch plotType
   case 'step'
      hmenu(1) = hplot.addCharMenu(mChar, xlate('Peak Response'),...
         'resppack.StepPeakRespData', 'resppack.StepPeakRespView');

      hmenu(2) = hplot.addCharMenu(mChar, xlate('Settling Time'),...
         'resppack.SettleTimeData', 'resppack.SettleTimeView');

      hmenu(3) = hplot.addCharMenu(mChar, xlate('Rise Time'),...
         'resppack.StepRiseTimeData', 'resppack.StepRiseTimeView');

      hmenu(4) = hplot.addCharMenu(mChar, xlate('Steady State'),...
         'resppack.TimeFinalValueData', 'resppack.StepSteadyStateView');

   case 'impulse'
      hmenu(1) = hplot.addCharMenu(mChar, xlate('Peak Response'),...
         'wavepack.TimePeakAmpData', 'wavepack.TimePeakAmpView');

      hmenu(2) = hplot.addCharMenu(mChar, xlate('Settling Time'),...
         'resppack.SettleTimeData', 'resppack.SettleTimeView');

   case 'initial'
      hmenu(1) = hplot.addCharMenu(mChar, xlate('Peak Response'),...
         'wavepack.TimePeakAmpData', 'wavepack.TimePeakAmpView');

   case 'lsim'
      hmenu(1) = hplot.addCharMenu(mChar, xlate('Peak Response'),...
         'wavepack.TimePeakAmpData', 'wavepack.TimePeakAmpView',...
         'resppack.SimInputPeakView');

   case 'bode'
      hmenu(1) = hplot.addCharMenu(mChar, xlate('Peak Response'),...
         'wavepack.FreqPeakGainData', 'wavepack.FreqPeakGainView');

      s = size(getaxes(hplot));
      if prod(s(1:2)) == 1
         hmenu(2) = hplot.addCharMenu(mChar, xlate('Minimum Stability Margins'),...
            'resppack.MinStabilityMarginData', 'resppack.BodeStabilityMarginView');

         hmenu(3) = hplot.addCharMenu(mChar, xlate('All Stability Margins'),...
            'resppack.AllStabilityMarginData', 'resppack.BodeStabilityMarginView');
      end

   case 'nichols'
      hmenu(1) = hplot.addCharMenu(mChar, xlate('Peak Response'),...
         'wavepack.FreqPeakGainData', 'resppack.NicholsPeakRespView');

      s = size(getaxes(hplot));
      if prod(s(1:2)) == 1
         hmenu(2) = hplot.addCharMenu(mChar, xlate('Minimum Stability Margins'),...
            'resppack.MinStabilityMarginData', 'resppack.NicholsStabilityMarginView');

         hmenu(3) = hplot.addCharMenu(mChar, xlate('All Stability Margins'),...
            'resppack.AllStabilityMarginData', 'resppack.NicholsStabilityMarginView');
      end

   case 'nyquist'
      hmenu(1) = hplot.addCharMenu(mChar, xlate('Peak Response'),...
         'resppack.FreqPeakRespData', 'resppack.NyquistPeakRespView');

      s = size(getaxes(hplot));
      if prod(s(1:2)) == 1
         hmenu(2) = hplot.addCharMenu(mChar, xlate('Minimum Stability Margins'),...
            'resppack.MinStabilityMarginData', 'resppack.NyquistStabilityMarginView');

         hmenu(3) = hplot.addCharMenu(mChar, xlate('All Stability Margins'),...
            'resppack.AllStabilityMarginData', 'resppack.NyquistStabilityMarginView');
      end

   case 'sigma'
      hmenu(1) = hplot.addCharMenu(mChar, xlate('Peak Response'),...
         'resppack.SigmaPeakRespData', 'resppack.SigmaPeakRespView');
end
