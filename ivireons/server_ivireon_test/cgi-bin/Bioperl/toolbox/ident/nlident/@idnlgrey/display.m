function txt = display(nlsys, type)
%DISPLAY  Displays IDNLGREY information on the screen.
%
%   DISPLAY(NLSYS, TYPE) shows information about the IDNLGREY object
%   NLSYS on the screen. The optional argument type, which can be
%   either 0 (default) or 1, determines the amount of information
%   sent to the screen.
%
%   With TYPE = 0 (default), the information will contain various
%   structure data (number of inputs, number of outputs, etc.), the
%   the structure of the model and some basic estimation information.
%   With TYPE = 1, further information about the model as well as
%   further estimation information are additionally displayed.
%
%   TXT = DISPLAY(NLSYS, TYPE) sends the result of display to the
%   variable TXT, i.e., not to the screen.
%
%   See also IDNLGREY/PRESENT.

%   Copyright 2005-2010 The MathWorks, Inc.
%   $Revision: 1.1.10.8 $ $Date: 2010/03/22 03:49:06 $
%   Written by Peter Lindskog.

% Check that the function is called with one or two arguments.
nin = nargin;
error(nargchk(1, 2, nin, 'struct'));

% Check that NLSYS is an IDNLGREY object.
if ~isa(nlsys, 'idnlgrey')
    ctrlMsgUtils.error('Ident:general:objectTypeMismatch','display','IDNLGREY');
end

% Check that TYPE is correctly given.
if (nin < 2)
    type = 0;
elseif ~isnumeric(type)
    ctrlMsgUtils.error('Ident:idnlmodel:idnlgreyDisplayInvalidtype')
elseif isempty(type)
    type = 0;
elseif (ndims(type) ~= 2)
    ctrlMsgUtils.error('Ident:idnlmodel:idnlgreyDisplayInvalidtype')
elseif any(size(type) ~= [1 1])
    ctrlMsgUtils.error('Ident:idnlmodel:idnlgreyDisplayInvalidtype')
elseif ~((type == 0) || (type == 1))
    ctrlMsgUtils.error('Ident:idnlmodel:idnlgreyDisplayInvalidtype')
end

% Generate text to be displayed or returned.
if isempty(nlsys)
    txt1 = 'Empty IDNLGREY model.';
