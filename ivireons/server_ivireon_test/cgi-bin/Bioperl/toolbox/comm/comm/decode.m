function [msg, err, ccode, cerr] = decode(code, n, k, method, opt1, opt2, opt3, opt4)
%DECODE Block decoder.
%   MSG = DECODE(CODE, N, K, METHOD...) decodes CODE using an error-
%   control coding technique.  For information about METHOD and
%   other parameters, and about using a specific technique,
%   type one of these commands at the MATLAB prompt:
%
%   FOR DETAILS, TYPE       CODING TECHNIQUE
%     decode hamming         % Hamming
%     decode linear          % Linear block
%     decode cyclic          % Cyclic
%
%   See also ENCODE, CYCLPOLY, SYNDTABLE, GEN2PAR.

%   Copyright 1996-2008 The MathWorks, Inc.
%   $Revision: 1.27.4.7 $  $Date: 2008/03/31 17:06:23 $

% routine check
if (nargin == 2)
    error('comm:decode:NotEnoughInputs','Not enough input parameters')
elseif nargin == 3
    method = 'hamming';
elseif nargin > 3
    method = lower(method);
end;

if nargin < 1
    feval('help', 'decode');
    return;
elseif ischar(code)
    method = lower(deblank(code));
    if length(method) < 2
        error('comm:decode:InvalidMethod','Invalid method option for DECODE.')
    end
    if nargin == 1
        addition = 'See also ENCODE, CYCLPOLY, SYNDTABLE, GEN2PAR.';
        callhelp('decode.hlp',method(1:2),addition);
    else
        warning('comm:decode:inputVarNum', ...
            'Wrong number of input variables for DECODE.');
    end;
    return;
