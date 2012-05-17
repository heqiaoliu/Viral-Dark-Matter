function showPanelHelp(this)

%   Author(s): C. Buhr
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2006/01/26 01:47:22 $

Tab = getVisibleTab(this);

switch Tab
    case 'Architecture' % Architecture Panel
        HelpTopicKey = 'sisoarchitecturetab';

    case 'PZEditor' % Manual Tunning
        HelpTopicKey = 'sisocompensatoreditortab';

    case 'DesignPlot' % Design Plot Configuration
        HelpTopicKey = 'sisographicaltuningtab';

    case 'AnalysisPlot' % Design Plot Configuration
        HelpTopicKey = 'sisoanalysisplotstab';

    case 'SROTuning' % Automated Tuning
        HelpTopicKey = 'sisoautomatedtuningtab';
end

try
    mapfile = ctrlguihelp;
    helpview(mapfile,HelpTopicKey,'CSHelpWindow');
end