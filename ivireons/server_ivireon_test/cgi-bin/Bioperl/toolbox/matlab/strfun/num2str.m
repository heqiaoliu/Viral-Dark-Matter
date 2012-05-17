function s = num2str(x, f)
%NUM2STR Convert numbers to a string.
%   T = NUM2STR(X) converts the matrix X into a string representation T
%   with about 4 digits and an exponent if required.  This is useful for
%   labeling plots with the TITLE, XLABEL, YLABEL, and TEXT commands.
%
%   T = NUM2STR(X,N) converts the matrix X into a string representation
%   with a maximum N digits of precision.  The default number of digits is
%   based on the magnitude of the elements of X.
%
%   T = NUM2STR(X,FORMAT) uses the format string FORMAT (see SPRINTF for
%   details).
%
%   If the input array is integer-valued, num2str returns the exact string
%   representation of that integer. The term integer-valued includes large
%   floating-point numbers that lose precision due to limitations of the
%   hardware.
%
%   Example 1:
%       num2str(randn(2,2),3) produces the string matrix
%
%       -0.433    0.125
%       -1.671    0.288
%
%   Example 2:
%       num2str(rand(2,3) * 9999, '%10.5e\n') produces the string matrix
%
%       8.14642e+003
%       1.26974e+003
%       6.32296e+003
%       9.05701e+003
%       9.13285e+003
%       9.75307e+002
%
%   See also INT2STR, SPRINTF, FPRINTF, MAT2STR.

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 5.32.4.21 $  $Date: 2009/04/21 03:26:42 $
%------------------------------------------------------------------------------
    % if input does not exist or is empty, throw an exception
    if nargin<1
        error('MATLAB:num2str:NumericArrayUnspecified',...
            'Numeric array is unspecified')
    end
    % If input is a string, return this string.
    if ischar(x)
        s = x;
        return
    end
    if isempty(x)
        s = '';
        return
    end
    if issparse(x)
        x = full(x);
    end

    intFieldExtra = 1;
    maxFieldWidth = 12;
    floatWidthOffset = 4;
    forceWidth = 0;
    padColumnsWithSpace = true;

    % Compose sprintf format string of numeric array.
    if nargin < 2
        if ~isempty(x) && isequalwithequalnans(x, fix(x))
            if isreal(x)
                s = int2str(x);
                return;
            else
                %Complex case
                xmax = double(max(abs(x(:))));
                if xmax == 0
                    d = 1;
                else
                    d = min(maxFieldWidth, floor(log10(xmax)) + 1);
                end
                forceWidth = d+intFieldExtra;
                f = '%d';
            end
        else
            % The precision is unspecified; the numeric array contains floating point
            % numbers.
            xmax = double(max(abs(x(:))));
            if xmax == 0
                d = 1;
            else
                d = min(maxFieldWidth, max(1, floor(log10(xmax))+1))+floatWidthOffset;
            end
            
            [s, forceWidth, f] = handleNumericPrecision(x, d);

            if ~isempty(s)
                return;
            end
        end
    elseif isnumeric(f)
        f = round(real(f));

        [s, forceWidth, f] = handleNumericPrecision(x, f);

        if ~isempty(s)
            return;
        end
    elseif ischar(f)
        % Precision is specified as an ANSI C print format string.
        
        % Explicit format strings should be explicitly padded
        padColumnsWithSpace = false;
        
        % Validate format string
        k = strfind(f,'%');
        if isempty(k)
            error('MATLAB:num2str:fmtInvalid', '''%s'' is an invalid format.',f);
        end
    else
        error('MATLAB:num2str:invalidSecondArgument',...
            'Second argument to num2str must be char or numeric')        
    end

    %-------------------------------------------------------------------------------
    % Print numeric array as a string image of itself.

    if isreal(x)
        [raw, isLeft] = cellPrintf(f, x, false);
        [m,n] = size(raw);
        cols = cell(1,n);
        widths = zeros(1,n);
        for j = 1:n
            if isLeft
                cols{j} = char(raw(:,j));
            else
                cols{j} = strvrcat(raw(:,j));
            end
            widths(j) = size(cols{j}, 2);
        end
    else
        forceWidth = 2*forceWidth + 2;
        raw = cellPrintf(f, real(x), false);
        imagRaw = cellPrintf(f, imag(x), true);
        [m,n] = size(raw);
        cols = cell(1,n);
        widths = zeros(1,n);
        for j = 1:n
            cols{j} = [strvrcat(raw(:,j)) char(imagRaw(:,j))];
            widths(j) = size(cols{j}, 2);
        end
    end

    maxWidth = max([widths forceWidth]);
    padWidths = maxWidth - widths;
    padIndex = find(padWidths, 1);
    while ~isempty(padIndex)
        padWidth = padWidths(padIndex);
        padCols = (padWidths==padWidth);
        padWidths(padCols) = 0;
        spaceCols = char(ones(m,padWidth)*' ');
        cols(padCols) = strcat({spaceCols}, cols(padCols));
        padIndex = find(padWidths, 1);
    end

    if padColumnsWithSpace
        spaceCols = char(ones(m,1)*' ');
        cols = strcat(cols, {spaceCols});
    end

    s = strtrim([cols{:}]);
end

function s = strvrcat(c)
    s = strjust(char(c));
end

function [cells, isLeft] = cellPrintf(f, x, b)
    try
        [cells, err, isLeft] = sprintfc(f, x, b);
        if ~isempty(err)
            warning('MATLAB:num2str:badConversion', err);
        end
    catch e
        warning(e.identifier, e.message);
        cells = {''};
        isLeft = false;
    end
end

function [s, forceWidth, f] = handleNumericPrecision(x, precision)
    if isreal(x)
        s = convertUsingRecycledSprintf(x, precision);
        forceWidth = 0;
        f = '';
    else
        floatFieldExtra = 6;
        s = '';
        forceWidth = precision+floatFieldExtra;
        f = sprintf('%%.%dg', precision);
    end
end

function s = convertUsingRecycledSprintf(x, d)
    floatFieldExtra = 7;
    f = sprintf('%%%.0f.%.0fg', d+floatFieldExtra, d);
    
    [m, n] = size(x);
    scell = cell(1,m);
    pads = logical([]);
    for i = 1:m
        scell{i} =  sprintf(f,x(i,:));
        if n > 1 && (min(x(i,:)) < 0)
            pads(regexp(scell{i}, '([^\sEe])-')) = true;
        end
    end

    s = char(scell{:});

    pads = find(pads);
    if ~isempty(pads)
        pads = fliplr(pads);
        spacecol = char(ones(m,1)*' ');
        for pad = pads
            s = [s(:,1:pad) spacecol s(:,pad+1:end)];
        end
    end
    
    s = strtrim(s);
end
