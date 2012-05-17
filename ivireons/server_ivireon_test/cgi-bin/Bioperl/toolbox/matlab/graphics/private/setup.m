function result = setup( pj )
%SETUP Open the printer setup dialog.
%   If the device driver in the PrintJob object is setup, opens the window
%   system specific dialog for setting options for printing. Normally this 
%   dialog will affect all future printing using the window system's driver
%   (i.e. Windows drivers), not just the current Figure or model.
%
%   Ex:
%      err_code = SETUP( pj ); %returns 1 if successfuly opened setup
%                               dialog, 0 if not.
%
%   See also PRINT.

%   Copyright 1984-2008 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2008/12/15 08:53:02 $

if strcmp('setup', pj.Driver)
    result = 1;
    if (useOriginalHGPrinting())
        hardcopy(pj.Handles{1}(1), '-dsetup');
    end
else
    result = 0;
end
