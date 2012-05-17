function x = simulinkStructToVector(this,xstr,varargin) 
% SIMULINKSTRUCTTOVECTOR  Return a flattened vector of a structure of double valued
% Simulink signals.  Default the values field will be returned.   
%
 
% Author(s): John W. Glass 01-Mar-2005
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2007/10/15 23:28:39 $

if isstruct(xstr)
    % Eliminate nondouble states
    for ct = length(xstr.signals):-1:1
        if ~strcmp(class(xstr.signals(ct).values),'double')
            xstr.signals(ct) = [];
        end
    end

    % Compute the number of states in the structure
    nels = 0;
    for ct = 1:length(xstr.signals)
        nels = nels + prod([xstr.signals(ct).dimensions]);
    end

    % Initialize the state vector
    x = zeros(nels,1);

    % Initialize the index into the state vector
    ind = 1;

    % Loop over to write the states into the vector
    for ct = 1:length(xstr.signals)
        if (nargin == 2)
            x(ind:ind+prod(xstr.signals(ct).dimensions)-1) = xstr.signals(ct).values(:);
        elseif strcmp(varargin{1},'sampleTime')
            tsx = xstr.signals(ct).sampleTime;
            x(ind:ind+prod(xstr.signals(ct).dimensions)-1) = tsx(1:end,1);
        end
        
        ind = ind + prod(xstr.signals(ct).dimensions);
    end
elseif isempty(xstr)
    x = zeros(0,1);
else
    x = xstr;
end