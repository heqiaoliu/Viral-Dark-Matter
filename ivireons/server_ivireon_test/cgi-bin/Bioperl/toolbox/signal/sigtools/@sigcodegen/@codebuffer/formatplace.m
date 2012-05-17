function s = formatplace(this, n, str)
%FORMATPLACE Convert a number to its place
%   H.FORMATPLACE(N) Convert the number n to its place, i.e '1st', '2nd'.
%
%   H.FORMATPLACE(N, 'full') Convert the number n to its spelled out place,
%   i.e. 'first', 'second'.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/12/14 15:17:38 $

% This should be a static method.

error(nargchk(2,3,nargin,'struct'))

if nargin < 3, str = 'partial'; end

switch str
    case 'partial'
        if n > 4 && n < 20,
            s = sprintf('%dth', n);
        else
            switch rem(n, 10)
                case 1,    s = sprintf('%dst', n);
                case 2,    s = sprintf('%dnd', n);
                case 3,    s = sprintf('%drd', n);
                otherwise, s = sprintf('%dth', n);
            end
        end
    case 'full'
        switch rem(n, 10)
            case 1, s = '-first';
            case 2, s = '-second';
            case 3, s = '-third';
            case 4, s = '-fourth';
            case 5, s = '-fifth';
            case 6, s = '-sixth';
            case 7, s = '-seventh';
            case 8, s = '-eighth';
            case 9, s = '-ninth';
            case 0, s = 'th';
        end
        
        % Get the 10s place
        switch rem(floor(n/10), 10)
            case 1
                % Special case
                switch rem(n, 100)
                    case 10,   s = ' tenth';
                    case 11,   s = ' eleventh';
                    case 12,   s = ' twelfth';
                    case 13,   s = ' thirteenth';
                    otherwise, s = strrep(s, 'th', 'teenth');
                end
            otherwise
                s = gettens(n, s);
        end
        
        if rem(n,10) == 0 && rem(n,100) > 19, s(end-2) = 'i'; end
        
        if n > 99
            s = gethundreds(n, s);
            lbls = {'thousand', 'million', 'billion', 'trillion', 'quadrillion'};
            
            % This is the complete list, but there is no point in adding
            % them all because the precision of the numbers at the other
            % end is lost, i.e. we need more than 64 bits to accurately
            % describe these numbers.
            
%             lbls = {'thousand', 'million', 'billion', 'trillion', 'quadrillion', ...
%                     'quintillion', 'sextillion', 'septillion', 'octillion', ...
%                     'nonillion', 'decillion', 'undecillion', 'duodecillion', ...
%                     'tredecillion', 'quattuordecillion', 'quindecillion', ...
%                     'sexdecillion', 'septendecillion', 'octodecillion', ...
%                     'novemdecillion', 'vigintillion'};

            for indx = 1:length(lbls)
                n = floor(n/1000);
                s = getthousands(n, s, lbls{indx});
            end
        end

        s(1) = [];
    otherwise
        error(generatemsgid('invalidArgument'), ...
            'Unrecognized option %s', str);
end

% --------------------------------------------------------------
function s = getthousands(n, s, lbl)

if nargin < 3, lbl = 'thousand'; end

if n >= 1,
    s = gethundreds(floor(n), ...
        gettens(floor(n), ...
        sprintf('-%s%s', lbl, s)));
end

% --------------------------------------------------------------
function s = gethundreds(n, s)

switch rem(floor(n/100), 10)
    case 0
    otherwise
        s = getones(rem(floor(n/100), 10), sprintf('-hundred%s', s));
end

% --------------------------------------------------------------
function s = gettens(n, s)

switch rem(floor(n/10), 10)
    case 1,
        switch rem(n, 10)
            case 1, s = sprintf(' eleven%s', s);
            case 2, s = sprintf(' twelve%s', s);
            case 3, s = sprintf(' thirteen%s', s);
            case 4, s = sprintf(' fourteen%s', s);
            case 5, s = sprintf(' fifteen%s', s);
            case 6, s = sprintf(' sixteen%s', s);
            case 7, s = sprintf(' seventeen%s', s);
            case 8, s = sprintf(' eighteen%s', s);
            case 9, s = sprintf(' nineteen%s', s);
            case 0, s = sprintf(' ten%s', s);
        end
        
    case 2, s = sprintf(' twenty%s', s);
    case 3, s = sprintf(' thirty%s', s);
    case 4, s = sprintf(' forty%s', s);
    case 5, s = sprintf(' fifty%s', s);
    case 6, s = sprintf(' sixty%s', s);
    case 7, s = sprintf(' seventy%s', s);
    case 8, s = sprintf(' eighty%s', s);
    case 9, s = sprintf(' ninety%s', s);
    case 0, s = sprintf(' %s%s', getones(n), s);
end

% --------------------------------------------------------------
function s = getones(n, s)

if nargin < 2, s = ''; end

switch rem(n, 10)
    case 1, s = sprintf(' one%s', s);
    case 2, s = sprintf(' two%s', s);
    case 3, s = sprintf(' three%s', s);
    case 4, s = sprintf(' four%s', s);
    case 5, s = sprintf(' five%s', s);
    case 6, s = sprintf(' six%s', s);
    case 7, s = sprintf(' seven%s', s);
    case 8, s = sprintf(' eight%s', s);
    case 9, s = sprintf(' nine%s', s);
end

% [EOF]
