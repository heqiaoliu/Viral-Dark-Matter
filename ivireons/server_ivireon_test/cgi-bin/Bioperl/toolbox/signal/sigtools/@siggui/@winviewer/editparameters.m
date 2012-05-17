function editparameters(hView)
%EDITPARAMETERS Edit the parameters

%   Author(s): V. Pellissier
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2005/12/22 19:04:45 $ 

hdlg = get(hView, 'ParameterDlg');

% If there is no parameter dialog, create one.
if isempty(hdlg),
    hdlg = siggui.parameterdlg(hView.Parameters, 'Analysis Parameters', 'Magnitude Response');
    set(hView, 'ParameterDlg', hdlg);
    set(hdlg, 'Tool', 'winviewer');
    set(hdlg, 'HelpLocation', {fullfile(docroot, '/toolbox/signal/', 'signal.map'), ...
            'wintool_analysis_parameters'});
    
    value = get(getparameter(hView, 'freqmode'), 'Value');
    if strcmpi(value, 'normalized'),
        % Disable Sampling
        disableparameter(hdlg, 'sampfreq');
    else
        % Enable Sampling
        enableparameter(hdlg, 'sampfreq');
    end  
end

if ~isrendered(hdlg), 
    render(hdlg);
    centerdlgonfig(hdlg, hView);
end
    
% If there is a parameter dialog, make it visible and bring it to the front.
set(hdlg, 'visible', 'on');
figure(hdlg.FigureHandle);

% [EOF]
