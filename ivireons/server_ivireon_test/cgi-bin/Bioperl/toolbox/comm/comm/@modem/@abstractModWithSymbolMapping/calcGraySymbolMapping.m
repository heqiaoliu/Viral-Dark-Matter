function symMapping = calcGraySymbolMapping(h, M)
%CALCGRAYSYMBOLMAPPING Calculate the Gray symbol mapping 
%   based on the defined modulation type TYPE and constellation size M

%   @modem/@abstractModWithSymbolMapping

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/06 15:46:41 $

if ( strncmp(h.Type, 'PSK', 3) || strncmp(h.Type, 'OQPSK', 5) )
    modTypeStr = 'psk';
elseif strncmp(h.Type, 'QAM', 3)
    modTypeStr = 'qam';
elseif strncmp(h.Type, 'PAM', 3)
    modTypeStr = 'pam';
elseif strncmp(h.Type, 'DPSK', 4)
    modTypeStr = 'dpsk';
elseif strncmp(h.Type, 'FSK', 3)
    modTypeStr = 'fsk';
end;

symMapping = bin2gray((0:M-1),modTypeStr,M);
if ( strncmp(h.Type, 'QAM', 3) )
    [varNotUsed symMapping] = ismember(0:M-1, symMapping); %#ok
    symMapping = symMapping - 1;
end;

%-------------------------------------------------------------------------------
% [EOF]

