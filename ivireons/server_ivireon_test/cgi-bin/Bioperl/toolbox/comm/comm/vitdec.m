function varargout = vitdec(code,trellis,tblen,opmode,dectype,varargin)
%VITDEC Convolutionally decode binary data using the Viterbi algorithm.
%   DECODED = VITDEC(CODE,TRELLIS,TBLEN,OPMODE,DECTYPE) decodes the vector CODE
%   using the Viterbi algorithm.  CODE is assumed to be the output of a 
%   convolutional encoder specified by the MATLAB structure TRELLIS.  See
%   POLY2TRELLIS for a valid TRELLIS structure.  Each symbol in CODE consists 
%   of log2(TRELLIS.numOutputSymbols) bits, and CODE may contain one or more 
%   symbols.  DECODED is a vector in the same orientation as CODE, and each of 
%   its symbols consists of log2(TRELLIS.numInputSymbols) bits.  TBLEN is a 
%   positive integer scalar that specifies the traceback depth.
%    
%      OPMODE denotes the operation mode of the decoder. Choices are:
%      'trunc' : The encoder is assumed to have started at the all-zeros state.  
%                The decoder traces back from the state with the best metric.
%      'term'  : The encoder is assumed to have both started and ended at the 
%                all-zeros state.  The decoder traces back from the all-zeros
%                state.
%      'cont'  : The encoder is assumed to have started at the all-zeros state.
%                The decoder traces back from the state with the best metric.  A
%                delay equal to TBLEN symbols is incurred.
%    
%      DECTYPE denotes how the bits are represented in CODE.  Choices are:
%      'unquant' : The decoder expects signed real input values.  +1 represents
%                  a logical zero and -1 represents a logical one.
%      'hard'    : The decoder expects binary input values.
%      'soft'    : See the syntax below.
%
%   DECODED = VITDEC(CODE,TRELLIS,TBLEN,OPMODE,'soft',NSDEC) decodes the input
%   vector CODE consisting of integers between 0 and 2^NSDEC-1, where
%   0 represents the most confident 0 and 2^NSDEC-1 represents the most 
%   confident 1.
%   Note that NSDEC is a required argument if and only if the decision type is
%   'soft'.
%
%   DECODED = VITDEC(CODE, TRELLIS, TBLEN, OPMODE, DECTYPE, PUNCPAT)
%   decodes the input punctured CODE where PUNCPAT is the puncture pattern
%   vector of 1's and 0's with 0's indicating where the punctures occurred
%   in the data stream.
%
%   DECODED = VITDEC(CODE, TRELLIS, TBLEN, OPMODE, DECTYPE, PUNCPAT, ERASPAT)
%   allows an erasure pattern (ERASPAT) vector to be specified for the input
%   CODE where the 1's indicate the corresponding erasures. ERASPAT and CODE
%   must be of the same length. If puncturing is not used, specify PUNCPAT
%   to be []. 
%    
%   DECODED = VITDEC(..., 'cont', ..., INIT_METRIC,INIT_STATES,INIT_INPUTS)
%   provides the decoder with initial state metrics, initial traceback states
%   and initial traceback inputs.  Each real number in INIT_METRIC represents
%   the starting state metric of the corresponding state.  INIT_STATES and 
%   INIT_INPUTS jointly specify the initial traceback memory of the decoder.
%   They are both TRELLIS.numStates-by-TBLEN matrices.  INIT_STATES consists of
%   integers between 0 and TRELLIS.numStates-1.  INIT_INPUTS consists of 
%   integers between 0 and TRELLIS.numInputSymbols-1.  To use default values for
%   all of the last three arguments, specify them as [],[],[].
%   
%   [DECODED FINAL_METRIC FINAL_STATES FINAL_INPUTS] = VITDEC(..., 'cont', ...)
%   returns the state metrics, traceback states and traceback inputs at the end
%   of the decoding process.  FINAL_METRIC is a vector with TRELLIS.numStates 
%   elements which correspond to the final state metrics.  FINAL_STATES and 
%   FINAL_INPUTS are TRELLIS.numStates-by-TBLEN matrices.
%   
%   Example:
%       t = poly2trellis([3 3],[4 5 7;7 4 2]);  k = log2(t.numInputSymbols);
%       msg = [1 1 0 1 1 1 1 0 1 0 1 1 0 1 1 1];
%       code = convenc(msg,t);    tblen = 3;
%       [d1 m1 p1 in1]=vitdec(code(1:end/2),t,tblen,'cont','hard')
%       [d2 m2 p2 in2]=vitdec(code(end/2+1:end),t,tblen,'cont','hard',m1,p1,in1)
%       [d m p in] = vitdec(code,t,tblen,'cont','hard')
%    
%       % The same decoded message is returned in d and [d1 d2].  The pairs m and 
%       % m2, p and p2, in and in2 are equal.  Note that d is a delayed version of 
%       % msg, so d(tblen*k+1:end) is the same as msg(1:end-tblen*k).
%    
%   See also CONVENC, POLY2TRELLIS, ISTRELLIS.

