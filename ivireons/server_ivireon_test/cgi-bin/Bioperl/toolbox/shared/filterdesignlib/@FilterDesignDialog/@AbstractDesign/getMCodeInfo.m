function mCodeInfo = getMCodeInfo(this)
%GETMCODEINFO Get the mCodeInfo.
%   OUT = GETMCODEINFO(ARGS) <long description>

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/02/13 15:13:18 $

laState = get(this, 'LastAppliedState');
specs   = getSpecs(this, laState);

% Convert the specification to a cell of specs
spec = getSpecification(this, laState);
specCell = textscan(spec, '%s', 'delimiter', ',');
specCell = specCell{1};

% Convert the cell of specs to variable names and vals.
vars  = cell(size(specCell));
vals  = vars;
descs = vars;
for indx = 1:length(specCell)
    descs{indx} = '';
    switch lower(specCell{indx})
        case 'q'
            vars{indx} = 'Q';
            vals{indx} = num2str(specs.Q);
        case 'qa'
            vars{indx} = 'Qa';
            vals{indx} = num2str(specs.Qa);
            descs{indx} = 'Quality factor (audio)';
        case 's'
            vars{indx} = 'S';
            vals{indx} = num2str(specs.S); 
            descs{indx} = 'Shelf slope parameter';
        case 'tw'
            vars{indx} = 'TW';
            vals{indx} = num2str(specs.TransitionWidth);
        case 'n'
            vars{indx} = 'N';
            vals{indx} = num2str(specs.Order);
        case 'fp'
            vars{indx} = 'Fpass';
            vals{indx} = num2str(specs.Fpass);
        case 'fp1'
            vars{indx} = 'Fpass1';
            vals{indx} = num2str(specs.Fpass1);
        case 'fp2'
            vars{indx} = 'Fpass2';
            vals{indx} = num2str(specs.Fpass2);
        case 'fst'
            vars{indx} = 'Fstop';
            vals{indx} = num2str(specs.Fstop);
        case 'fst1'
            vars{indx} = 'Fstop1';
            vals{indx} = num2str(specs.Fstop1);
        case 'fst2'
            vars{indx} = 'Fstop2';
            vals{indx} = num2str(specs.Fstop2);
        case 'f3db'
            vars{indx} = 'F3dB';
            vals{indx} = num2str(specs.F3dB);
        case 'f3db1'
            vars{indx} = 'F3dB1';
            vals{indx} = num2str(specs.F3dB1);
        case 'f3db2'
            vars{indx} = 'F3dB2';
            vals{indx} = num2str(specs.F3dB2);
        case 'fc'     
            if isfield(specs, 'Fc')
                vars{indx} = 'Fc';
                vals{indx} = num2str(specs.Fc);     
                descs{indx} = 'Cutoff frequency';
            else
                vars{indx} = 'F6dB';
                vals{indx} = num2str(specs.F6dB);
            end
        case 'fc1'
            vars{indx} = 'F6dB1';
            vals{indx} = num2str(specs.F6dB1);
        case 'fc2'
            vars{indx} = 'F6dB2';
            vals{indx} = num2str(specs.F6dB2);
        case 'ap'
            vars{indx} = 'Apass';
            vals{indx} = num2str(specs.Apass);
        case 'ap1'
            vars{indx} = 'Apass1';
            vals{indx} = num2str(specs.Apass1);
        case 'ap2'
            vars{indx} = 'Apass2';
            vals{indx} = num2str(specs.Apass2);
        case 'ast'
            vars{indx} = 'Astop';
            vals{indx} = num2str(specs.Astop);
        case 'ast1'
            vars{indx} = 'Astop1';
            vals{indx} = num2str(specs.Astop1);
        case 'ast2'
            vars{indx} = 'Astop2';
            vals{indx} = num2str(specs.Astop2);
        case 'f0'
            vars{indx} = 'F0';
            if isfield(specs, 'F0')
                vals{indx} = num2str(specs.F0);
            else
                vals{indx} = num2str(specs.CenterFreq);
            end
            descs{indx} = 'Center frequency';
        case 'bw'
            vars{indx} = 'BW';
            vals{indx} = num2str(specs.BW);
            descs{indx} = 'Bandwidth';
        case 'bwp'
            vars{indx} = 'BWpass';
            vals{indx} = num2str(specs.BWpass);
            descs{indx} = 'Passband width';
        case 'bwst'
            vars{indx} = 'BWstop';
            vals{indx} = num2str(specs.BWstop);
            descs{indx} = 'Stopband width';
        case 'gref'
            vars{indx} = 'Gref';
            vals{indx} = num2str(specs.Gref);
            descs{indx} = 'Reference gain';
        case 'g0'
            vars{indx} = 'G0';
            vals{indx} = num2str(specs.G0);
            descs{indx} = 'Center frequency gain';
        case 'gbw'
            vars{indx} = 'GBW';
            vals{indx} = num2str(specs.GBW);
            descs{indx} = 'Bandwidth gain';
        case 'gp'
            vars{indx} = 'Gpass';
            vals{indx} = num2str(specs.Gpass);
            descs{indx} = 'Passband gain';
        case 'gst'
            vars{indx} = 'Gstop';
            vals{indx} = num2str(specs.Gstop);
            descs{indx} = 'Stopband gain';
        case 'flow'
            vars{indx} = 'Flow';
            vals{indx} = num2str(specs.Flow);
            descs{indx} = 'Low frequency';
        case 'fhigh'
            vars{indx} = 'Fhigh';
            vals{indx} = num2str(specs.Fhigh);
            descs{indx} = 'High frequency';
        case 'beta'
            vars{indx} = 'Beta';
            vals{indx} = num2str(specs.Beta);
            descs{indx} = 'Rolloff factor';
        case 'bt'
            vars{indx} = 'BT';
            vals{indx} = num2str(specs.BT);
            descs{indx} = 'Bandwidth-symbol time product';
        case 'nsym'
            vars{indx} = 'Nsym';
            vals{indx} = num2str(specs.NumberOfSymbols);
            descs{indx} = 'Number of symbols';
        otherwise
            error(generatemsgid('InternalError'),'getMCodeInfo missing %s', specCell{indx});
    end
end

mCodeInfo.Variables    = vars;
mCodeInfo.Values       = vals;
mCodeInfo.Descriptions = descs;

% [EOF]
