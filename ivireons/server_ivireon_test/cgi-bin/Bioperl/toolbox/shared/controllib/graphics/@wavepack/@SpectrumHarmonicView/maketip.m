function str = maketip(this,tip,info)
%MAKETIP  Build data tips for SpectrumHarmonicView Characteristics.
%
%   INFO is a structure built dynamically by the data tip interface
%   and passed to MAKETIP to facilitate construction of the tip text.

% Author(s): Erman Korkut 18-Mar-2009
% Revised:
% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:27:02 $

r = info.Carrier;
cData = info.Data;
AxGrid = info.View.AxesGrid;
MagUnits = AxGrid.YUnits;
if iscell(MagUnits)
   MagUnits = MagUnits{1};  % for mag/phase plots
end

str{1,1} = ctrlMsgUtils.message('Controllib:plots:strFundamentalHarmonic');
[iotxt,ShowFlag] = rcinfo(r,info.Row,info.Col); 
if any(AxGrid.Size(1:2)>1) | ShowFlag 
    % Show if MIMO or non trivial 
    str{end+1,1} = iotxt; 
end

% Note: Characteristic data expressed in same units as carrier's response data
XData = unitconv(cData.Frequency(info.Row,info.Col),cData.Parent.FreqUnits,AxGrid.XUnits);
YData = unitconv(cData.PeakGain(info.Row,info.Col),cData.Parent.MagUnits,MagUnits);
str{end+1,1} = sprintf('%s (%s): %0.4g', ctrlMsgUtils.message('Controllib:plots:strFrequency'),...
    AxGrid.XUnits, XData);
str{end+1,1} = sprintf('%s (%s): %0.4g', ctrlMsgUtils.message('Controllib:plots:strAmplitude'),...
    MagUnits, YData);