% Copyright 1996-2009 The MathWorks, Inc.
% $Revision: 1.15.4.10 $  $Date: 2009/12/05 01:58:09 $

% Check number of input arguments
error(nargchk(5,11,nargin,'struct'));

% Check number of output arguments
if nargout>4
    error('comm:vitdec:TooManyArgs','Too many output arguments.');
end
nvarargin = nargin - 5;

% Define macros

% Opmode
CONT  = 1;
TRUNC = 2;
TERM  = 3;

% Dectype
UNQUANT = 1;
HARD    = 2;
SOFT    = 3;

% Puncturing/Erasures Modes
NONE = 0;
PUNC = 1;     % punctures only
ERAS = 2;     % erasures only
PUNCERAS = 3; % both

% Value set indicators (used for setting optional inputs)
initTableSet  = 0;

% Set default values for optional inputs
nsdec         = 1;
puncVector    = [];
erasVector    = [];
initmetric    = [];
initstate     = [];
initinput     = [];
% Set an puncturing/erasures mode flag
puncErasMode  = NONE;

% Check trellis
if ~istrellis(trellis),
    error('comm:vitdec:inVTrellis', 'Trellis is not valid.');
end

k = log2(trellis.numInputSymbols);
n = log2(trellis.numOutputSymbols);
outputs = oct2dec(trellis.outputs);

if ~ischar(opmode)
    error('comm:vitdec:charOpMode',...
          'Operation mode must be specified by a character string.');
end
if ~ischar(dectype)
    error('comm:vitdec:charDecType',...
          'Decision type must be specified by a character string.');
end

% Set opmode
switch lower(opmode)
case {'cont'}
   opmodeNum = CONT;
case {'trunc'}
   opmodeNum = TRUNC;
case {'term'}
   opmodeNum = TERM;
otherwise
   error('comm:vitdec:InvalidOpMode','Unknown operation mode passed in.');
end; 

% Check : only 1 output is allowed for 'term and 'trunc' modes
if ( opmodeNum~=CONT && nargout>1 )
    error('comm:vitdec:termTrunc', ...
          ['The decoded message is the only output allowed for the '...
           'Truncated and Terminated\noperation modes.'])
end

% Set dectype
switch lower(dectype)
case {'unquant'}
   dectypeNum = UNQUANT;
case {'hard'}
   dectypeNum = HARD;
case {'soft'}
   dectypeNum = SOFT;
otherwise
   error('comm:vitdec:InvalidDecType','Unknown decision type passed in.');
end;

