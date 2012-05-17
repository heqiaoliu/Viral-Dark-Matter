function bfithelp(cmd)
% BFITHELP Displays help for Basic Fitting and Data Statistics
%   BFITHELP('bf') displays Basic Fitting Help
%   BFITHELP('ds') displays Data Statistics Help

%   Copyright 1984-2008 The MathWorks, Inc.
%   $Revision: 1.6.4.5 $

switch cmd
    case 'bf'
        try
            helpview([docroot '/techdoc/time_series_csh/time_series_csh.map'], ...
                'basic_fitting_options' ,'CSHelpWindow');
        catch err
            bfitcascadeerr(['Unable to display help for Basic Fitting:' ...
                sprintf('\n') err.message ], 'Basic Fitting');
        end
        
    case 'ds'
        try
            helpview([docroot '/techdoc/time_series_csh/time_series_csh.map'], ...
                'plotting_basic_stats2' ,'CSHelpWindow');
        catch err
            bfitcascadeerr(['Unable to display help for Data Statistics' ...
                sprintf('\n') err.message ], 'Data Statistics');
        end
end
