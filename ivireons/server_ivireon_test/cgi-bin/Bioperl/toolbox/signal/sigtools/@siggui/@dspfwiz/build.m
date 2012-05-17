function build(this)
%BUILD Sync the gui and the parameter and build the model

%   Copyright 1995-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/06/13 15:30:18 $

str  = 'Realizing Model';

% Send the message that realization has begun
sendstatus(this,str);

if strcmpi(this.UseBasicElements, 'On'),

    fcn = 'realizemdl';

    % Get the values from the GUI and remove those that the parameter object
    % does not care about.
    s = getstate(this);
    s = rmfield(s, {'Version', 'Tag', 'Filter', 'UseBasicElements', 'OptimizeScaleValues'});

    if strcmpi(this.Destination, 'user defined')
        s.Destination = s.UserDefined;
    end
    s = rmfield(s, 'UserDefined');

    % Sync the parameter with the GUI
    p = fieldnames(s);
    v = struct2cell(s);

    inputs = [p v]'; 
    inputs = {inputs{:}};
    
else
    
    if strcmpi(this.Destination, 'user defined')
        destination = this.UserDefined;
    else
        destination = this.Destination;
    end
        
    fcn = 'block';
    inputs = {'Destination', destination, 'BlockName', this.BlockName, ...
        'OverwriteBlock', this.OverWrite};
end

sendstatus(this,sprintf('%s ...', str));

if isa(this.Filter, 'dfilt.abstractsos')
    oldOptim = this.Filter.OptimizeScaleValues;
    this.Filter.OptimizeScaleValues = strcmp(this.OptimizeScaleValues, 'on');
end

capturewarnings(fcn, this.Filter, inputs{:});

if isa(this.Filter, 'dfilt.abstractsos')
    this.Filter.OptimizeScaleValues = oldOptim;
end

% Send the message that realization is complete
sendstatus(this,sprintf('%s ... done', str));

% [EOF]
