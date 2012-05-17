function out = getnset(hObj, fcn, varargin)
%GETNSET Get and set functions for the pzeditor

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.9 $  $Date: 2009/07/14 04:03:37 $

out = feval(fcn, hObj, varargin{:}); 

% -----------------------------------------------------------
function poles = getpoles(hObj)

pnzs = get(hObj, 'Roots');
if isempty(pnzs),
    poles = [];
else
    poles = find(pnzs, '-isa', 'sigaxes.pole');
    if isempty(poles),
        
        % Make sure we return an empty double not an empty handle vector.
        poles = [];
    else
        poles = double(poles, 'conj');
    end
end

% -----------------------------------------------------------
function gain = getgain(hObj)

csec = get(hObj, 'CurrentSection');
allroots = get(hObj, 'AllRoots');

if isempty(allroots) || csec == 0, gain = 1;
else                              gain = allroots(csec).gain; end

% -----------------------------------------------------------
function gain = setgain(hObj, gain)

csec = get(hObj, 'CurrentSection');
allroots = get(hObj, 'AllRoots');

allroots(csec).gain = gain;

set(hObj, 'AllRoots', allroots);

% -----------------------------------------------------------
function zeros = getzeros(hObj)

pnzs = get(hObj, 'Roots');
if isempty(pnzs),
    zeros = [];
else
    zeros = find(pnzs, '-isa', 'sigaxes.zero');
    if isempty(zeros),
        
        % Make sure we return an empty double not an empty handle vector.
        zeros = [];
    else
        zeros = double(zeros, 'conj');
    end
end

% -----------------------------------------------------------
function zeros = setzeros(hObj, zeros)

pnzs = get(hObj, 'Roots');

% Make we don't write over any poles.
if ~isempty(pnzs), pnzs = find(pnzs, '-isa', 'sigaxes.pole'); end

set(hObj, 'Roots', union(pnzs, construct(zeros, 'zero')));

zeros = [];

% -----------------------------------------------------------
function poles = setpoles(hObj, poles)

pnzs = get(hObj, 'Roots');

% Make sure we don't write over any zeros.
if ~isempty(pnzs), pnzs = find(pnzs, '-isa', 'sigaxes.zero'); end

set(hObj, 'Roots', union(pnzs, construct(poles, 'pole')));

poles = [];

% -----------------------------------------------------------
function out = setfilter(this, out)

% [b, a]    = tf(Hd);
if isempty(out),
    set(this, 'Poles', []);
    set(this, 'Zeros', []);
else
    try
        this.AllRoots = constructRoots(out);
        this.ErrorStatus = '';
    catch me
        this.ErrorStatus = sprintf('Could not calculate poles and zeroes:\n%s', ...
            cleanerrormsg(me.message));
    end
    out = copy(out);
end

set(this, 'privFilter', out);

out = [];

% --------------------------------------------------------
function out = getfilter(hObj, out)

% Build a filter out of the existing poles and zeros

% Reuse the filter object to save time.
out = get(hObj, 'privFilter');
if isa(out, 'dfilt.abstractsos'),
    msroots = get(hObj, 'AllRoots');

    % Get all the poles and zeros
    z = find([msroots.roots], '-isa', 'sigaxes.zero');
    p = find([msroots.roots], '-isa', 'sigaxes.pole');
    if isempty(z), z = [];
    else          z = double(z, 'conj'); end
    if isempty(p), p = [];
    else          p = double(p, 'conj'); end
    
    try
        [sos, g] = zp2sos(z, p);
        all_g = [msroots.gain];
        all_g(1) = all_g(1)*g;
        set(out, 'sosMatrix', sos, 'ScaleValues', all_g);
    catch
               
        c = class(out);
        c = c(1:end-3);
        
        z = find(msroots(1).roots, '-isa', 'sigaxes.zero');
        p = find(msroots(1).roots, '-isa', 'sigaxes.pole');
        
        if isempty(z), z = [];
        else          z = double(z, 'conj'); end
        if isempty(p), p = [];
        else          p = double(p, 'conj'); end
        
        Hd = feval(c, prod([msroots.gain])*poly(z), poly(p));
        
        out = dfilt.cascade(Hd);
        
        for indx = 2:length(msroots)
            z = find(msroots(indx).roots, '-isa', 'sigaxes.zero');
            p = find(msroots(indx).roots, '-isa', 'sigaxes.pole');
            if isempty(z), z = [];
            else          z = double(z, 'conj'); end
            if isempty(p), p = [];
            else          p = double(p, 'conj'); end
            addstage(out, feval(c, prod([msroots.gain])*poly(z), poly(p)));
        end
    end
elseif isa(out, 'dfilt.multistage'),
    allroots = get(hObj, 'AllRoots');
    for indx = 1:length(allroots)
        if isempty(allroots(indx).roots),
            num = 1;
            den = 1;
        else
            [num, den] = tf(allroots(indx).roots);
        end
        num = num*allroots(indx).gain;
        out.Stage(indx) = lclbuildfilter(out.Stage(indx), num, den);
    end
