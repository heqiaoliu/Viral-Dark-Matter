function varargout = convenc(msg, trellis, varargin)
%CONVENC Convolutionally encode binary data.
%   CODE = CONVENC(MSG,TRELLIS) encodes the binary vector MSG using the
%   convolutional encoder defined by the MATLAB structure TRELLIS.  See
%   POLY2TRELLIS and ISTRELLIS for a valid TRELLIS structure.  The encoder
%   starts at the all-zeros state.  Each symbol in MSG consists of
%   log2(TRELLIS.numInputSymbols) bits.  MSG may contain one or more symbols.
%   CODE is a vector in the same orientation as MSG, and each of its symbols
%   consists of log2(TRELLIS.numOutputSymbols) bits.
%
%   CODE = CONVENC(MSG, TRELLIS, PUNCPAT) is the same as the syntax above,
%   except that it specifies a puncture pattern (PUNCPAT) to allow higher 
%   rate encoding. PUNCPAT must be a vector of 1's and 0's where the 0's
%   indicate the punctured bits. PUNCPAT must have a length of at least
%   log2(TRELLIS.numOutputSymbols) bits.
%
%   CODE = CONVENC(...,INIT_STATE) is the same as the syntaxes above,
%   except that the encoder registers start at a state specified by 
%   INIT_STATE. INIT_STATE is an integer between 0 and 
%   TRELLIS.numStates - 1 and must be the last input parameter.  
%
%   [CODE FINAL_STATE] = CONVENC(...) returns the final state FINAL_STATE of
%   the encoder after processing the input message.
%
%   Example:
%       t = poly2trellis([3 3],[6 5 1;7 2 5]);
%       msg = [1 1 0 1 0 0 1 1];
%       [code1 state1]=convenc(msg(1:end/2),t);
%       [code2 state2]=convenc(msg(end/2+1:end),t,state1);
%       [codeA stateA]=convenc(msg,t);
%
%       % The same result will be returned in [code1 code2] and codeA.
%       % The final states state2 and stateA are also equal.
%
%   See also VITDEC, POLY2TRELLIS, ISTRELLIS, DISTSPEC.

% Copyright 1996-2008 The MathWorks, Inc.
% $Revision: 1.11.4.8 $  $Date: 2008/12/04 22:16:21 $
% Calls convcore.c

% Typical error checking.
error(nargchk(2,4,nargin,'struct'));

nvarargin = nargin - 2;

% Set defaults
punctVec = [];
initialstate = 0;

switch (nvarargin)
case 1
    if ~isempty(varargin{1})
        if isscalar(varargin{1})
            initialstate = varargin{1};
        else
            punctVec = varargin{1};
        end
    end
case 2
    [punctVec, initialstate] = deal(varargin{:});
end

if nargout > 2
    error('comm:convenc:TooManyOutputArg','Too many output arguments.');
end

% check trellis
if ~istrellis(trellis),
    error('comm:convenc:InvalidTrellis','Trellis is not valid.');
end

% Get info out of trellis structure
k = log2(trellis.numInputSymbols);
n = log2(trellis.numOutputSymbols);
outputs = oct2dec(trellis.outputs);

% Check msg
if ~isempty(msg)
    msg_dim = size(msg);
    if ~( isnumeric(msg) || islogical(msg) ) || ...
          length(msg_dim)>2                  || ...
          min(msg_dim)>1
        error('comm:convenc:InvalidMsg','The input message must be a logical or numeric vector.');
    end
    outLog = islogical(msg);   % for output data type
    msg    = double(msg);      % for proper numerical operation
    
    if max(max(msg < 0))           || ...
       max(max(~isfinite(msg)))    || ...
       ~isreal(msg)                || ...
       max(max(floor(msg) ~= msg)) || ...
       max(max(msg)) > 1
        error('comm:convenc:InputNotBinary','The input message must contain only binary values.');
    end
    if mod(length(msg), k) ~=0
        error('comm:convenc:InvalidMsgLength',['Length of the input message must be a multiple of the ' ...
               'number of bits in an input symbol.']);
    end

    % Get message orientation
    if msg_dim(1)>1
        msg_flip = 1;
        msg=msg';
    else
        msg_flip = 0;
    end
end

% Check Puncture vector
if ~isempty(punctVec)
    % Validity check
    if ~( isnumeric(punctVec) || islogical(punctVec) )   || ...
       length(size(punctVec)) > 2                        || ...
       ~( isvector(punctVec) && ~isscalar(punctVec) )   || ...
       max(max(~isfinite(punctVec)))                     || ...
       ~isreal(punctVec)
        error('comm:convenc:InvalidPuncPat', ['The puncture pattern parameter',...
              ' must be a vector of real or logical values.']);
    end

    % Binary value check
    if any(punctVec~=0 & punctVec~=1)
        error('comm:convenc:PuncPatNotBinary', ...
               ['The puncture pattern parameter must be a binary vector of 1''s ',...
                'and 0''s only.']);
    end

    % Length checks
    if length(punctVec) < n
        error('comm:convenc:InvalidPuncPatLength',...
              ['The puncture pattern parameter length must be at least the ',...
               'number of bits in an output symbol.']);
    end
    
    if mod((length(msg)/k)*n, length(punctVec)) ~=0
        error('comm:convenc:InvalidCodeLengthPunc', ...
            ['The input message length divided by the base code rate must be an',...
            '\ninteger multiple of the length of the puncture pattern parameter.']);
    end
end

% Check initial state
if ~isnumeric(initialstate)                      || ...
   ~isscalar(initialstate)                       || ...
   max(max(initialstate < 0))                    || ...
   max(max(~isfinite(initialstate)))             || ...
   ~isreal(initialstate)                         || ...
   max(max(floor(initialstate) ~= initialstate)) || ...
   max(max(initialstate)) > trellis.numStates-1
    error('comm:convenc:InvalidInitialState',['The initial state must be an integer scalar between 0 and ' ...
           '(TRELLIS.numStates-1).  See POLY2TRELLIS.']);
end

% Return if input message is empty
if isempty(msg)
    varargout{1} = [];
    varargout{2} = initialstate;
    return;
end

% Actual call to core function 'convcore.c'
[code, fstate] = ...
    convcore(msg,k,n,trellis.numStates,outputs,trellis.nextStates,initialstate);

if ~isempty(punctVec)
    % Expand punctVec if needed
    if length(code) ~= length(punctVec)
        pVec = punctVec(:);
        bb = pVec(:, ones(1, length(code)/length(punctVec))); % repeat
        punctVec = bb(:);                                     % vector
    end

    % Puncture the encoded output
    code(~logical(punctVec)) = [];
end

% Change code back to same orientation as input MSG
if msg_flip
    code=code';
end

% Set output data type to logical if appropriate
if outLog, code = logical(code); end;

% Set outputs
varargout = {code, fstate};

% [EOF]
