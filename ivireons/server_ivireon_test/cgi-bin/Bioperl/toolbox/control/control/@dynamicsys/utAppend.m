function L = utAppend(L1,L2)
% Metadata management for APPEND.

%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 14:23:22 $
L = utClearUserData(L1);

% Append I/O groups
L.InputGroup = groupcat(L1.InputGroup,L2.InputGroup,...
                        length(L1.InputName)+(1:length(L2.InputName)));
L.OutputGroup = groupcat(L1.OutputGroup,L2.OutputGroup,...
                        length(L1.OutputName)+(1:length(L2.OutputName)));

% Append I/O names
L.InputName = [L1.InputName ; L2.InputName];
L.OutputName = [L1.OutputName ; L2.OutputName];
