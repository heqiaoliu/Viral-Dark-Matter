function [e, x0] = utpe(varargin)
%UTPE  Utility code used by idmodel and idnlmodel PE methods.

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.9 $ $Date: 2008/10/02 18:52:13 $
%   Written by Peter Lindskog.

% First allow the property/value pair 'initialstate'/ini to conform with
% other routines.
nr = find(strncmpi(varargin, 'in', 2));
x0init = [];
if ~isempty(nr)
    if (length(varargin) < nr+1)
        ctrlMsgUtils.error('Ident:analysis:peInvalidIni1')
    end
    x0init = varargin{nr+1};
    if (~ischar(x0init) && ~isfloat(x0init))
        ctrlMsgUtils.error('Ident:analysis:peInvalidIni1')
    end
    varargin(nr) = [];
end

% Retrieve the number of inputs and outputs.
nin = length(varargin);
nout = nargout;

% Check that the function is called with 2 to 3 input arguments.
error(nargchk(2, 3, nin, 'struct'));
sys = varargin{1};
data = varargin{2};
if (nin == 3)
    %if ~isempty(x0init)
    %   erro('Ident:pe:TooManyInputs', 'Too many input arguments.');
    %else
    x0init = varargin{3};
    %end
end

% Allow SYS and DATA arguments to be swapped.
if (isa(sys, 'iddata') || isa(sys,'cell') || isnumeric(sys))
    datatmp = sys;
    sys = data;
    data = datatmp;
end

if isnan(sys)
    ctrlMsgUtils.error('Ident:analysis:peIllDefinedModel')
end

% Check that DATA is an IDDATA object or a matrix of appropriate size.
if isa(data, 'iddata')
    retmat = false;
    if strcmpi(pvget(data, 'Domain'), 'frequency')
        sys = pvset(sys, 'CovarianceMatrix', []);
        if ~isa(sys, 'idproc') % This is to not destroy sampling.
            sys = idss(sys);
        end
        [e, x0] = pe_f(sys, data, x0init);
        if (nout == 0)
            % Plot e.
            utidplot(sys, e, 'Prediction error for');
            clear e x0;
        end
        return;
    end
else
    retmat = true;
    if ~isa(data, 'cell')
        data = {data};
    end
end

% Handle linear OE case.
if (isa(sys, 'idmodel') && strcmp(x0init, 'oe'))
    sys.cov = [];
    sys = idss(sys);
    sys = pvset(sys, 'DisturbanceModel', 'None');
    x0init = 'e';
end

% Call predict.
if (nin < 3)
    [yp, x0] = predict(sys, data, 1);
else
    [yp, x0] = predict(sys, data, 1, x0init);
end

% Compute the prediction errors.
if isa(data, 'iddata')
    ne = size(data, 'ne');
    prederr = cell(1, ne);
    if (ne == 1)
        prederr{1} = data.y-yp.y;
    else
        for i = 1:ne
            prederr{i} = data.y{i}-yp.y{i};
        end
    end

    % Construct the prediction error iddata object.
    e = data;
    e = pvset(e, 'OutputData', prederr, 'InputData', []);
else
    e = cell(size(data));
    ny = size(sys, 'ny');

    %Added by QZ
    if ~iscell(yp)
        yp = {yp};
    end

    for kexp = 1:length(data)
        e{kexp} = data{kexp}(:, 1:ny) - yp{kexp};
    end
end

% Plot or return prediction errors.
if (nout == 0)
    % Plot e.
    utidplot(sys, e, 'Prediction error for');
    clear e x0;
else
    if (retmat)
        % Here we could vectorize the cell array.
        e = cat(1, e{:});
    else
        % Determine the names of the prediction error channels.
        eoutname = pvget(data, 'OutputName');
        nameprefix = noiprefi('e');
        for i = 1:size(sys, 'ny')
            eoutname{i} = [nameprefix eoutname{i}];
        end
        e = pvset(e, 'OutputName', eoutname);
    end
end