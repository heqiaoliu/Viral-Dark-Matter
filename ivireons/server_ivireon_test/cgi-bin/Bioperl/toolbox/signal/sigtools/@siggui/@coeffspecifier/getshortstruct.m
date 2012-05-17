function shortstruct = getshortstruct(hCoeff, searchtype)
%GETSHORTSTRUCT Returns the abbreviation for the selected structure
%   GETSHORTSTRUCT(hSTRUCT, STYPE) Returns the abbreviation for the selected
%   structure of the Import Tool associated with hIT.  STYPE is the type
%   of search performed, 'object' will return the constructor to the 
%   object itself.  'struct' will return the generic string 'tf' for all
%   direct form structures.  'struct' is the default.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2004/04/13 00:22:07 $

if nargin == 1, searchtype = 'struct'; end

index = getindex(hCoeff);
a_struct = get(hCoeff,'AllStructures');

shortstruct = [a_struct.short{index}];

% This special case is for indexing into the other properties
if strcmpi(searchtype,'struct')
    if strcmpi(hCoeff.SOS, 'on'),
        shortstruct = 'sos';
    else
        switch shortstruct
            case {'dfilt.df1', 'dfilt.df2', 'dfilt.df1t', 'dfilt.df2t'},
                shortstruct = 'tf';
            case {'dfilt.dffir', 'dfilt.fftfir'},
                shortstruct = 'fir';
            otherwise
                [pk, shortstruct] = strtok(shortstruct, '.');
                if isempty(shortstruct),
                    shortstruct = pk;
                else,
                    shortstruct(1) = [];
                end
        end
    end
end

% [EOF]
