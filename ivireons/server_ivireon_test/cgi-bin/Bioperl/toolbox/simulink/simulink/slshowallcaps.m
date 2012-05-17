function slshowallcaps(Action, libLists, libNames)
%SLSHOWALLCAPS  Launches html page in help browser to show
%   data type & production intent information for all blocks.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $
%   $Date: 2008/05/20 00:27:10 $

if nargin < 3
  Action = 'Unknown';
end

switch Action
    case 'Unknown'
        warning('Simulink:bcst:UseFromMenu', DAStudio.message('Simulink:bcst:UseFromMenu'));
    case 'LaunchHTML'
        % Simulink must be loaded for this function to work.
        if isempty(find_system('SearchDepth', 0, 'CaseSensitive', 'off', 'Name', 'simulink'))
            disp(DAStudio.message('Simulink:bcst:LoadingSL'));
            load_system('simulink');
        end
        bcstMakeSlSupportTable(libLists, false, '*All*', libNames);
otherwise
  warning('Simulink:bcst:UnrecognizedAction', DAStudio.message('Simulink:bcst:UnrecognizedAction', Action));
end
