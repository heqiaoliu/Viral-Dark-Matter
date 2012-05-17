function [yvec, regmat, msg] = makeregmat(sys, data)
%MAKEREGMAT composes the regression matrix for IDNLARX object.
%  [yvec, regmat, msg] = makeregmat(sys, data)
%
%  yvec: output vector, ny-by-1 cellarray of column vectors
%  regmat: regression matrix, ny-by-1 cellarray of matrices
%  msg: error message, empty if no error.
%
%  sys: IDNLARX object
%  data: IDDATA object
%
%  In case of multi-experiments data, the results of individual
%  experiments are vertically concatenated in yvec and regmat.

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.9 $ $Date: 2009/03/09 19:14:49 $

% Author(s): Qinghua Zhang

error(nargchk(2, 2, nargin, 'struct'));

if ~isa(sys, 'idnlarx')
    ctrlMsgUtils.error('Ident:general:objectTypeMismatch','makeregmat','IDNLARX')
end

% Get data from the IDNLARX object.
na = pvget(sys, 'na');
nb = pvget(sys, 'nb');
nk = pvget(sys, 'nk');
[ny, nu] = size(sys);

regmat = cell(ny,1);
yvec = cell(ny,1);

% Check that data is an IDDATA object or a matrix of appropriate size.
% Convert to IDDATA object if data matrix
[data, msg] = datacheck(data, ny, nu);
if ~isempty(msg)
    return
end

[nobs, nyd, nud, nex] = size(data);

udata  = pvget(data, 'InputData');
ydata = pvget(data, 'OutputData');

% Get custom regressors.
custreg = pvget(sys, 'CustomRegressors');
if isempty(custreg)
    custreg = cell(ny,1);
elseif ~iscell(custreg)
    custreg = {custreg};
end

[maxidelay, nregs] = reginfo(na, nb, nk, custreg);

if nregs==0
    ctrlMsgUtils.error('Ident:estimation:idnlarxNoRegressors1')
end

% Prepare custom regressor evaluation
% For non vectorized custom regressor only, mxind contains
% the indices in mxdata corresponding to custom regressor
% function arguments.

% mxind = cell(ny,1);
xcell = cell(ny,1);
custregflagvec = false(ny,1);
for ky=1:ny
    if ~isempty(custreg{ky}) && isa(custreg{ky},'customreg')
        custregflagvec(ky) = true;
        ncr = numel(custreg{ky});
        xcell{ky} = cell(ncr,1);
    end
end

