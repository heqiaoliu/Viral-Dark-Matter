function refreshgain(this)
%REFRESHGAIN  Refreshes gain field

%   Author(s): R. Chen
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.8 $  $Date: 2007/02/06 19:50:56 $

% get handles
C = this.CompList(this.idxC);
Handles = this.Handles.ComboDispHandles;
gain = C.getFormattedGain;
PrecisionFormat = this.PrecisionFormat;

% populate the PZ text display area
[ZString PString] = getDisplayString(C);
if isempty(ZString) && isempty(PString)
    % Three line breaks
    PZString = sprintf('<html><BR><BR><BR></html>');
    MultiplyString = '';
    awtinvoke(Handles.CompPZLabel,'setToolTipText(Ljava/lang/String;)','');
else
    if C.Ts>0 && ismember(this.parent.preferences.CompensatorFormat,{'TimeConstant1','TimeConstant2'})
        WString = sprintf('w=(z-1)/Ts');
        awtinvoke(Handles.CompPZLabel, 'setToolTipText(Ljava/lang/String;)',java.lang.String(WString));    
        PZString = sprintf('<html><table><td><center>%s</center><hr><center>%s</center></td><td>, %s</td></table></html>', ZString, PString, WString);
    else
        awtinvoke(Handles.CompPZLabel,'setToolTipText(Ljava/lang/String;)','');
        PZString = sprintf('<html><center>%s</center><hr><center>%s</center></html>', ZString, PString);
    end
    MultiplyString = 'x';
end
awtinvoke(Handles.MultiplyLabel, 'setText(Ljava/lang/String;)', java.lang.String(MultiplyString));
awtinvoke(Handles.CompPZLabel, 'setText(Ljava/lang/String;)', java.lang.String(PZString));

% Refresh gain box and set userdata value
EditG1Text = sprintf(PrecisionFormat,gain);
awtinvoke(Handles.CompGainEditor,'setText(Ljava/lang/String;)',java.lang.String(EditG1Text));
this.GainCache = EditG1Text;
awtinvoke(Handles.CompGainEditor,'setCaretPosition(I)',length(EditG1Text));
% enable/disable gain editor box based on constraints on gain
awtinvoke(Handles.CompGainEditor,'setEnabled(Z)',C.isTunable);

% repaint the panel to avoid initialization problem
awtinvoke(Handles.Combopanel,'revalidate()');

