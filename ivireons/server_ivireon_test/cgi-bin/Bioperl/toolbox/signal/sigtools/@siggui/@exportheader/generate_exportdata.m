function s = generate_exportdata(hEH)
% Generate the structure 'exportdata' with a part of the GUI
% state that we wish to export.

%   Author(s): J. Schickler & R. Losada
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.9.4.5 $  $Date: 2004/12/26 22:21:17 $

hdt = getcomponent(hEH, '-class', 'siggui.datatypeselector');
hvh = getcomponent(hEH, '-class', 'siggui.varsinheader');

s.DataType = getdatatype(hdt);
s.fracLnth = getfraclength(hdt);

[s.coeffs,s.overflow,s.isTrunc] = convert_data(hEH.Filter, s);

s.coeffvars = getcurrentvariables(hvh);

s.coefflengthvars = s.coeffvars.length;
s.coeffvars       = s.coeffvars.var;
dindx             = [];
for indx = 1:length(s.coefflengthvars),
    if isempty(s.coefflengthvars{indx}),
        dindx = [dindx, indx];
    end
end
s.coefflengthvars(dindx) = [];
dindx = [];
for indx = 1:length(s.coeffvars),
    if isempty(s.coeffvars{indx}),
        dindx = [dindx, indx];
    end
end
s.coeffvars(dindx) = [];

G = get(hEH, 'Filter');

s.nsecs = nsections(G);
s.info  = info(G);

% Target filename
s.file = get(hEH, 'Filename');

% --------------------------------------------------------------------
function [c,overFlag,truncFlag] = convert_data(filtobj,s)
% Convert coefficients to desired data type.

% Initialize overflow flag and truncation flag to zero (no overflow or truncation)
overFlag = 0;
truncFlag = 0;
    
if isa(filtobj, 'dfilt.abstractsos'),
    c  = sos2cell(get(filtobj, 'sosMatrix'));
    sv = get(filtobj, 'ScaleValues');
    if ~isempty(sv),

        c = {{sv(1),1},c{:}};
        for i = 2:length(sv),
            c = {c{1:2*i-2}, {sv(i), 1}, c{2*i-1:end}};
        end
    end
else
    % May not have FD Tlbx, convert data by hand
    c = coefficients(filtobj);
    if ~isa(filtobj, 'dfilt.cascade'),
        c = {c};
    end
end

switch s.DataType,
    case 'double',
        % Do nothing
    case 'single',
        if isprop(filtobj, 'Arithmetic') && isfdtbxinstalled
            if ~strcmpi(filtobj.Arithmetic, 'single')
                truncFlag = 1;
            end
        else
            truncFlag = 1;
        end
        % Loop over multiple sections,
        for m = 1:length(c),
            % Loop over entries in a section, e.g. num and den
            for n = 1:length(c{m}),
                c{m}{n} = single(c{m}{n});
            end
        end
    otherwise,
        if isprop(filtobj, 'Arithmetic') && isfdtbxinstalled
            if any(strcmpi(filtobj.Arithmetic, {'double', 'single'}))
                truncFlag = 1;
            else
                info = qtoolinfo(filtobj);
                info = info.coeff.syncops;

                for indx = 1:length(info)
                    fraclength(indx) = filtobj.([info{indx} 'FracLength']);
                end
                fraclength = min(fraclength);
                if fraclength > s.fracLnth
                    truncFlag = 1;
                end
            end
        else
            truncFlag = 1;
        end
        [c,overFlag] = convert2int(c,s);
end

% --------------------------------------------------------------------
function [c,overFlag] = convert2int(c,s)
% Convert cell array of doubles to cell arrays of integers

% Initialize overflow flag to zero (no overflow)
overFlag = 0;

% Get the word length and a flag indicating if integer is signed or not
[wordLnth,signedFlag] = get_wordLnthNsignedFlag(s.DataType);
	
% Find allowable min and max values
if signedFlag,
	minVal = -pow2(wordLnth - 1);
	maxVal = pow2(wordLnth - 1 ) - 1;
else
	minVal = 0;
	maxVal = pow2(wordLnth ) - 1;
end

% Precompute the amount to shift the numbers by
p = pow2(s.fracLnth);

% Loop over multiple sections,
for m = 1:length(c),
	% Loop over entries in a section, e.g. num and den
	for n = 1:length(c{m}),

		% Shift and round data
		c{m}{n} = round(c{m}{n}.*p);
		
		% Flag if overflow will occur
		if (c{m}{n} > maxVal) | (c{m}{n} < minVal),
			overFlag = 1;
		end
		
		% Saturate
		c{m}{n} = min(max(c{m}{n},minVal),maxVal);
		
		% Actually cast the data Type
		c{m}{n} = feval(s.DataType,c{m}{n});
	end
end

% --------------------------------------------------------------------
function [wordLnth,signedFlag] = get_wordLnthNsignedFlag(dataType)
% Get the word length and a flag indicating if integer is signed or not

% By default assume it is a "signed" data type
signedFlag = 1;

% Remove the "u" from the string if it is there but flag it
if strcmpi(dataType(1),'u'),
	dataType = dataType(2:end);
	signedFlag = 0;
end

% Now remove the "int" from the string
dataType = dataType(4:end);

% Record the wordlength
wordLnth = str2num(dataType);

% [EOF]
