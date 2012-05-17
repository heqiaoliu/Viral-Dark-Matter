function editparameters(this)
%EDITPARAMETERS Edit the parameters for the Current Analysis

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.14.4.5 $  $Date: 2005/06/30 17:39:13 $ 

hdlg = get(this, 'ParameterDlg');
ca   = get(this, 'CurrentAnalysis');

if isempty(ca)
    error(generatemsgid('noAnalysis'), 'Cannot edit analysis parameters if no analysis is selected.');
end

% If there is no parameter dialog, create one.
if isempty(hdlg),
    if ~isempty(ca)
        hdlg = ca.setupparameterdlg;
        set(this, 'ParameterDlg', hdlg);

        set(hdlg, 'Tool', 'fvtool');
        [wstr, wid] = lastwarn;
        set(hdlg, 'HelpLocation', {fullfile(docroot, 'toolbox','signal', 'signal.map'), ...
            'fvtool_analysis_parameters'});
        lastwarn(wstr, wid);
    end
else
    
    if ~isrendered(hdlg),
        render(hdlg);
        hdlg.centerdlgonfig(this.FigureHandle);
        set(hdlg, 'HelpLocation', {fullfile(docroot, 'toolbox','signal', 'signal.map'), ...
                'fvtool_analysis_parameters'});
    end
    setupparameterdlg(ca, hdlg);
end

cshelpcontextmenu(hdlg.FigureHandle, handles2vector(hdlg), ...
    'fvtool_analysis_parameters', 'FDATool');

% Make it visible and bring it to the front.
set(hdlg, 'visible', 'on');
figure(hdlg.FigureHandle);

% [EOF]