else
    num = poly(get(hObj, 'Zeros'))*get(hObj, 'Gain');
    den = poly(get(hObj, 'Poles'));
    
    out = lclbuildfilter(out, num, den);
end

set(hObj, 'privFilter', out);

% --------------------------------------------------------
function out = lclbuildfilter(out, num, den)

if isempty(out),
    out = dfilt.df2t(num, den);
elseif signalpolyutils('isfir', num, den),
    if isa(out, 'dfilt.dtffir'),
        set(out, 'Numerator', num);
    elseif isa(out, 'dfilt.dtfiir'),
        set(out, 'Numerator', num, 'Denominator', 1);
    end
else
    if isa(out, 'dfilt.dtffir'),
        out = dfilt.df2t(num, den);
    elseif isa(out, 'dfilt.dtfiir'),
        set(out, 'Numerator', num, 'Denominator', den);
    end
end

% --------------------------------------------------------
function roots = setallroots(hObj, roots)

if isempty(roots),
    roots.gain = 1;
    roots.roots = [];
end

if strcmpi(hObj.AnnounceNewSpecs, 'On'),
    send(hObj, 'NewFilter', handle.EventData(hObj, 'NewFilter'));
end

if length(roots) < hObj.CurrentSection,
    hObj.CurrentSection = length(roots);
end

% Make sure that we delete the old listener.  overwriting it doesn't seem
% to work.
oldl = get(hObj, 'PZValueListener');

hL = handle.listener([roots.roots], 'NewValue', @pzvalue_listener);

set(hL, 'CallbackTarget', hObj);
set(hObj, 'PZValueListener', hL);

if isa(oldl, 'handle.listener'),
    delete(oldl);
end

% --------------------------------------------------------
function roots = getroots(hObj)

csec = get(hObj, 'CurrentSection');
allroots = get(hObj, 'AllRoots');
if csec == 0 || isempty(allroots),
    roots = [];
else
    roots = allroots(csec).roots;
end

% --------------------------------------------------------
function roots = setroots(hObj, roots)

csec = get(hObj, 'CurrentSection');
allroots = get(hObj, 'AllRoots');
if csec ~= 0,
    allroots(csec).roots = roots;
    if ~isfield(allroots(csec), 'gain'), allroots(csec).gain = 1; end
end
set(hObj, 'AllRoots', allroots);

send(hObj, 'NewFilter', handle.EventData(hObj, 'NewFilter'));

% --------------------------------------------------------
function cmode = setconjugatemode(hObj, cmode)

hC = get(hObj, 'CurrentRoots');

if ~isempty(hC),
    
    if strcmpi(cmode, 'on'),
        roots = get(hObj, 'Roots');
        h2    = createconjugate(hC, roots);
        set(hObj, 'Roots', setdiff(roots, h2));
    else
        roots = get(hObj, 'Roots');
        h2    = splitconjugate(hC);
        set(hObj, 'Roots', union(roots, h2));
    end
end

if isrendered(hObj),
    updatelimits(hObj);
end

% --------------------------------------------------------
function sec = setcurrentsection(hObj, sec)

msroots = hObj.AllRoots;

if isempty(msroots), return; end

if sec < 1,
    error(generatemsgid('InvalidSection'), ...
        'The current section must be greater than 0.');
elseif sec > length(msroots),
    error(generatemsgid('InvalidSection'), ...
        'The current section cannot be greater than the number of sections.');
end

% hObj.Roots = union(msroots(sec).pole, msroots(sec).zero);
% hObj.Gain  = msroots(sec).gain;

% --------------------------------------------------------
%   Helper functions
% --------------------------------------------------------

% --------------------------------------------------------
function roots = constructRoots(out)

if isa(out, 'dfilt.abstractsos'),
    k1 = out.ScaleValues;
    s = get(out, 'sosMatrix');
    for indx = 1:size(s, 1)
        [z, p, k] = sos2zp(s(indx,:));
        if length(k1) >= indx, k = k*k1(indx); end
        
        roots(indx).gain = k;
        roots(indx).roots = [construct(z, 'zero') construct(p, 'pole')];
    end
    
elseif isa(out, 'dfilt.multistage'),
    for indx = 1:length(out.Stage)
        
        [z, p, k] = zpk(out.Stage(indx));
        roots(indx).gain = k;
        roots(indx).roots = [construct(z, 'zero') construct(p, 'pole')];
    end
else
    [z, p, k] = zpk(out);
    roots.roots = [construct(z, 'zero') construct(p, 'pole')];
    roots.gain = k;
end

% --------------------------------------------------------
function h = construct(pz, type)

h = [];
while ~isempty(pz),
    pzI = pz(1);
    hI = feval(['sigaxes.' type], pzI);
    
    h = union(h, hI);
    
    pz(1) = [];
    
    % Look for matching roots.  these are the conjugates.
    if ~isempty(pz),
        indx = find(abs(pz - conj(pzI)) < sqrt(eps));
        if ~isempty(indx),
            hI = createconjugate(hI);
            pz(indx(1)) = [];
        end
    end
end

% [EOF]
