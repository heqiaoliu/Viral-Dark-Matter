function select(hObj, str)
%SELECT Select the specified poles and zeros
%   SELECT(hObj, STR) Select the poles and zeros specified by STR.  STR can
%   be 'none', 'all', 'allpoles', 'allzeros', 'insideunitcircle', 'left',
%   'lowerhalf', 'onunitcircle', 'outsideunitcircle', 'right', 'upperhalf'.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2007/12/14 15:19:12 $

error(nargchk(2,2,nargin,'struct'));

opts = {'all', 'none', 'allpoles', 'allzeros', 'insideunitcircle', 'left', ...
        'lowerhalf', 'onunitcircle', 'outsideunitcircle', 'right', 'upperhalf'};

indx = strmatch(str, opts);

switch length(indx)
    case 0
        error(generatemsgid('invalidSelection'), '''%s'' is not a valid selection.', str);
    case 1
    otherwise
        
        % 'all' triggers this case.
        indx = strcmpi(str, opts);
        
        if isempty(indx),
            error(generatemsgid('notSpecific'), '''%s'' is not a unique selection.', str);
        end
end

allroots = hObj.Roots;

if isempty(allroots),
    croots = allroots;
else
    croots = feval([opts{indx} '_fcn'], allroots);
end

hObj.CurrentRoots = croots;

% -------------------------------------------------------------------------
function out = none_fcn(out)

out = [];

% -------------------------------------------------------------------------
function out = all_fcn(out)

% NO OP

% -------------------------------------------------------------------------
function out = allpoles_fcn(out)

out = find(out, '-isa', 'sigaxes.pole');

% -------------------------------------------------------------------------
function out = allzeros_fcn(out)

out = find(out, '-isa', 'sigaxes.zero');

% -------------------------------------------------------------------------
function out = insideunitcircle_fcn(out)

out = out(find(abs(double(out)) < 1));

% -------------------------------------------------------------------------
function out = left_fcn(out)

out = out(find(real(double(out)) < 0));

% -------------------------------------------------------------------------
function out = lowerhalf_fcn(out)

c = find(out, 'conjugate', 'on');
n = find(out, 'conjugate', 'off');

c = c(find(abs(imag(double(c))) > 0));

if isempty(n)
    out = c;
else
    out = [c; n(find(imag(double(n)) < 0))];
end

% -------------------------------------------------------------------------
function out = onunitcircle_fcn(out)

out = out(find(abs(double(out)) == 1));

% -------------------------------------------------------------------------
function out = outsideunitcircle_fcn(out)

out = out(find(abs(double(out)) > 1));

% -------------------------------------------------------------------------
function out = right_fcn(out)

out = out(find(real(double(out)) > 0));

% -------------------------------------------------------------------------
function out = upperhalf_fcn(out)

c = find(out, 'conjugate', 'on');
n = find(out, 'conjugate', 'off');

c = c(find(abs(imag(double(c))) > 0));

if isempty(n)
    out = c;
else
    out = [c; n(find(imag(double(n)) > 0))];
end

% [EOF]
