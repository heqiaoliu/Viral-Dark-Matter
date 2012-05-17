%DISP Display properties of an object.
%   DISP(H) displays relevant properties of object H. H is can be any of the
%   objects listed in <a href="matlab:help modem/types">modem/types</a>.  
%
%   If a property is not relevant to the object's configuration, it is not
%   displayed. For example, for a MODEM.PSKDEMOD object, NoiseVariance property
%   is not relevant when DecisionType property is set to 'Hard decision', hence
%   NoiseVariance property is not displayed. 
%
%   EXAMPLES:
%
%     h = modem.pskmod; % create an object with default properties
%     disp(h); % display object properties
%
%     h = modem.qamdemod('M', 32) % note the absence of semicolon
%
%   See also MODEM, MODEM/MODULATE, MODEM/DEMODULATE, MODEM/TYPES, MODEM/COPY,
%   MODEM/RESET

% @modem/

%   Copyright 2006 - 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/08/01 12:18:06 $
