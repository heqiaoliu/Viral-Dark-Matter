function varargout=modem(varargin) %#ok
%MODEM Modulation implementation
%   H = MODEM.<TYPE>(...) returns a modulation object H of a particular
%   TYPE for performing modulation and/or demodulation. Modulation
%   object H has a set of properties based on its TYPE. 
%   Type "help modem/types" to get the complete help of <a href="matlab:help modem/types">types</a>.
%
%   Each TYPE of modulation object is equipped with functions for simulation
%   and visualization. Type "help modem.<TYPE>" to get the complete help on
%   specific TYPE of modulation object. 
%
%   % EXAMPLE: Construct modulation objects to perform QPSK modulation and
%   % demodulation
%   h = modem.pskmod('M', 4);              % Modulator object
%   g = modem.pskdemod('M', 4);            % Demodulator object
%   msg = randi([0 3],10,1);               % Modulating message
%   modSignal = modulate(h,msg);           % Modulate signal
%   demodSignal = demodulate(g,modSignal); % Demodulate signal

% @modem/
%
%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/01/05 17:45:38 $

error('comm:modem:InvalidUse', ['Use MODEM.<TYPE> to create a modulation object.\n' ... 
                    'For example,\n h = modem.pskmod']);