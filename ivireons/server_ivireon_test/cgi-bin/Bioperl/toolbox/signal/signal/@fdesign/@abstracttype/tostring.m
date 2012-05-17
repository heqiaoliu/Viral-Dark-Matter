function str = tostring(this)
%TOSTRING

%   Author(s): R. Losada
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2008/10/02 19:04:50 $

s = get(this);
s = reorderstructure(s, 'Response', 'Specification', 'Description');

% Remove Description field
s = rmfield(s, 'Description');

% Remove sampling frecuencies and normalized
s = rmfield(s, 'Fs');
if isfield(s,'Fs_in'), s = rmfield(s, 'Fs_in'); end
if isfield(s,'Fs_out'), s = rmfield(s, 'Fs_out'); end

s = rmfield(s,'NormalizedFrequency');

f = fieldnames(s);

param = cell(length(f)+1, 1);
value = param;

param{1} = 'Sampling Frequency';
if this.NormalizedFrequency
    value{1} = 'N/A (normalized frequency)';
    fpost    = '';
    m        = 1;
else
    
    [fs m prefix] = engunits(this.Fs);
    
    fpost    = sprintf(' %sHz', prefix);
    value{1} = [num2str(fs) fpost];
end

for indx = 1:length(f)
    
    if isnumeric(s.(f{indx})),
        num = str2num(f{indx}(end));
        if isempty(num),
            d = '';
        else
            switch num
                case 1
                    d = 'First ';
                case 2
                    d = 'Second ';
                case 3
                    d = 'Third ';
                case 4
                    d = 'Fourth ';
            end
        end
        
        switch lower(f{indx})
            case {'transitionwidth', 'transitionwidth1', 'transitionwidth2'};
                d    = [d 'Transition Width'];
                post = fpost;
            case {'apass', 'apass1', 'apass2'}
                d = [d 'Passband Ripple'];
            case {'astop', 'astop1', 'astop2'}
                d = [d 'Stopband Atten.'];
            case {'fpass', 'fpass1', 'fpass2'}
                d = [d 'Passband Edge'];
            case {'fstop', 'fstop1', 'fstop2'}
                d = [d 'Stopband Edge'];
            case {'f3db', 'f6db', 'f3db1', 'f6db1', 'f3db2', 'f6db2'}
                d = [d f{indx}(2) '-dB Point'];
            otherwise
                d = f{indx};
        end
        
        if any(strcmpi(f{indx},{'Amplitudes','FreqResponse','FilterOrder',...
                'NumOrder','DenOrder','NumberOfSections','DifferentialDelay',...
                'DecimationFactor','InterpolationFactor','q','BandsPerOctave'})),
            post = '';
            value{indx+1} = num2str(this.(f{indx}));
        elseif strncmpi(f{indx}, 'a', 1) || strncmpi(f{indx}, 'g', 1)
            post = ' dB';
            value{indx+1} = num2str(this.(f{indx}));
        elseif any(strfind(lower(f{indx}), 'delay'))
            delay = this.(f{indx});
            post    = sprintf(' samples');
            value{indx+1} = num2str(delay);
            
            if ~this.NormalizedFrequency,
                [t m prefix] = engunits(delay,'time');
                post = sprintf(' %s', prefix);
            end
            value{indx+1} = num2str(delay*m);
        else
            if this.NormalizedFrequency
                value{indx+1} = num2str(this.(f{indx}));
                post    = '';
            else
                [val mval valprefix] = engunits(this.(f{indx}));
                post    = sprintf(' %sHz', valprefix);
                value{indx+1} = num2str(val);
            end
        end
        
        value{indx+1} = sprintf('%s%s', value{indx+1}, post);
        
        param{indx+1} = d;
    else
        param{indx+1} = f{indx};
        value{indx+1} = s.(f{indx});
    end
end

str = [strvcat(param) repmat(' : ', length(param), 1) strvcat(value)];


% [EOF]

