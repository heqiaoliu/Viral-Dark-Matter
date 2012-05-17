function X0 = data2state(nlsys, iostruct)
%DATA2STATE Map input/output data to initial state values of IDNLARX model.
%
%   X0 = DATA2STATE(MODEL, IOSTRUCT)
%   Map the input and output samples provided in IOSTRUCT to the initial
%   states X0 of MODEL. The data provided in IOSTRUCT are interpreted as
%   "past" samples of data. In other words, the returned state values
%   should be interpreted as values at the time immediately after the time
%   corresponding to the last (most recent) in the data.
%
%   IOSTRUCT should be a struct with fields 'Input' and 'Output'. Each
%   field should contain data samples for model's input or output.
%   'Input': Specify a matrix of NU (= number of inputs) columns. The
%            number of rows must be equal to the maximum input delay in
%            MODEL (maximum across all input channels). 
%   'Output':Specify a matrix of NY (= number of outputs) columns. The
%            number of rows must be equal to the maximum output delay in
%            MODEL (maximum across all output channels). 
%   For either field, a vector of constant values may be specified to
%   denote a constant signal level.
%
%   X0 = DATA2STATE(MODEL, DATA)
%   Map the input and output samples from the IDDATA object DATA to the
%   initial states X0 of MODEL. The number of samples in DATA should not
%   be less than the maximum delay in the model (across all input and
%   output channels). X0 is the value of model's states at time t0 =
%   DATA.SamplingInstants(end)+DATA.Ts. 
%
%   To determine maximum delay in each input and output channel of MODEL,
%   use "getDelayInfo" command. Maximum delays are returned as a vector of
%   integers in the order: [Output_delays, Input_delays]. Then: 
%       number of rows in IOSTRUCT.Output = max(Output_delays)
%       number of rows in IOSTRUCT.Input  = max(Input_delays)
%       number of data samples in DATA = max([Output_delays, Input_delays])
%
%   The samples in IOSTRUCT or DATA should be in the order of increasing
%   time (last row of values is the most recent in time). 
%
%   State definition: The states of an IDNLARX model are defined using time
%   delayed input/output variables of the model. The number of delayed
%   terms used for each I/O variable is dictated by the maximum lag of
%   that variable in the model's regressors. See idnlarx/getDelayInfo for
%   more information.
%
% Example: Suppose MODEL has 3 inputs and 2 outputs.
%   MaxDelays =  getDelayInfo(MODEL) % delays arranged channelwise
%   IOSTRUCT = struct('Input', rand(max(MaxDelays(ny+1:end)),3),...
%                     'Output', rand(max(MaxDelays(1:ny)), 2))
%
%   Suppose input is constant with values (10, 20, 30) for the three input
%   channels. Then IOSTRUCT.Input = [10, 20, 30] could be used in place of
%   a  matrix of values. Given IOSTRUCT, initial state values will be:
%   X0 = DATA2STATE(MODEL, IOSTRUCT);
%
%   See also IDNLARX/FINDOP, IDNLARX/FINDSTATES, IDNLARX/GETDELAYINFO,
%   GETREG.

% Copyright 2007-2009 The MathWorks, Inc.
% $Revision: 1.1.8.7 $ $Date: 2009/10/16 04:56:53 $

error(nargchk(2, 2, nargin,'struct'))

if ~isa(iostruct,'iddata') && (~isstruct(iostruct) || ~all(ismember({'Input','Output'},fieldnames(iostruct))))
    ctrlMsgUtils.error('Ident:analysis:data2stateInvalidInput')
end

[ny, nu] = size(nlsys);
Delays = getDelayInfo(nlsys);
yDel = Delays(1:ny);
uDel = Delays(ny+1:end);

if isstruct(iostruct)
    U = iostruct.Input;
    Y = iostruct.Output;
    [U,msg] = LocalValidateStructData(U,nu,max(uDel),'Input');
    if ~isempty(msg.message)
        error(msg);
    end

    [Y,msg] = LocalValidateStructData(Y,ny,max(yDel),'Output');
    if ~isempty(msg.message)
        error(msg);
    end
else
    U = iostruct.InputData;
    Y = iostruct.OutputData;
    [sampLen,nyd,nud] = size(iostruct);
    if isnan(iostruct)
        ctrlMsgUtils.error('Ident:general:idprepMissingData')
    elseif (ny~=nyd) || (nu~=nud)
        ctrlMsgUtils.error('Ident:general:dataModelDimMismatch',nu,ny)
    elseif sampLen<max(Delays)
        ctrlMsgUtils.error('Ident:analysis:data2stateTooFewSamples',max(Delays))
    end
end

X0 = data2finalstate(nlsys,U,Y);

%--------------------------------------------------------------------------
function [x,msg] = LocalValidateStructData(x,nx,xDel,Type)
% validate Input and Output fields of IOSTRUCT

msg = struct('identifier','','message','');
if (ndims(x)~=2) || ~isrealmat(x) || ~all(isfinite(x(:))) || ...
        size(x,2)~=nx || (~isempty(x) && size(x,1)~=1 && size(x,1)<xDel)
    msg.identifier = sprintf('Ident:analysis:data2stateInvalid%sField',Type);
    msg.message = sprintf('In the "data2state(NLSYS, IOSTRUCT)" command, ''%s'' field of IOSTRUCT must be set to a real matrix of size [1 %d] or [%d %d].',...
        Type,nx,xDel,nx);
    return
end

% scalar expansion for single-row data
if ~isempty(xDel) && (xDel>1) && (size(x,1)==1)
    x = repmat(x,xDel,1);
end