else
    % store the type of argument code
    in_type = class(code);
    code = cast(code, 'double');

    if ~isempty(findstr(method, 'rs'))
        % Reed-Solomon method.
        if ~isempty(findstr(method, 'pow'))
            type_flag = 'power';
        elseif ~isempty(findstr(method, 'dec'))
            type_flag = 'decimal';
        else
            type_flag = 'binary';
        end;
        if nargin > 4
            n = opt1;
        end;
        if nargout <= 1
            msg = rsdeco(code, n, k, type_flag);
        elseif nargout == 2
            [msg, err] = rsdeco(code, n, k, type_flag);
        elseif nargout == 3
            [msg, err, ccode] = rsdeco(code, n, k, type_flag);
        elseif nargout == 4
            [msg, err, ccode, cerr] = rsdeco(code, n, k, type_flag);
        else
            error('comm:decode:TooManyArgs','Too many output arguments.');
        end;
    else

        % error checking for N & K
        if (floor(n) ~= n) || (n<1)
            error('comm:decode:InvalidN',['The codeword length, N must be a '...
                'positive integer greater than 0.']);
        end

        if (floor(k) ~= k) || (k<1)
            error('comm:decode:InvalidK',['The message length, K must be a '...
                'positive integer greater than 0.']);
        end

        if (n <= k)
            error('comm:decode:NLessThanK',['The codeword length, N must be '...
                'greater than the message length, K.']);
        end

        isRowVector = false; % this variable is used to determine if input is a
        % row vector
        % make msg to be a column vector when it is a vector.
        if min(size(code)) == 1
            isRowVector = (size(code,1) == 1); %check if CODE is a Row Vector
            code = code(:);
        end;

        [n_code, m_code] = size(code);

        if ~isempty(findstr(method, 'decimal'))
            type_flag = 1;      % decimal
            if m_code > 1
                method = method(1:find(method=='/')-1);
                error('comm:decode:CodeNotVector', ['CODE for %s code '...
                    'in decimal format must be a vector.'], method)
            else
                if ~isempty([find(code > 2^n-1); find(code < 0);...
                        find(floor(code)~=code)])
                    error('comm:decode:InvalidCode',['CODE must contain '...
                        'only positive integers smaller than 2^N.'])
                end;
            end;
            code = de2bi(code, n);
        else
            type_flag = 0;      % binary matrix
            if ~strncmp(in_type, 'logical', 7) && (~isempty([find(code > 1); ...
                    find(code < 0); find(floor(code)~=code)]) ...
                    && isempty(findstr(method, 'conv'))) %#ok
                error('comm:decode:CodeNotBinary',['CODE must contain only '...
                    'binary numbers.'])
            end;
            if m_code == 1
                type_flag = 2;  % binary vector
                [code, added] = vec2mat(code, n);
                if added
                    warning('comm:decode:codeFormat', ...
                        ['The input CODE does not have the same format as ', ...
                        'the output of ENCODE.  Check your computation ', ...
                        'procedures for possible errors.']);
                end;
            elseif m_code ~= n
                error('comm:decode:InvalidCodeColumnSize',['CODE must be '...
                    'either a vector or a matrix with N columns.']);
            end;
        end;
        % at this stage CODE is a N-colomn matrix
        if ~isempty(findstr(method, 'bch'))
            % BCH code.
            if nargin <= 4
                t = 0;
            else
                t = opt1;
            end;
            if ~(t>0)
                [tmp1, tmp2, tmp3, tmp4, t] = bchpoly(n, k);
            end;
            if nargin <= 5
                [msg, err, ccode] = bchdeco(code, k, t);
            else
                [msg, err, ccode] = bchdeco(code, k, t, opt2);
            end;
        elseif ~isempty(findstr(method, 'convol'))
            if nargin < 5
                error('comm:decode:NotEnoughInputs',['Not enough input '...
                    'parameters.'])
            elseif nargin == 5
                [msg, err, ccode] = viterbi(code, opt1);
            elseif nargin == 6
                [msg, err, ccode] = viterbi(code, opt1, opt2);
            elseif nargin == 7
                [msg, err, ccode] = viterbi(code, opt1, opt2, opt3);
            else
                [msg, err, ccode] = viterbi(code, opt1, opt2, opt3, opt4);
            end;
        else
            % the msg calculation is the same, different trt and h calculation.
            % for hamming, block and cyclic code.
            if ~isempty(findstr(method, 'hamming'))
                % hamming code.
                m = n - k;
                if 2^m - 1 ~= n
                    error('comm:decode:InvalidNKLen',['The specified '...
                        'codeword length and message length are not valid.'])
                end;
                if nargin <= 4
                    [h, gen] = hammgen(m);
                else
                    [h, gen] = hammgen(m, opt1);
                end;
                % truth table.
                trt = syndtable(h);
            elseif ~isempty(findstr(method, 'linear'))
                % block code.
                if nargin < 5
                    error('comm:decode:MissingGenMatrix',['The generator '...
                        'matrix is a required input argument for linear '...
                        'block decoding.']);
                end;
                [n_opt1, m_opt1] = size(opt1);
                if (m_opt1 ~= n) || (n_opt1 ~= k)
                    error('comm:decode:InvalidGenMatrixDims',['The '...
                        'generator matrix must be a K-by-N matrix.']);
                end;
                gen = opt1;
                h = gen2par(gen);
                if nargin < 6
                    opt2 = syndtable(h);
                end;
                trt = opt2;
            elseif ~isempty(findstr(method, 'cyclic'))
                % cyclic code.
                if nargin < 5

                    opt1 = [];
                    try
                        opt1 = cyclpoly(n, k);
                    catch exception
                        if isempty(opt1)
                            error('comm:encode:IvalidGenPoly',['No '...
                                'generator polynomial satisfies the given '...
                                'constraints of N and K.']);
                        else
                            rethrow(exception);
                        end
                    end

                end;
                [h, gen] = cyclgen(n, opt1);
                if nargin < 6
                    opt2 = syndtable(h);
                end;
                trt = opt2;
            else
                error('comm:decode:InvalidDecodingMethod',['Invalid '...
                    'decoding method ''%s'''], method);
            end;

            %calculation:
            syndrome = rem(code * h', 2);

            % error location:
            err = bi2de(fliplr(syndrome));
            err_loc = trt(err + 1, :);

            % corrected code
            ccode = rem(err_loc + code, 2);

            % corrected message
            I = eye(k);
            if isequal(gen(:, 1:k) ,I)
                msg = ccode(:, 1:k);
            elseif isequal(gen(:, n-k+1:n), I)
                msg = ccode(:, n-k+1:n);
            else
                error('comm:decode:InvalidGenMatrixForm',['The generator '...
                    'matrix must be in the standard form.']);
            end

            % check the error number for the corresponding msg.
            if nargout > 1
                % number of errors has been found.
                err = sum(err_loc,2);
                % bring back the code to check the error
                err_loc = rem(msg * gen, 2);
                % find the error location
                indx = find(sum(abs(err_loc - ccode),2) > 0);
                % assign the uncorrected one to be -1
                err(indx) = indx - indx - 1;
                indx = find(sum(abs(err_loc - code),2) ~= err);
                % assign the uncorrected one to be -1
                err(indx) = indx - indx - 1;
            end;
            % finish the calculation for hamming code, cyclic code and linear
            % block code.
        end;
        % convert back to the original structure.
        if nargout > 3
            cerr = err;
        end;
        if type_flag == 1
            msg = bi2de(msg);
            if nargout > 2
                ccode = bi2de(ccode);
                if isRowVector
                    % if input MSG was a Row Vector, output CCODE must be a Row
                    % Vector i.e. preserve the dimensionality across input &
                    % outputs.
                    ccode = ccode';
                end;
            end;
        elseif type_flag == 2
            msg = msg';
            msg = msg(:);
            if nargout > 1
                err=err(:);
            end;
            if nargout > 2
                ccode = ccode';
                ccode = ccode(:);
                if isRowVector
                    % if input MSG was a Row Vector, output CCODE must be a Row
                    % Vector i.e. preserve the dimensionality across input &
                    % outputs.
                    ccode = ccode';
                end;
            end;
            if nargout > 3
                cerr = cerr(:);
            end;
        end;
        if isRowVector
            % if input MSG was a Row Vector, output CODE must be a Row Vector
            % i.e. preserve the dimensionality across input & output.
            msg = msg';
        end;
    end;
end;

msg = cast(msg, in_type);