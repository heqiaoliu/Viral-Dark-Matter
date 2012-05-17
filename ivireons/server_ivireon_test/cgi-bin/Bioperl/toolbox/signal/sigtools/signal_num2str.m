function str = signal_num2str(num, fmt)
%SIGNAL_NUM2STR   Convert the number to a string.
%   SIGNAL_NUM2STR(NUM, FMT)  Convert the number to a string, removing
%   trailing zeros after decimal places and aligning the decimal places.
%   All precision is kept whenever possible.
%
%   % Example
%   Hd = cheby2(fdesign.lowpass);
%   set(Hd, 'Arithmetic', 'fixed');
%   signal_num2str(Hd.sosMatrix)

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/02/13 15:13:59 $

if isempty(num),
    str = '[]';
    return;
end

if nargin < 2
    fmt = '%.39f';
end


[rows, cols] = size(num);

% If we have a vector
if cols == 1
    str = lclformat(num, fmt);
else
    str = cell(1,cols);
    for indx = 1:cols
       str{indx} = [lclformat(num(:, indx), fmt)'; repmat('  ', rows, 1)'];
    end

    str{end}(end-1:end, :) = [];

    str = strvcat(str{:})'; %#ok<VCAT>
end

% ------------------------------------------------------------------------
function str = lclformat(num, fmt)

if isreal(num)
    str = num2str(num, fmt);
else
    realstr = lclformat(real(num), fmt);
    imagstr = lclformat(imag(num), fmt);
    for indx = 1:length(num)
        if imag(num(indx)) >=0
            sndx = find(diff(strfind(imagstr(indx,:), ' ')) ~= 1,1);
            if isempty(sndx) || imag(num(indx)) == 0
                sndx = strfind(imagstr(indx,:), ' ');
                if isempty(sndx) || imag(num(indx)) == 0
                    imagstr = [repmat(' ', length(num), 1) imagstr]; %#ok<AGROW>
                end
            end
            imagstr(indx, 1) = '+';
        end
    end
    imagstr = [imagstr repmat('i', length(num), 1)];
    str = [realstr imagstr];
    return;
end

nrows = size(str, 1);
   

for indx = 1:nrows

    % Find the decimal.
    decim = strfind(str(indx, :), '.');
    if ~isempty(decim)

        % Loop from the end towards the decimal point and remove zeros.
        jndx = size(str, 2);
        while isequal(str(indx, jndx), '0') || isequal(str(indx, jndx), ' ')
            str(indx, jndx) = ' ';
            jndx = jndx - 1;
        end

        % If the next character is the decimal, remove it.
        if decim == jndx
            str(indx, jndx) = ' ';
        end
    end
end

digitstodecimal = zeros(nrows, 1);

% Find each numbers decimal place
strcell = cell(1,nrows);
for indx = 1:nrows
    strcell{indx} = strtrim(str(indx, :));
    dtd = strfind(strcell{indx}, '.');
    if isempty(dtd)
        dtd = length(strcell{indx})+1;
    end
    digitstodecimal(indx) = dtd;
end

% Add spaces to the beginning of each line so that the decimals align.
maxdigits = max(digitstodecimal);
for indx = 1:nrows
    strcell{indx} = [repmat(' ', 1, maxdigits-digitstodecimal(indx)), strcell{indx}];
end

str = strvcat(strcell{:}); %#ok<VCAT>


% [EOF]
