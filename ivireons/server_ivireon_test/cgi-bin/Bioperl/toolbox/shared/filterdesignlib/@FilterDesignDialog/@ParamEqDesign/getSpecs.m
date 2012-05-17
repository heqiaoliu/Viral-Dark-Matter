function specs = getSpecs(this, varargin)
%GETSPECS Get the specs.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/02/13 15:13:24 $

if nargin > 1 && ~isempty(varargin{1})
    source = varargin{1};
else
    source = this;
end

specs.Scale      = strcmpi(this.Scale, 'on');
specs.ForceLeadingNumerator = strcmpi(this.ForceLeadingNumerator, 'on');

specs.FrequencyUnits  = source.FrequencyUnits;
specs.InputSampleRate = getnum(source, 'InputSampleRate');

specs.Gref = evaluatevars(source.Gref);
specs.G0   = evaluatevars(source.G0);
specs.GBW  = evaluatevars(source.GBW);

spec = getSpecification(this, source);

switch lower(spec)
    case 'f0,bw,bwp,gref,g0,gbw,gp'
        specs.F0     = getnum(source, 'F0');
        specs.BW     = getnum(source, 'BW');
        specs.BWpass = getnum(source, 'BWpass');
        specs.Gpass  = evaluatevars(source.Gpass);
    case 'f0,bw,bwst,gref,g0,gbw,gst'
        specs.F0     = getnum(source, 'F0');
        specs.BW     = getnum(source, 'BW');
        specs.BWstop = getnum(source, 'BWstop');
        specs.Gstop  = evaluatevars(source.Gstop);
    case 'f0,bw,bwp,gref,g0,gbw,gp,gst'
        specs.F0     = getnum(source, 'F0');
        specs.BW     = getnum(source, 'BW');
        specs.BWpass = getnum(source, 'BWpass');
        specs.Gpass  = evaluatevars(source.Gpass);
        specs.Gstop  = evaluatevars(source.Gstop);
    case 'n,f0,bw,gref,g0,gbw'
        specs.Order = evaluatevars(source.Order);
        specs.F0     = getnum(source, 'F0');
        specs.BW     = getnum(source, 'BW');
    case 'n,f0,bw,gref,g0,gbw,gp'
        specs.Order = evaluatevars(source.Order);
        specs.F0     = getnum(source, 'F0');
        specs.BW     = getnum(source, 'BW');
        specs.Gpass  = evaluatevars(source.Gpass);
    case 'n,f0,bw,gref,g0,gbw,gst'
        specs.Order = evaluatevars(source.Order);
        specs.F0     = getnum(source, 'F0');
        specs.BW     = getnum(source, 'BW');
        specs.Gpass  = evaluatevars(source.Gpass);
        specs.Gstop  = evaluatevars(source.Gstop);
    case 'n,f0,bw,gref,g0,gbw,gp,gst'
        specs.Order = evaluatevars(source.Order);
        specs.F0     = getnum(source, 'F0');
        specs.BW     = getnum(source, 'BW');
        specs.Gpass  = evaluatevars(source.Gpass);
        specs.Gstop  = evaluatevars(source.Gstop);
    case 'n,f0,qa,gref,g0'
        specs.Order = evaluatevars(source.Order);        
        specs.F0    =  getnum(source, 'F0'); 
        specs.Qa    = evaluatevars(source.Qa); 
    case 'n,f0,fc,qa,g0'
        %Fo value is specified according to the desired shelving response
        %set by the user in the gui
        if strcmpi(source.ShelfType,'lowpass')
            specs.F0  = 0;
        else
            specs.F0 = specs.InputSampleRate/2;
        end
        specs.Order = evaluatevars(source.Order);        
        specs.Fc    = getnum(source, 'Fc');        
        specs.Qa    = evaluatevars(source.Qa); 
        %G0 is specified via a boost/cut gain parameter Gbc in the gui
        specs.G0    = evaluatevars(source.Gbc);        
    case 'n,f0,fc,s,g0'
        %Fo value is specified according to the desired shelving response
        %set by the user in the gui
        if strcmpi(source.ShelfType,'lowpass')
            specs.F0  = 0;
        else
            specs.F0 = specs.InputSampleRate/2;
        end
        specs.Order = evaluatevars(source.Order);
        specs.Fc    = getnum(source, 'Fc');        
        specs.S     = evaluatevars(source.S);   
        %G0 is specified via a boost/cut gain parameter Gbc in the gui
        specs.G0    = evaluatevars(source.Gbc);
    case 'n,flow,fhigh,gref,g0,gbw'
        specs.Order = evaluatevars(source.Order);
        specs.Flow  = getnum(source, 'Flow');
        specs.Fhigh = getnum(source, 'Fhigh');
    case 'n,flow,fhigh,gref,g0,gbw,gp'
        specs.Order = evaluatevars(source.Order);
        specs.Flow  = getnum(source, 'Flow');
        specs.Fhigh = getnum(source, 'Fhigh');
        specs.Gpass = evaluatevars(source.Gpass);
    case 'n,flow,fhigh,gref,g0,gbw,gst'
        specs.Order = evaluatevars(source.Order);
        specs.Flow  = getnum(source, 'Flow');
        specs.Fhigh = getnum(source, 'Fhigh');
        specs.Gstop = evaluatevars(source.Gstop);
    case 'n,flow,fhigh,gref,g0,gbw,gp,gst'
        specs.Order = evaluatevars(source.Order);
        specs.Flow  = getnum(source, 'Flow');
        specs.Fhigh = getnum(source, 'Fhigh');
        specs.Gpass = evaluatevars(source.Gpass);
        specs.Gstop = evaluatevars(source.Gstop);
    otherwise
        disp(sprintf('Finish %s', spec));
end

% -------------------------------------------------------------------------
function value = getnum(source, prop)

value = source.(prop);
value = evaluatevars(value);

funits = source.FrequencyUnits;
if ~strncmpi(funits, 'normalized', 10)
    value = convertfrequnits(value, funits, 'Hz');
end


% [EOF]
