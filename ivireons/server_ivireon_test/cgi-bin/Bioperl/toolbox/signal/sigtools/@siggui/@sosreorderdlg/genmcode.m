function s = genmcode(this)
%GENMCODE   Generate MATLAB code that performs the action of the dialog.

%   Author(s): J. Schickler
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2010/01/25 22:53:27 $

s = sigcodegen.mcodebuffer;

rtype = get(this, 'ReorderType');

if ~strcmpi(rtype, 'none')
    if strcmpi(rtype, 'custom')
        hc = getcomponent(this, 'custom');
        ro = getreorderinputs(hc);
        le = length(ro);
        p = {'numorder'};
        v = {['[' num2str(ro{1}) ']']};
        d = {'Numerator Order'};
        inputs = '';
        if le > 1
            p{end+1} = 'denorder';
            v{end+1} = ['[' num2str(ro{2}) ']'];
            d{end+1} = 'Denominator Order';
            inputs   = ', denorder';
            
            if le > 2
                p{end+1} = 'svorder';
                v{end+1} = ['[' num2str(ro{3}) ']'];
                d{end+1} = 'Scale Values Order';
                inputs   = sprintf('%s, svorder', inputs);
            end
        end
        s.addcr(s.formatparams(p, v, d));
        s.cr;
        s.addcr('reorder(Hd, numorder%s);', inputs);
    else
        s.addcr('reorder(Hd, ''%s'');', rtype);
    end
    s.cr;
end

if strcmpi(this.scale, 'on'),

    switch this.PNorm
        case 1, pnorm = 'l1';
        case 2, pnorm = 'Linf';
        case 3, pnorm = 'l2';
        case 4, pnorm = 'L1';
        case 5, pnorm = 'linf';
    end
    
    svc = map(this.ScaleValueConstraint);
    
    p = {'pnorm', 'maxnum', 'numcon', 'omode', 'svcon'};
    v = {['''' pnorm ''''], num2str(evaluatevars(this.MaxNumerator)), ...
        ['''' map(this.NumeratorConstraint) ''''], ...
        ['''' this.OverflowMode ''''], ['''' svc '''']};
    d = {'Pth Norm', 'Maximum Numerator', 'Numerator Constraint', ...
        'Overflow Mode', 'Scale Value Constraint'};
    
    if ~strcmpi(svc, 'unit'),
        p{end+1} = 'maxsv';
        v{end+1} = evaluatevars(this.MaxScaleValue);
        d{end+1} = 'Maximum Scale Value';
    end

    s.addcr(s.formatparams(p,v,d));
    s.cr;
    s.addcr('scale(Hd, pnorm, ...');
    s.addcr('    ''MaxNumerator'', maxnum, ...');
    s.addcr('    ''NumeratorConstraint'', numcon, ...');
    s.addcr('    ''Overflowmode'', omode, ...');
    s.addcr('    ''ScaleValueConstraint'', svcon, ...');
    
    if ~strcmpi(svc, 'unit')
        s.addcr('    ''MaxScaleValue'', maxsv, ...');
    end
    s.add('    ''SOSReorder'', ''none'');');
end

% -------------------------------------------------------------------------
function n = map(n)

if strcmpi(n, 'power of 2')
    n = 'po2';
end

% [EOF]