for ky = 1:ny
    if any(maxidelay(ky)>=nobs)  % any is due to multi-experiments data
        msg = 'Too few data samples in one or more data experiment(s).';
        msg = struct('identifier','Ident:idnlmodel:toofewSamples', 'message',msg);
        return
    end
    
    matrows = sum(nobs(:)-maxidelay(ky)); % sum is due to multi-experiments data
    yvec{ky} = zeros(matrows,1);
    regmat{ky} = zeros(matrows,nregs(ky));
    
    rowend = 0;
    for kex=1:nex
        rowstart = rowend + 1;
        rowend = rowend + nobs(kex) - maxidelay(ky);
        yvec{ky}(rowstart:rowend) = ydata{kex}(maxidelay(ky)+1:nobs(kex), ky);
        
        % Standard regressors
        colcum = 0;
        for iy=1:ny           % Delays of different outputs
            for jy=1:na(ky,iy)  % Delays of the current output
                regmat{ky}(rowstart:rowend, colcum+jy) = ydata{kex}(maxidelay(ky)-jy+1:nobs(kex)-jy,iy);
            end
            colcum = colcum+na(ky,iy);
        end
        for iu=1:nu           % Delays of different inputs
            for ju=1:nb(ky,iu)  % Delays of the current input
                regmat{ky}(rowstart:rowend, colcum+ju) = udata{kex}(maxidelay(ky)-nk(ky,iu)-ju+2:nobs(kex)-nk(ky,iu)-ju+1,iu);
            end
            colcum = colcum+nb(ky,iu);
        end
        
        % Custom regressors
        if custregflagvec(ky)
            cregs = custreg{ky};
            ncr = numel(cregs);
            mxind = cell(ncr,1);
            for kcr=1:ncr
                mxind{kcr} = sub2ind([nobs(kex), ny+nu], ...
                    maxidelay(ky)+1-cregs(kcr).Delays, ...
                    cregs(kcr).ChannelIndices);
            end
            yudatakex = [ydata{kex}, udata{kex}];
            
            % t0 = cputime;
            for kcr=1:ncr
                
                %Note: this part is added to give up vectorization only if Vectorized==false.
                %The redundancy with the following part should be removed
                %if this solution is confirmed.
                if ~cregs(kcr).Vectorized
                    try
                        % Non vectorized custom regressor
                        for kobs=maxidelay(ky)+1:nobs(kex)
                            % Get values from yudatakex corresponding to custom reg arguments,
                            % put them in a cell in order to pass as separate arguments.
                            % The cellarray of cellarrays xcell is used to avoid memory
                            % re-allocation in the loop.
                            xcell{ky}{kcr} = num2cell(yudatakex(mxind{kcr}+kobs-maxidelay(ky)-1));
                            regval = cregs(kcr).Function(xcell{ky}{kcr}{:});
                            
                            if numel(regval)==1 && isnumeric(regval) && isreal(regval)
                                regmat{ky}(rowstart-1+kobs-maxidelay(ky), colcum+kcr) = regval;
                            else
                                msg = 'Each custom regressor must return a scalar real value.';
                                msg = struct('identifier','Ident:idnlmodel:invalidCustomreg1', 'message',msg);
                                return
                            end
                        end %for kobs
                    catch E
                        msg = struct('identifier',E.identifier,'message',E.message);
                        return
                    end %try
                    
                    continue % skip the remaining of the iteration of kcr=1:ncr
                end
                
                try
                    % Try to evaluate vectorized custom regressor
                    vshift = (0:nobs(kex)-(maxidelay(ky)+1))';
                    matind = mxind{kcr}(ones(nobs(kex)-maxidelay(ky),1),:) ...
                        + vshift(:,ones(1,length(cregs(kcr).Delays)));
                    xcl = num2cell(yudatakex(matind),1);
                    regval = cregs(kcr).Function(xcl{:});
                    if numel(regval)==nobs(kex)-maxidelay(ky) && isnumeric(regval) && isreal(regval)
                        regmat{ky}(rowstart-1-maxidelay(ky)+(maxidelay(ky)+1:nobs(kex)), colcum+kcr) = regval;
                    else
                        msg = 'Custom regressor incorrectly vectorized. Type "help customreg" for more information.';
                        msg = struct('identifier','Ident:idnlmodel:invalidCustomreg2', 'message',msg);
                        return
                    end
                catch
                    try
                        % Non vectorized custom regressor
                        for kobs=maxidelay(ky)+1:nobs(kex)
                            % Get values from yudatakex corresponding to custom reg arguments,
                            % put them in a cell in order to pass as separate arguments.
                            % The cellarray of cellarrays xcell is used to avoid memory
                            % re-allocation in the loop.
                            xcell{ky}{kcr} = num2cell(yudatakex(mxind{kcr}+kobs-maxidelay(ky)-1));
                            regval = cregs(kcr).Function(xcell{ky}{kcr}{:});
                            
                            if numel(regval)==1 && isnumeric(regval) && isreal(regval)
                                regmat{ky}(rowstart-1+kobs-maxidelay(ky), colcum+kcr) = regval;
                            else
                                msg = 'Each custom regressor must return a scalar real value.';
                                msg = struct('identifier','Ident:idnlmodel:makeregmat2', 'message',msg);
                                return
                            end
                        end %for kobs
                    catch E
                        msg = struct('identifier',E.identifier,'message',E.message);
                        return
                    end %try (inner)
                end  %try (outer)
            end%for kcr=1:ncr
            %       disp(['CustomRegressors evaluation time: ', num2str(cputime-t0)])
        end %if custregflagvec(ky)
    end %for kex=1:nex
end %for ky = 1:ny

% FILE END
