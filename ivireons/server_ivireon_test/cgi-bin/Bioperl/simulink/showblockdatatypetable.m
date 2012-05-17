function showblockdatatypetable(Action)
%SHOWBLOCKDATATYPETABLE  Launches html page in help browser to show
%   data type & production intent information for library blocks.

%   Copyright 1990-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/05/20 00:26:49 $

if nargin == 0
  Action = 'LaunchHTML';
end

switch Action
case 'LaunchHTML'
  % Simulink must be loaded for this function to work.
  if isempty(find_system('SearchDepth', 0, 'CaseSensitive', 'off', 'Name', 'simulink'))
    disp(DAStudio.message('Simulink:bcst:LoadingSL'));
    load_system('simulink');
  end
  bcstMakeSlSupportTable('simulink');
otherwise
  warning('Simulink:bcst:UnrecognizedAction', DAStudio.message('Simulink:bcst:UnrecognizedAction', Action));
end
