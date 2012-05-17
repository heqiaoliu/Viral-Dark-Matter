function varargout=fec(varargin) %#ok
%FEC Forward error control code implementation.
%   H = FEC.<TYPE>(...) returns a forward error control code object H of a particular
%   TYPE for performing encoding and/or decoding. Encoder/Decoder
%   object H has a set of properties based on its TYPE. 
%   Type "help fec/types" to get the complete help of <a href="matlab:help fec/types">types</a>.
%
%   Each TYPE of encoder/decoder object is equipped with functions for simulation
%   and visualization. Type "help fec.<TYPE>" to get the complete help on
%   specific TYPE of encoder/decoder object. 
%
%   % EXAMPLE: Construct encoder objects to perform Reed-Solomon encoding and
%   % decoding.
%   h = fec.rsenc(7,3);    % Reed-Solomon encoder object
%   g = fec.rsdec(7,3); % Reed-Solomon decoder object

% @fec/
%
%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/09/14 15:58:31 $

error('comm:fec:InvalidUse', ['Use FEC.<TYPE> to create a forward error control code object.\n' ... 
                    'For example,\n h = fec.rsenc']);