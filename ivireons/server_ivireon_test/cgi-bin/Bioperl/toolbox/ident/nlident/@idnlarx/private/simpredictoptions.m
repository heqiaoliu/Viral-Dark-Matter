function [xinit, matching, defaultnoise, progdisp] = simpredictoptions(optnames, charset, varargin)
%SIMPREDICTOPTIONS: process optional arguments of sim and predict of IDNLARX models.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/10/02 18:53:25 $

% Author(s): Qinghua Zhang

isinpredict = any(strcmpi('e', charset));

% Default values
if isinpredict
    xinit = 'e';
    command = 'predict';
else
    xinit = 'z';
    command = 'sim';
end
xinitdf = xinit;
matching = false;
defaultnoise = false;
progdisp = false;

nvi = length(varargin);
if (nvi==1 || (nvi==2 && islogical(varargin{2}))) && ...
        (isempty(varargin{1}) || isa(varargin{1},'iddata') || isrealmat(varargin{1}) ||...
        (ischar(varargin{1}) && any(strcmpi(varargin{1},charset))))
    
    % Handle the case of command(..., xinit, progdisp) for backward
    % compatibility
    if ~isempty(varargin{1})
        xinit = varargin{1};
    end
    if nvi==2 && islogical(varargin{2})
        progdisp = varargin{2};
    end
    
else % P-V style options
    
    nameIndex = zeros(nvi,1);
    
    for kv=1:nvi
        argkv = varargin{kv};
        
        if nameIndex(kv)==0 && ischar(argkv) && ~any(strcmpi(argkv, charset))
            ind = strmatch(lower(argkv), lower(optnames));
            if length(ind)~=1
                %G416442
                ctrlMsgUtils.error('Ident:general:invalidOption',argkv,command, ['idnlarx/',command]);
            end
            nameIndex(kv) = ind;
            
            switch optnames{ind}
                case 'Noise'
                    defaultnoise = true;
                case 'InitialState'
                    if kv>=nvi
                        ctrlMsgUtils.error('Ident:general:CompleteOptionsValuePairs',command,['idnlarx/',command])
                    end
                    nameIndex(kv+1) = -1; % Note: "-1" as marker of value argument.
                    
                    xinit = varargin{kv+1};
                    if ~(isempty(xinit) || isa(xinit,'iddata') || ...
                            (ischar(xinit) && any(strcmpi(xinit,charset))) || isrealmat(xinit))
                        ctrlMsgUtils.error('Ident:analysis:X0val',command,['idnlarx/',command])
                    end
                    if isempty(xinit)
                        xinit = xinitdf;
                    end
                case 'Matching'
                    if length(argkv)<5
                        % 'Matching' must be at least specified as 'match'.
                        %G416442
                        ctrlMsgUtils.error('Ident:general:invalidOption',argkv,command, ['idnlarx/',command])
                    end
                    if kv>=nvi
                        ctrlMsgUtils.error('Ident:analysis:idnlarxMatchingOptVal',['idnlarx/',command])
                    end
                    nameIndex(kv+1) = -1; % Note: "-1" as marker of value argument.
                    
                    matching = true;
                    xinit = varargin{kv+1};
                    if ~isa(xinit,'iddata')
                        ctrlMsgUtils.error('Ident:analysis:idnlarxMatchingOptVal',['idnlarx/',command])
                    end
            end
        end
    end
    
    if nvi>0 && all(nameIndex==0)
        ctrlMsgUtils.error('Ident:general:InvalidSyntax',command,['idnlarx/',command])
    end
    
    for kv=1:nvi
        if nameIndex(kv)>0 && sum(nameIndex(kv)==nameIndex)>1
            ctrlMsgUtils.error('Ident:general:ambiguousOpt',optnames{nameIndex(kv)})
        end
    end
    
end %if (nvi==1 || ...

if ischar(xinit) && strcmpi(xinit, 'm')
    xinit = 'z';
    ctrlMsgUtils.warning('Ident:analysis:idnlmodelModelInitOpt','IDNLARX')
end

% FILE END