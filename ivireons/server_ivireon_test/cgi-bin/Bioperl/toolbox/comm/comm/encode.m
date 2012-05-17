function [code, added] = encode(msg, n, k, method, opt)
%ENCODE Block encoder.
%   CODE = ENCODE(MSG, N, K, METHOD, OPT) encodes MSG using an error-control
%   coding technique. For information about the parameters and about using a
%   specific technique, type one of these commands at the MATLAB prompt:
%
%   FOR DETAILS, TYPE       CODING TECHNIQUE
%     encode hamming         % Hamming
%     encode linear          % Linear block
%     encode cyclic          % Cyclic
%
%   See also DECODE, CYCLPOLY, CYCLGEN, HAMMGEN.

%   Copyright 1996-2007 The MathWorks, Inc.
%   $Revision: 1.20.4.5 $  $Date: 2007/09/14 15:57:18 $

% routine check
error(nargchk(1,5,nargin,'struct'));
if nargin == 2
    error('comm:encode:NotEnoughInputs','Not enough input arguments.')
elseif nargin > 3
    method = lower(method);
elseif nargin == 3
    method = 'hamming';
end;

added = 0;
if nargin < 1
    feval('help', 'encode');
    return;
elseif ischar(msg)
    method = lower(deblank(msg));
    if length(method) < 2
        error('comm:encode:InvalidMethod','Invalid method option for ENCODE.')
    end
    if nargin == 1
        addition = 'See also DECODE, CYCLPOLY, CYCLGEN, HAMMGEN.';
        err = callhelp('encode.hlp',method(1:2),addition);
        if err < 0
            error('comm:encode:InvalidCodingMethod','Invalid coding method.');
        end
    else
        warning('comm:encode:inputVarNum', ...
            'Wrong number of input variables for ENCODE.');
    end;
    return;
elseif ~isempty(findstr(method, 'rs'))
    % Reed-Solomon method.
    if ~isempty(findstr(method, 'power'))
        type_flag = 'power';
    elseif ~isempty(findstr(method, 'decimal'))
        type_flag = 'decimal';
    else
        type_flag = 'binary';
    end;
    if nargin <= 4
        [code, added] = rsenco(msg, n, k, type_flag);
    else
        [code, added] = rsenco(msg, n, k, type_flag, opt);
    end;
else
    if strfind(method, 'p')
        error('comm:encode:InvalidMessageFormat','Message format must be either binary or decimal.');
    end

    % error checking for N & K
    if (floor(n) ~= n) || (n<1)
        error('comm:encode:InvalidN','The codeword length, N must be a positive integer greater than 0.');
    end

    if (floor(k) ~= k) || (k<1)
        error('comm:encode:InvalidK','The message length, K must be a positive integer greater than 0.');
    end

    if (n <= k)
        error('comm:encode:NLessThanK','The codeword length, N must be greater than the message length, K.');
    end

    isRowVector = false; % this variable is used to determine if input is a
    % row vector
    % make msg to be a column vector when it is a vector.
    if min(size(msg)) == 1
        isRowVector = (size(msg,1) == 1); %check if msg is a Row Vector
        msg = msg(:);
    end;

    added = 0;
    m_msg = size(msg, 2);

    if ~isempty(findstr(method, 'decimal'))
        type_flag = 1;      % decimal
        if m_msg > 1
            method = method(1:(find(method=='/')-1));
            error('comm:encode:MsgNotVector',['For ',method,' code with decimal data, MSG must be a vector.'])
        else
            if ~isempty([find(msg > 2^k-1); find(msg < 0); find(floor(msg)~=msg)])
                error('comm:encode:InvalidMSG','For decimal data processing, MSG must contain only integers between 0 and 2^K-1.')
            end;
        end;
        msg = de2bi(msg, k);
    else
        type_flag = 0;      % binary matrix
        if ~isempty([find(msg > 1); find(msg < 0); find(floor(msg)~=msg)])
            error('comm:encode:InvalidMsgDataFormat','MSG does not match specified data format.  Either make MSG binary or append /decimal to the method string.')
        end;
        if m_msg == 1
            type_flag = 2;  % binary vector
            [msg, added] = vec2mat(msg, k);
        elseif m_msg ~= k
            error('comm:encode:InvalidMatrixColumnSize','The matrix MSG in ENCODE must have K columns.');
        end;
    end;
    % at this stage MSG is a K-column matrix
    if ~isempty(findstr(method, 'bch'))
        % BCH code.
        if nargin <= 4
            code = bchenco(msg, n, k);
        else
            code = bchenco(msg, n, k, opt);
        end;
    elseif ~isempty(findstr(method, 'hamming'))
        % hamming code.
        m = n - k;
        if 2^m - 1 ~= n
            error('comm:encode:InvalidNKLen','The specified codeword length and message length are not valid.')
        end;
        if nargin <= 4
            h = hammgen(m);
        else
            h = hammgen(m, opt);
        end;
        gen = gen2par(h);
        code = rem(msg * gen, 2);
    elseif ~isempty(findstr(method, 'linear'))
        % block code.
        if nargin < 5
            error('comm:encode:MissingGenMatrix','The generator matrix is a required input argument for linear block code.');
        end;
        [n_opt, m_opt] = size(opt);
        if (m_opt ~= n) || (n_opt ~= k)
            error('comm:encode:InvalidGenMatrixDims','The generator matrix dimensions are not valid.');
        end;
        code = rem(msg * opt, 2);
    elseif ~isempty(findstr(method, 'cyclic'))
        if nargin < 5

            % turn off the warning that might be generated by CYCLPOLY & record
            % the original state of the warning
            originalState = warning('off','comm:cyclpoly:NoCycGenPolyFound');

            opt = cyclpoly(n, k);

            % set the warning to its original state
            warning(originalState);

            if isempty(opt)
                error('comm:encode:IvalidGenPoly','No generator polynomial satisfies the given constraints of N and K.');
            end

        end;
        [h, gen] = cyclgen(n, opt);
        code = rem(msg * gen, 2);
    elseif ~isempty(findstr(method, 'convol'))
        code = convenco(msg, opt);
    else
        error('comm:encode:CodingMethodUnknown',['Unknown coding method ''',method,'''']);
    end;

    % convert back to the original structure.
    if type_flag == 1
        code = bi2de(code);
    elseif type_flag == 2
        code = code';
        code = code(:);
    end;
    if isRowVector
        % if input MSG was a Row Vector, output CODE must be a Row Vector
        % i.e. preserve the dimensionality across input & output.
        code = code';
    end;
end;

% [EOF] encode.m