% --- Parsing of optional inputs
errMsgId = 'comm:vitdec:TooManyInputs';
errMsg = 'Invalid syntax.  Too many input arguments.';
if nvarargin > 0
    if (dectypeNum == SOFT)
        nsdec = varargin{1}; % has to be
        switch nvarargin
            case 1 % vitdec(..., nsdec);
            case 2 % vitdec(..., nsdec, pVec);
                puncVector   = varargin{2};
                puncErasMode = PUNC;
            case 3 % vitdec(..., nsdec, pVec, eVec);
                if isempty(varargin{2}) && isempty(varargin{3})
                    error('comm:vitdec:InvalidPuncPatErasPat', ...
                        ['PUNCPAT and ERASPAT cannot be both empty arrays.',...
                        ' If you would like to use the default values, do',...
                        ' not specify these arguments. If you want to', ...
                        ' specify ERASPAT only, then specify PUNCPAT as an',...
                        ' empty array.']);
                elseif isempty(varargin{3})
                    error('comm:vitdec:InvalidErasPat', ...
                        ['ERASPAT cannot be an empty array if PUNCPAT',...
                        ' has been specified. If you would like to use the',...
                        ' default ERASPAT do not specify this argument.']);                    
                end
                [puncVector, erasVector] = deal(varargin{2:end});
                puncErasMode = PUNCERAS;
            case 4 % vitdec(..., nsdec, initM, initS, initInp);
                if (opmodeNum == CONT)
                    [initmetric, initstate, initinput] = deal(varargin{2:end});
                    puncErasMode = NONE;
                else
                    error(errMsgId, errMsg);
                end
            case 5 % vitdec(..., nsdec, pVec, initM, initS, initInp);
                if (opmodeNum == CONT)
                    [puncVector, initmetric, initstate, ...
                        initinput] = deal(varargin{2:end});
                    puncErasMode = PUNC;
                else
                    error(errMsgId, errMsg);
                end
            case 6 % vitdec(..., nsdec, pVec, eVec, initM, initS, initInp);
                if (opmodeNum == CONT)
                    [puncVector, erasVector, initmetric, initstate,...
                        initinput] = deal(varargin{2:end});
                    puncErasMode = PUNCERAS;
                else
                    error(errMsgId, errMsg);
                end
        end % end switch
    else % hard or unquantized => no nsdec specified
        switch nvarargin
            case 1 % vitdec(..., pVec);
                puncVector = varargin{1};
                puncErasMode = PUNC;
            case 2 % vitdec(..., pVec, eVec);
                if isempty(varargin{1}) && isempty(varargin{2})
                    error('comm:vitdec:InvalidPuncPatErasPat', ...
                        ['PUNCPAT and ERASPAT cannot be both empty arrays.',...
                        ' If you would like to use the default values, do',...
                        ' not specify these arguments. If you want to', ...
                        ' specify ERASPAT only, then specify PUNCPAT as an',...
                        ' empty array.']);
                elseif isempty(varargin{2})
                    error('comm:vitdec:InvalidErasPat', ...
                        ['ERASPAT cannot be an empty array if PUNCPAT',...
                        ' has been specified. If you would like to use the',...
                        ' default ERASPAT do not specify this argument.']);                    
                end
                [puncVector, erasVector] = deal(varargin{:});
                puncErasMode = PUNCERAS;
            case 3 % vitdec(..., initM, initS, initInp);
                if (opmodeNum == CONT)
                    [initmetric, initstate, initinput] = deal(varargin{:});
                    puncErasMode = NONE;
                else
                    error(errMsgId, errMsg);
                end
            case 4 % vitdec(..., pVec, initM, initS, initInp);
                if (opmodeNum == CONT)
                    [puncVector, initmetric, initstate,...
                        initinput] = deal(varargin{:});
                    puncErasMode = PUNC;
                else
                    error(errMsgId, errMsg);
                end
            case 5 % vitdec(..., pVec, eVec, initM, initS, initInp);
                if (opmodeNum == CONT)
                    [puncVector, erasVector, initmetric, initstate,...
                        initinput] = deal(varargin{:});
                    puncErasMode = PUNCERAS;
                else
                    error(errMsgId, errMsg);
                end
            otherwise
                error(errMsgId, errMsg);
        end % end switch
    end % end if (dectypeNum == SOFT)
else % no optional args
    if (dectypeNum == SOFT)
        error('comm:vitdec:NoBits', ['Number of soft decision bits must be provided ' ,...
                                     'for the ''soft'' decision type.']);
    end
end

% Set flag for memory
if ~(isempty(initmetric) && isempty(initstate) && isempty(initinput))
    initTableSet = 1; % Indicates that traceback memory is given
end

% Parameter checking
% Check code
if ~isempty(code)
    code_dim = size(code);
    if ~( isnumeric(code) || islogical(code) ) || ...
       length(code_dim) > 2                    || ...
       ~( isvector(code) && ~isscalar(code) )  || ...
       max(max(~isfinite(code)))               || ...
       ~isreal(code)
        error('comm:vitdec:InvCode',...
              'CODE must be a vector of real or logical values.')
    end
    outLog = islogical(code);   % for output data type
    code   = double(code);      % for proper numerical operation    
    
    if max(max(code < 0)) || (max(max(floor(code) ~= code)))
        if dectypeNum == HARD && max(max(code)) > 1
            error('comm:vitdec:InvCode',...
                  'For hard decision type, CODE must contain only binary values.');
        elseif dectypeNum == SOFT && max(max(code)) > 2^nsdec-1
            error('comm:vitdec:InvCode',...
                  ['For soft decision type, CODE must contain only integers ', ...
                   'between 0 and 2^NSDEC-1.']);
        end
    end
    
    % check only if not punctured
    if ( (puncErasMode == NONE) || (puncErasMode == ERAS) )
        if mod(length(code), n) ~=0
            error('comm:vitdec:invalidCodeLength', ...
                ['Length of the input code vector must be a multiple of the ', ...
                'number of bits in an\n input symbol.'])
        end
    end
    
    % Get code orientation
    if code_dim(1)>1
        code_flip = 1;
        code=code';
    else
        code_flip = 0;
    end
