function varargout = design(this, varargin)
%DESIGN Design the pulse shaping filter object.

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/03/31 00:00:10 $

% Call the superclass design method.  
if nargout
    hd = superdesign(this, varargin{:});
    
    % Create a pulse shaping fdesign with shape and specification of "this"
    psFDesign = fdesign.pulseshaping(this.SamplesPerSymbol, ...
        this.Response, this.Specification);
    
    % Determine the properties of psFDesign
    props = get(this);
    fn = fieldnames(props);
    
    % Remove properties that we do not want to set
    fn = setdiff(fn, ...
        {'Response', 'Description', 'Specification', ...
        'SamplesPerSymbol', 'NormalizedFrequency', 'Fs'});
    
    % Set the properties
    for p=1:length(fn)
        psFDesign.(fn{p}) = this.(fn{p});
    end
    if ~ischar(props.Fs)
        normalizefreq(psFDesign, this.NormalizedFrequency, this.Fs)
    else
        normalizefreq(psFDesign, this.NormalizedFrequency)
    end
    
    % Put the fdesign.pulseshaping object into the dfilt object
    setfdesign(hd, psFDesign);
    varargout{1} = hd;
else
    superdesign(this, varargin{:});
end

%[EOF]