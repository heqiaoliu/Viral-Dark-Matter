function MaxDelays = getDelayInfo(sys,Type)
%GETDELAYINFO Obtain channel delay related information for IDNLARX model.
% 
% DELAYS = GETDELAYINFO(MODEL) obtains the maximum delay in each input and
% output channel of MODEL.
% 
% DELAYS = GETDELAYINFO(MODEL, TYPE) allows the choice between obtaining
% channel delays 'channelwise' or 'all' channels as follows:
%
%   DELAYS is a vector of maximum delay on each I/O channel reported as:
%       TYPE = 'all': DELAYS is the maximum of delays across each
%       output (vector of ny+nu entries, where [ny, nu] = size(MODEL)).
%       This is the default value of TYPE.
%       If TYPE = 'channelwise': A set of delay values separately for each
%       output (ny-by-(ny+nu) matrix).
%
%  DELAYS has delay information arranged column-wise for each channel
%  with output channels preceding the input channels: [y1, y2,.., u1,
%  u2,..]. Delays information is useful for determining how many states the
%  Nonlinear ARX model has.

% Copyright 2007-2008 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2008/10/02 18:53:06 $

if nargin<2
    Type = 'all';
elseif ~any(strcmpi(Type,{'all','channelwise'}))
    ctrlMsgUtils.error('Ident:analysis:delayInfoUnknownType')
end
    
[ny, nu] = size(sys);
na = sys.na; 
nb = sys.nb; 
nk = sys.nk;

custs = sys.CustomRegressors;
if ny==1
    custs = {custs};
end

MaxDelays = zeros(ny,ny+nu);

for k = 1:ny
    MaxDel = zeros(1,ny+nu);
    cust = custs{k};
    LenCust = numel(cust);
    if LenCust>0
        % parse each variable in k'th nonlinearity's custom regressor list
        for i = 1:ny+nu
            Delij = 0;
            for j = 1:LenCust
                Ind = find(cust(j).ChannelIndices == i); % could be non-scalar
                if ~isempty(Ind)
                    thisdel = cust(j).Delays(Ind);
                    Delij = max([Delij,thisdel]); % delay of y_i or u_(i-ny) in reg{i}(j)
                    
                end %if
            end %j
            MaxDel(i) = Delij;
        end %i
    end %if
    MaxDel = max(MaxDel,[na(k,:),nb(k,:)+nk(k,:).*(nb(k,:)>0)-1]);
    MaxDelays(k,:) = MaxDel;
end

if strcmpi(Type,'all')
    MaxDelays = max(MaxDelays,[],1); % max channel delays across all outputs
end

%{
% Some Information:
Nx = sum(AllMaxDelays); % number of states
cumDel = cumsum(AllMaxDelays)+1;
CumInd = [1,cumDel(1:end-1)]; 
%}