end

% Check tblen
if (~isscalar(tblen) || ...
   ~isnumeric(tblen) || ...
   ~isreal(tblen)    || ...
   ~isfinite(tblen)  || ...
   tblen<=0          || ...
   floor(tblen)~=tblen )
    error('comm:vitdec:tracebackDepth', ...
          'Traceback depth must be a positive integer scalar.');

elseif ~isempty(code) && (opmodeNum ~= CONT && tblen>length(code)/n )
    error('comm:vitdec:tracebackDepth', ...
         ['For the ''term'' and ''trunc'' modes, traceback depth ', ...
          'must be a positive integer scalar not larger than the ', ...
          'number of input symbols in CODE.'])
end

% Check nsdec if dectype=='soft'
if (dectypeNum == SOFT)
    if (~isscalar(nsdec)  || ...
       ~isnumeric(nsdec) || ...
       ~isreal(nsdec)    || ...
       nsdec<0           || ...
       floor(nsdec)~=nsdec )
        error('comm:vitdec:invBits',...
              ['Number of soft decision bits must be a positive ', ...
               'scalar integer.']);
    end
end

% Check Puncture vector if specified
if ~isempty(puncVector)
    % Validity check
    if ~( isnumeric(puncVector) || islogical(puncVector) ) || ...
       length(size(puncVector)) > 2                        || ...
       ~( isvector(puncVector) && ~isscalar(puncVector) )  || ...
       max(max(~isfinite(puncVector)))                     || ...
       ~isreal(puncVector)
        error('comm:vitdec:invPuncPat', ['The puncture pattern parameter',...
              ' must be a vector of real or logical values.']);
    end
    puncVector = double(puncVector);  % cast to doubles for numerics

    % Binary value check
    if any(puncVector~=0 & puncVector~=1)
        error('comm:vitdec:PuncPatBinary', ...
               ['The puncture pattern parameter must be a binary vector of ',...
               '1''s and 0''s only.']);
    end

    if (puncErasMode == PUNC) || (puncErasMode == PUNCERAS)
        % Length checks
        if mod(length(code), sum(puncVector)) ~=0 
            error('comm:vitdec:codeLengthPunc', ...
                   ['The input code length must be an integer multiple of ',...
                    'the number of ones in the\npuncture pattern parameter.']);
        end
        if mod( (length(code)/sum(puncVector))*length(puncVector), n) ~=0 
            error('comm:vitdec:codeLengthPuncN', ...
                   ['The input code length divided by the number of ones in',...
                    ' the puncture pattern\ntimes the length of the puncture',...
                    ' pattern must be an integer multiple of the number\nof',...
                    ' bits in an input symbol.']);
        end
    end

    % Use always a row vector
    if (size(puncVector, 1) > 1)
        puncVector = puncVector';
    end
else % puncVector is empty
    if (puncErasMode == PUNCERAS)
        puncErasMode = ERAS; % only erasures were specified
    elseif (puncErasMode == PUNC)
        error('comm:vitdec:InvPuncture', ...
               ['The puncture pattern parameter must be a binary vector of ',...
               '1''s and 0''s only. If you want to use the default PUNCPAT',...
               ', and ERASPAT values, do not specify this parameter.']);
    end
end