else
    % Check and get data from nlsys.
    error(isvalid(nlsys, 'SkipFileName'));
    
    % Build up basic data in a text string.
    FileName = nlsys.FileName;
    if isa(FileName, 'function_handle')
        txt1 = ' (function handle):\n\n';
    else
        switch exist(FileName, 'file')
            case 2
                txt1 = ' (MATLAB file):\n\n';
            case 3
                txt1 = ' (MEX-file):\n\n';
            case 6
                txt1 = ' (p-file):\n\n';
            otherwise
                txt1 = ' (unknown):\n\n';
        end
    end
    if (isempty(nlsys.FileArgument) && iscell(nlsys.FileArgument))
        argtxt = '';
    else
        argtxt = ', FileArgument';
    end
    Tv = pvget(nlsys, 'TimeVariable');
    Ts = pvget(nlsys, 'Ts');
    if isa(FileName, 'function_handle')
        FileName = ['@' func2str(FileName)];
    end
    switch size(nlsys, 'npo')
        case 0
            partxt = '';
        case 1
            partxt = ', p1';
        case 2
            partxt = ', p1, p2';
        otherwise
            partxt = sprintf(', p1, ..., p%d', size(nlsys, 'npo'));
    end
    if (nlsys.Order.nx > 0)
        if (nlsys.Order.nu > 0)
            if (Ts == 0)
                txt1 = sprintf(['Time-continuous nonlinear state-space model defined by ''' FileName '''' txt1]);
                txt1 = sprintf('%s   dx/d%s = F(%s, u(%s), x(%s)%s%s)\n', txt1, Tv, Tv, Tv, Tv, partxt, argtxt);
                txt1 = sprintf('%s    y(%s) = H(%s, u(%s), x(%s)%s%s) + e(%s)\n\n', txt1, Tv, Tv, Tv, Tv, partxt, argtxt, Tv);
            else
                txt1 = sprintf(['Time-discrete nonlinear state-space model defined by ''' FileName '''' txt1]);
                txt1 = sprintf('%s   x(%s+Ts) = F(%s, u(%s), x(%s)%s%s)\n', txt1, Tv, Tv, Tv, Tv, partxt, argtxt);
                txt1 = sprintf('%s      y(%s) = H(%s, u(%s), x(%s)%s%s) + e(%s)\n\n', txt1, Tv, Tv, Tv, Tv, partxt, argtxt, Tv);
            end
        else
            if (Ts == 0)
                txt1 = sprintf(['Time-continuous nonlinear state-space model defined by ''' FileName '''' txt1]);
                txt1 = sprintf('%s   dx/d%s = F(%s, x(%s)%s%s)\n', txt1, Tv, Tv, Tv, partxt, argtxt);
                txt1 = sprintf('%s    y(%s) = H(%s, x(%s)%s%s) + e(%s)\n\n', txt1, Tv, Tv, Tv, partxt, argtxt, Tv);
            else
                txt1 = sprintf(['Time-discrete nonlinear state-space model defined by ''' FileName '''' txt1]);
                txt1 = sprintf('%s   x(%s+Ts) = F(%s, u(%s), x(%s)%s%s)\n', txt1, Tv, Tv, Tv, Tv, partxt, argtxt);
                txt1 = sprintf('%s      y(%s) = H(%s, x(%s)%s%s) + e(%s)\n\n', txt1, Tv, Tv, Tv, partxt, argtxt, Tv);
            end
        end
    else
        if (nlsys.Order.nu > 0)
            if (Ts == 0)
                txt1 = sprintf(['Time-continuous nonlinear static model defined by ''' FileName '''' txt1]);
            else
                txt1 = sprintf(['Time-discrete nonlinear static model defined by ''' FileName '''' txt1]);
            end
            txt1 = sprintf('%s    y(%s) = H(%s, u(%s)%s%s) + e(%s)\n\n', txt1, Tv, Tv, Tv, partxt, argtxt, Tv);
        else
            if (Ts == 0)
                txt1 = sprintf(['Time-continuous nonlinear static model defined by ''' FileName '''' txt1]);
            else
                txt1 = sprintf(['Time-discrete nonlinear static model defined by ''' FileName '''' txt1]);
            end
            txt1 = sprintf('%s    y(%s) = H(%s, %s%s) + e(%s)\n\n', txt1, Tv, Tv, partxt, argtxt, Tv);
        end
    end
    if (nlsys.Order.nu > 0)
        if (nlsys.Order.nu > 1)
            pluru = 's';
        else
            pluru = '';
        end
        txt1 = sprintf('%swith %d input%s', txt1, nlsys.Order.nu, pluru);
        if (nlsys.Order.nx == 1)
            plurx = '';
        else
            plurx = 's';
        end
        txt1 = sprintf('%s, %d state%s', txt1, nlsys.Order.nx, plurx);
    else
        if (nlsys.Order.nx == 1)
            plurx = '';
        else
            plurx = 's';
        end
        txt1 = sprintf('%swith %d state%s', txt1, nlsys.Order.nx, plurx);
    end
    if (nlsys.Order.ny == 1)
        plury = '';
    else
        plury = 's';
    end
    txt1 = sprintf('%s, %d output%s', txt1, nlsys.Order.ny, plury);
    np = size(nlsys, 'np');
    npest = np - size(nlsys, 'npf');
    if (npest == 1)
        plurpe = '';
    else
        plurpe = 's';
    end
    if (np == 0)
        txt1 = sprintf('%s, and 0 parameters.', txt1);
    else
        txt1 = sprintf('%s, and %d free parameter%s (out of %d).', txt1, npest, plurpe, np);
    end
    
    % Display additional information.
    if (type == 1)
        % Display information about the input(s).
        nmax = max([nlsys.Order.nu nlsys.Order.nx nlsys.Order.ny size(nlsys, 'npo')]);
        if (nlsys.Order.nu > 0)
            txt1 = sprintf('%s\n\nInput%s:', txt1, pluru);
            InputName = pvget(nlsys, 'InputName');
            InputUnit = pvget(nlsys, 'InputUnit');
            for i = 1:nlsys.Order.nu
                if isempty(InputUnit{i})
                    txt1 = sprintf('%s\n   u(%d)%s  %s(%s)', txt1, i,                       ...
                        repmat(' ', 1, length(num2str(nmax))-length(num2str(i))), ...
                        InputName{i}, Tv);
                else
                    txt1 = sprintf('%s\n   u(%d)%s  %s(%s) [%s]', txt1, i,                  ...
                        repmat(' ', 1, length(num2str(nmax))-length(num2str(i))), ...
                        InputName{i}, Tv, InputUnit{i});
                end
            end
        else
            txt1 = sprintf('%s\n', txt1);
        end
        
        % Display information about the state(s).
        if (nlsys.Order.nx > 0)
            txthead = ['State' plurx ':'];
            ne = size(nlsys, 'ne');
            Name = {nlsys.InitialStates.Name};
            Unit = {nlsys.InitialStates.Unit};
            Value = {nlsys.InitialStates.Value};
            Minimum = {nlsys.InitialStates.Minimum};
            Maximum = {nlsys.InitialStates.Maximum};
            Fixed = {nlsys.InitialStates.Fixed};
            tmptxt1 = cell(nlsys.Order.nx, 1);      % Name and unit.
            tmptxt2 = cell(ne*nlsys.Order.nx, 1);   % Experiment.
            tmptxt3 = cell(ne*nlsys.Order.nx, 1);   % Value.
            maxlen = [0 0 0];
            for i = 1:nlsys.Order.nx
                if isempty(Unit{i})
                    tmptxt1{i} = sprintf('x(%d)%s  %s(%s)', i,                    ...
                        repmat(' ', 1, length(num2str(nmax))-length(num2str(i))), ...
                        Name{i}, Tv);
                elseif (length(Unit{i}) > 12)
                    tmptxt1{i} = sprintf('x(%d)%s  %s(%s) [%s..]', i,             ...
                        repmat(' ', 1, length(num2str(nmax))-length(num2str(i))), ...
                        Name{i}, Tv, Unit{i}(1:10));
                else
                    tmptxt1{i} = sprintf('x(%d)%s  %s(%s) [%s]', i,               ...
                        repmat(' ', 1, length(num2str(nmax))-length(num2str(i))), ...
                        Name{i}, Tv, Unit{i});
                end
                maxlen(1) = max(maxlen(1), length(tmptxt1{i}));
                for j = 1:ne
                    tmptxt2{nlsys.Order.nx*(i-1)+j} = sprintf('xinit@exp%d%s', j, ...
                        repmat(' ', 1, length(num2str(ne))-length(num2str(j))));
                    tmptxt3{nlsys.Order.nx*(i-1)+j} = sprintf('%g', Value{i}(j));
                    maxlen(2) = max(maxlen(2), length(tmptxt2{nlsys.Order.nx*(i-1)+j}));
                    maxlen(3) = max(maxlen(3), length(tmptxt3{nlsys.Order.nx*(i-1)+j}));
                end
            end
            txthead = [txthead repmat(' ', 1, maxlen(1)-length(txthead)) '      initial value'];
            txt1 = sprintf('%s\n%s', txt1, txthead);
            for i = 1:length(tmptxt1)
                for j = 1:ne
                    if (Fixed{i}(j))
                        tmptxt4 = '(fix)';
                    else
                        tmptxt4 = '(est)';
                    end
                    if (Minimum{i}(j) == eps(0))
                        LeftBrack = ']';
                        RightBrack = ']';
                        Minimum{i}(j) = 0;
                    elseif (Maximum{i}(j) == -eps(0))
                        LeftBrack = '[';
                        RightBrack = '[';
                        Maximum{i}(j) = 0;
                    else
                        LeftBrack = '[';
                        RightBrack = ']';
                    end
                    if (j == 1)
                        txt1 = sprintf('%s\n   %s%s   %s%s   %s%s   %s in %s%g, %g%s', txt1,   ...
                            tmptxt1{i}, repmat(' ', 1, maxlen(1)-length(tmptxt1{i})),          ...
                            tmptxt2{nlsys.Order.nx*(i-1)+j},                                   ...
                            repmat(' ', 1, maxlen(2)-length(tmptxt2{nlsys.Order.nx*(i-1)+j})), ...
                            repmat(' ', 1, maxlen(3)-length(tmptxt3{nlsys.Order.nx*(i-1)+j})), ...
                            tmptxt3{nlsys.Order.nx*(i-1)+j},                                   ...
                            tmptxt4, LeftBrack, Minimum{i}(j), Maximum{i}(j), RightBrack);
                    else
                        txt1 = sprintf('%s\n   %s%s   %s%s   %s%s   %s in %s%g, %g%s', txt1,   ...
                            repmat(' ', 1, length(tmptxt1{i})),                                ...
                            repmat(' ', 1, maxlen(1)-length(tmptxt1{i})),                      ...
                            tmptxt2{nlsys.Order.nx*(i-1)+j},                                   ...
                            repmat(' ', 1, maxlen(2)-length(tmptxt2{nlsys.Order.nx*(i-1)+j})), ...
                            repmat(' ', 1, maxlen(3)-length(tmptxt3{nlsys.Order.nx*(i-1)+j})), ...
                            tmptxt3{nlsys.Order.nx*(i-1)+j},                                   ...
                            tmptxt4, LeftBrack, Minimum{i}(j), Maximum{i}(j), RightBrack);
                    end
                end
            end
        end
        
        % Display information about the output(s).
        txt1 = sprintf('%s\nOutput%s:', txt1, plury);
        OutputName = pvget(nlsys, 'OutputName');
        OutputUnit = pvget(nlsys, 'OutputUnit');
        for i = 1:nlsys.Order.ny
            if isempty(OutputUnit{i})
                txt1 = sprintf('%s\n   y(%d)%s  %s(%s)', txt1, i,                       ...
                    repmat(' ', 1, length(num2str(nmax))-length(num2str(i))), ...
                    OutputName{i}, Tv);
            else
                txt1 = sprintf('%s\n   y(%d)%s  %s(%s) [%s]', txt1, i,                  ...
                    repmat(' ', 1, length(num2str(nmax))-length(num2str(i))), ...
                    OutputName{i}, Tv, OutputUnit{i});
            end
        end
        
        % Display information about the parameter(s).
        np = size(nlsys, 'np');
        if (np > 0)
            npo = size(nlsys, 'npo');
            if (np == 1)
                plurp = '';
            else
                plurp = 's';
            end
            txthead = ['Parameter' plurp ':'];
            Name = {nlsys.Parameters.Name};
            Unit = {nlsys.Parameters.Unit};
            Value = {nlsys.Parameters.Value};
            Minimum = {nlsys.Parameters.Minimum};
            Maximum = {nlsys.Parameters.Maximum};
            Fixed = {nlsys.Parameters.Fixed};
            tmptxt1 = cell(np, 1);    % Parameter list.
            tmptxt2 = cell(npo, 1);   % Name and unit.
            tmptxt3 = cell(np, 1);    % Value.
            tmptxt4 = cell(np, 1);    % Variance.
            tmptxt5 = cell(np, 1);    % Fixed, Minimum and Maximum.
            ind = 1;
            cov = nlsys.CovarianceMatrix;
            iscov = (isnumeric(cov) && all(size(cov) == np*ones(1, 2)));
            maxlen = [0 0 0 0];
            for i = 1:npo
                % Determine parameter list.
                if all(size(Value{i}) == [1 1])
                    % Scalar.
                    tmptxt1{ind} = sprintf('   p%d', i);
                    maxlen(1) = max(maxlen(1), length(tmptxt1{ind}));
                    tmptxt3{ind} = sprintf('%g', Value{i});
                    maxlen(3) = max(maxlen(3), length(tmptxt3{ind}));
                    if (iscov)
                        tmptxt4{ind} = sprintf('%g   ', sqrt(cov(ind, ind)));
                        maxlen(4) = max(maxlen(4), length(tmptxt4{ind}));
                    else
                        tmptxt4{ind} = '';
                    end
                    if (Minimum{i} == eps(0))
                        LeftBrack = ']';
                        RightBrack = ']';
                        Minimum{i} = 0;
                    elseif (Maximum{i} == -eps(0))
                        LeftBrack = '[';
                        RightBrack = '[';
                        Maximum{i} = 0;
                    else
                        LeftBrack = '[';
                        RightBrack = ']';
                    end
                    if Fixed{i}(1)
                        tmptxt5{ind} = sprintf('(fix) in %s%g, %g%s', ...
                            LeftBrack, Minimum{i}, Maximum{i}, RightBrack);
                    else
                        tmptxt5{ind} = sprintf('(est) in %s%g, %g%s', ...
                            LeftBrack, Minimum{i}, Maximum{i}, RightBrack);
                    end
                    ind = ind + 1;
                elseif (size(Value{i}, 2) == 1)
                    % Vector.
                    for j = 1:length(Value{i})
                        tmptxt1{ind} = sprintf('   p%d(%d)', i, j);
                        maxlen(1) = max(maxlen(1), length(tmptxt1{ind}));
                        tmptxt3{ind} = sprintf('%g', Value{i}(j));
                        maxlen(3) = max(maxlen(3), length(tmptxt3{ind}));
                        if (iscov)
                            tmptxt4{ind} = sprintf('%g   ', sqrt(cov(ind, ind)));
                            maxlen(4) = max(maxlen(4), length(tmptxt4{ind}));
                        else
                            tmptxt4{ind} = '';
                        end
                        if (Minimum{i}(j) == eps(0))
                            LeftBrack = ']';
                            RightBrack = ']';
                            Minimum{i}(j) = 0;
                        elseif (Maximum{i}(j) == -eps(0))
                            LeftBrack = '[';
                            RightBrack = '[';
                            Maximum{i}(j) = 0;
                        else
                            LeftBrack = '[';
                            RightBrack = ']';
                        end
                        if Fixed{i}(j)
                            tmptxt5{ind} = sprintf('(fix) in %s%g, %g%s', ...
                                LeftBrack, Minimum{i}(j), Maximum{i}(j), RightBrack);
                        else
                            tmptxt5{ind} = sprintf('(est) in %s%g, %g%s', ...
                                LeftBrack, Minimum{i}(j), Maximum{i}(j), RightBrack);
                        end
                        ind = ind + 1;
                    end
                else
                    % Matrix.
                    for j = 1:size(Value{i}, 2)
                        for k = 1:size(Value{i}, 1)
                            tmptxt1{ind} = sprintf('   p%d(%d,%d)', i, k, j);
                            maxlen(1) = max(maxlen(1), length(tmptxt1{ind}));
                            tmptxt3{ind} = sprintf('%g', Value{i}(k, j));
                            maxlen(3) = max(maxlen(3), length(tmptxt3{ind}));
                            if (iscov)
                                tmptxt4{ind} = sprintf('%g   ', sqrt(cov(ind, ind)));
                                maxlen(4) = max(maxlen(4), length(tmptxt4{ind}));
                            else
                                tmptxt4{ind} = '';
                            end
                            if (Minimum{i}(k, j) == eps(0))
                                LeftBrack = ']';
                                RightBrack = ']';
                                Minimum{i}(k, j) = 0;
                            elseif (Maximum{i}(k, j) == -eps(0))
                                LeftBrack = '[';
                                RightBrack = '[';
                                Maximum{i}(k, j) = 0;
                            else
                                LeftBrack = '[';
                                RightBrack = ']';
                            end
                            if Fixed{i}(k, j)
                                tmptxt5{ind} = sprintf('(fix) in %s%g, %g%s', ...
                                    LeftBrack, Minimum{i}(k, j), Maximum{i}(k, j), RightBrack);
                            else
                                tmptxt5{ind} = sprintf('(est) in %s%g, %g%s', ...
                                    LeftBrack, Minimum{i}(k, j), Maximum{i}(k, j), RightBrack);
                            end
                            ind = ind + 1;
                        end
                    end
                end
                
                % Determine parameter name and unit.
                if isempty(Unit{i})
                    tmptxt2{i} = sprintf('%s', Name{i});
                elseif (length(Unit{i}) > 12)
                    tmptxt2{i} = sprintf('%s [%s..]', Name{i}, Unit{i}(1:10));
                else
                    tmptxt2{i} = sprintf('%s [%s]', Name{i}, Unit{i});
                end
                maxlen(2) = max(maxlen(2), length(tmptxt2{i}));
            end
            if (iscov)
                txt1 = sprintf('%s\n%s%s      value%sstandard dev', txt1, txthead,  ...
                    repmat(' ', 1, maxlen(1)+maxlen(2)-length(txthead)),            ...
                    repmat(' ', 1, maxlen(3)-2));
            else
                txt1 = sprintf('%s\n%s%s      value', txt1, txthead,  ...
                    repmat(' ', 1, maxlen(1)+maxlen(2)-length(txthead)));
            end
            ind = 1;
            for i = 1:npo
                txt1 = sprintf('%s\n%s%s   %s%s   %s%s   %s%s%s',                       ...
                    txt1, tmptxt1{ind}, repmat(' ', 1, maxlen(1)-length(tmptxt1{ind})), ...
                    tmptxt2{i}, repmat(' ', 1, maxlen(2)-length(tmptxt2{i})),           ...
                    repmat(' ', 1, maxlen(3)-length(tmptxt3{ind})), tmptxt3{ind},       ...
                    repmat(' ', 1, maxlen(4)-length(tmptxt4{ind})), tmptxt4{ind},       ...
                    tmptxt5{ind});
                ind = ind + 1;
                for j = 2:length(Value{i}(:))
                    txt1 = sprintf('%s\n%s%s   %s   %s%s   %s%s%s',                                ...
                        txt1, tmptxt1{ind}, repmat(' ', 1, maxlen(1)-length(tmptxt1{ind})),        ...
                        repmat(' ', 1, maxlen(2)), repmat(' ', 1, maxlen(3)-length(tmptxt3{ind})), ...
                        tmptxt3{ind}, repmat(' ', 1, maxlen(4)-length(tmptxt4{ind})),              ...
                        tmptxt4{ind}, tmptxt5{ind});
                    ind = ind + 1;
                end
            end
        end
    end
    
    % Display EstimationInfo data.
    EstimationInfo = pvget(nlsys, 'EstimationInfo');
    if (   isValidStr(EstimationInfo.DataName) && isIntScalar(EstimationInfo.DataLength, 0, Inf, true) ...
            && isRealScalar(EstimationInfo.LossFcn, 0, Inf, true) && isRealScalar(EstimationInfo.FPE, 0, Inf, true))
        switch EstimationInfo.Status(1)
            case 'E'
                if isempty(EstimationInfo.DataName)
                    txt1 = sprintf(['%s\n\nThe model was estimated from a data set with %d samples.\n' ...
                        'Loss function %g and Akaike''s FPE %g'], txt1,                    ...
                        EstimationInfo.DataLength, EstimationInfo.LossFcn,                 ...
                        EstimationInfo.FPE);
                else
                    txt1 = sprintf(['%s\n\nThe model was estimated from the data set ''%s'', which\n'    ...
                        'contains %d data samples.\nLoss function %g and Akaike''s FPE %g'], ...
                        txt1, EstimationInfo.DataName, EstimationInfo.DataLength,            ...
                        EstimationInfo.LossFcn, EstimationInfo.FPE);
                end
            case 'M'
                txt1 = sprintf('%s\n\nThe model was originally estimated and then modified.', txt1);
            case 'N'
                txt1 = sprintf('%s\n\nThe model was not estimated from data.', txt1);
        end
    end
    
    % Display additional information.
    if (type == 1)
        % Add sampling interval information.
        Ts = EstimationInfo.DataTs;
        if isRealScalar(Ts, 0, Inf, true)
            txt1 = sprintf('%s\n\nSampling rate: %g [%s]', txt1, Ts{1}, pvget(nlsys, 'TimeUnit'));
        else
            txt1 = sprintf('%s\n', txt1);
        end
        
        % Add time information.
        txt1 = str2mat(txt1, timestamp(nlsys));
    end
end

% Return the result to the screen or to a variable.
if (nargout > 0)
    txt = txt1;
else
    disp(txt1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Local functions.                                                               %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function result = isValidStr(value)
% Return outvalue as a unique match of choices.
result = true;
if (ndims(value) ~= 2)
    result = false;
elseif ~ischar(value)
    result = false;
end

function result = isIntScalar(value, low, high, islimited)
% Check that value is an integer in the specified range.
result = true;
if (ndims(value) ~= 2)
    result = false;
elseif ~isnumeric(value)
    result = false;
elseif ~all(size(value) == [1 1])
    result = false;
elseif (~isreal(value) || isnan(value))
    result = false;
elseif (isfinite(value) && (rem(value, 1) ~= 0))
    result = false;
elseif (islimited && ~isfinite(value))
    result = false;
elseif (value < low)
    result = false;
elseif (value > high)
    result = false;
end

function result = isRealScalar(value, low, high, islimited)
% Check that value is a real scalar in the specified range.
result = true;
if (ndims(value) ~= 2)
    result = false;
elseif ~isnumeric(value)
    result = false;
elseif ~all(size(value) == [1 1])
    result = false;
elseif (~isreal(value) || isnan(value))
    result = false;
elseif (islimited && ~isfinite(value))
    result = false;
elseif (value < low)
    result = false;
elseif (value > high)
    result = false;
end