%COPY Copy the object H from REFOBJ.
%   H = COPY(REFOBJ) creates an new object H of the same type as the REFOBJ
%   and copies the properties of object H from properties of REFOBJ. REFOBJ
%   can be any of the objects listed in <a href="matlab:help modem/types">modem/types</a>.  
%
%   EXAMPLES:
%
%     h = modem.pskmod; % create an object with default properties
%     disp(h); % display object properties
%
%     h1 = copy(h) % note the absence of semicolon
%
%   See also MODEM, MODEM/MODULATE, MODEM/DEMODULATE, MODEM/TYPES, MODEM/DISP,
%   MODEM/RESET

% @modem/

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/08/01 12:18:04 $