% Check Erasures vector if specified
if ~isempty(erasVector)
    % validity check
    if ~( isnumeric(erasVector) || islogical(erasVector) ) || ...
       length(size(erasVector)) > 2                    || ...
       ~( isvector(erasVector) && ~isscalar(erasVector) )  || ...
       max(max(~isfinite(erasVector)))               || ...
       ~isreal(erasVector)
        error('comm:vitdec:erasVector', ['The erasures pattern parameter',...
              ' must be a vector of real or logical values.']);
    end
    erasVector = double(erasVector);  % cast to doubles for numerics

    % Binary value check
    if any(erasVector~=0 & erasVector~=1)
        error('comm:vitdec:erasVectorBinary', ...
               ['The erasures pattern parameter must be a binary vector of 1''s ',...
                'and 0''s only.']);
    end

    % Length check
    if (puncErasMode == ERAS) || (puncErasMode == PUNCERAS)
        if (length(code) ~= length(erasVector))
            error('comm:vitdec:codeLengthEras', ...
                   ['The length of the erasures pattern parameter must',...
                    ' be the same as the input code length.']);
        end
    end
end
    
% Check initmetric, initstate, initinput
if (initTableSet == 1)
    if ~isnumeric(initmetric) || ...
       ~(isvector(initmetric)&&~isempty(initmetric)&&~isscalar(initmetric)) || ...
       length(initmetric)~=trellis.numStates || ...
       max(max(~isfinite(initmetric))) || ...
       ~isreal(initmetric)
         
       if isempty(initmetric)
          error('comm:vitdec:emptyDefaults', ...
               ['When using [] as the default for INIT_METRIC, ' ,...
                'INIT_STATES and INIT_INPUTS must\n' ,...
                'also be [].'])
       else
          error('comm:vitdec:invalidStates', ...
               ['The initial state metrics must be a real vector with ', ...
                'length equal to the number\n' ,...
                'of states in the specified trellis.'])
       end
    end
    
    dimState = size(initstate);
    if ~isnumeric(initstate)                         || ...
       ~isequal(dimState, [trellis.numStates tblen]) || ...
       max(max(~isfinite(initstate)))                || ...
       ~isreal(initstate)                            || ...
       max(max(floor(initstate)~=initstate))         || ...
       min(initstate(:))<0                           || ...
       max(initstate(:)>trellis.numStates-1)
         
       if isempty(initstate)
          error('comm:vitdec:emptyDefaults', ...
               ['When using [] as the default for INIT_STATES, ' ,...
                'INIT_METRIC and INIT_INPUTS must\n' ,...
                'also be [].'])
       else
          error('comm:vitdec:invalidTBStates', ...
               ['The initial traceback states must be integers ' ,...
                'between 0 and\n' ,...
                '(number of states - 1), arranged in a matrix.  ' ,...
                'Its number of rows must equal the\n' ,...
                'number of states in the specified trellis, ' ,...
                'and its number of columns must equal\n' ,...
                'the traceback depth.'])
       end
    end
    
    dimInput = size(initinput);
    if ~isnumeric(initinput)                         || ...
       ~isequal(dimInput, [trellis.numStates tblen]) || ...
       max(max(~isfinite(initinput)))                || ...
       ~isreal(initinput)                            || ...
       max(max(floor(initstate)~=initstate))         || ...
       min(initstate(:))<0                           || ...
       max(initstate(:)>trellis.numStates-1)
         
       if isempty(initinput)
          error('comm:vitdec:emptyDefaults', ...
               ['When using [] as the default for INIT_INPUTS, ' ,...
                'INIT_METRIC and INIT_STATES must\n' ,...
                'also be [].'])
       else
          error('comm:vitdec:invalidTBInputs', ...
               ['The initial traceback inputs must be integers ' ,...
                'between 0 and\n' ,...
                '(number of states - 1), arranged in a matrix.  ' ,...
                'Its number of rows must equal the\n' ,...
                'number of states in the specified trellis, ' ,...
                'and its number of columns must equal\n' ,...
                'the traceback depth.'])
       end
    end
end

% Return if input code is empty
if isempty(code)
    varargout{1} = [];
    varargout{2} = initmetric;
    varargout{3} = initstate;
    varargout{4} = initinput;
    return;
end

% Call to vit.c
[varargout{1} varargout{2} varargout{3} varargout{4}] ...
    = vit(code, k, n, trellis.numStates, outputs, trellis.nextStates,...
          tblen, opmodeNum, dectypeNum, nsdec, puncErasMode, puncVector,...
          erasVector, initTableSet, initmetric, initstate, initinput);

% Change message back to same orientation as the input code if needed
if code_flip
    varargout{1}=(varargout{1})';
end

% Set output data type to logical if appropriate
if outLog, varargout{1} = logical(varargout{1}); end;

% [EOF]
