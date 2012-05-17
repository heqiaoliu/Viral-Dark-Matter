function update_datatype(hEH)
%UPDATE_DATATYPE Update the datatype frame

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.6 $  $Date: 2009/07/27 20:32:11 $

Hd = get(hEH, 'Filter');

% Set default fractional length to empty, change only for fixed-point
length = [];
type   = 'double';

if isquantized(Hd),
    
    switch lower(Hd.Arithmetic),
    case 'single',
        type = Hd.Arithmetic;
    case 'fixed',
        [type, length] = determine_fixed_defaultdataType(Hd);
    end
end

hdt = getcomponent(hEH, '-class', 'siggui.datatypeselector');

set(hdt, 'SuggestedType', type);
set(hdt, 'FractionalLength', length);

% --------------------------------------------------------------------
function [def_dataType,def_fracLength] = determine_fixed_defaultdataType(Hd)
% Determine default (suggested) integer data type for a fixed-point filter.

format = Hd.CoeffWordLength;
if format <= 8,
	def_dataType = 'int8';
	wrdlength = 8;
elseif format <= 16,
	def_dataType = 'int16';
	wrdlength = 16;
else
	def_dataType = 'int32';
	wrdlength = 32;
end

if strcmpi(Hd.Signed, 'Off'),
	def_dataType = ['u',def_dataType];
end

info = qtoolinfo(Hd);
info = info.coeff.syncops;

for indx = 1:length(info)
    fraclength(indx) = Hd.([info{indx} 'FracLength']);
end
fraclength = min(fraclength);

def_fracLength = wrdlength - (format-fraclength);

% --------------------------------------------------------------------
function def_dataType = determine_float_defaultdataType(format)
% Determine default (suggested) floating-point data type for a floating-point QFILT.

if format(1) <= 32,
	def_dataType = 'single';
elseif format(1) <= 64,
	def_dataType = 'double';
end

% [EOF]
