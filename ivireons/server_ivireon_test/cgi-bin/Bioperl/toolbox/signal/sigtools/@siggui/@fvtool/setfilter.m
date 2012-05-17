function setfilter(hFVT, varargin)
%SETFILTER Set the filter in FVTool
%   SETFILTER(hFVT, NUM, DEN) Set the filter in FVTool using the numerator
%   NUM and the denominator DEN to create a Direct Form II Transposed filter.
%
%   SETFILTER(hFVT, NUM) Set the filter in FVTool using the numerator
%   NUM to create a Direct Form II Transposed filter.
%
%   SETFILTER(hFVT, FILTOBJ) Set the filter in FVTool using the filter object
%   FILTOBJ.
%
%   SETFILTER(hFVT, FILTOBJ, OPTS) Set the filter in FVTool according to
%   the options in the structure OPTS.  OPTS can contain the field 'index'
%   which specifies the index in the existing filter vector to set the new
%   filter.
%
%   See also ADDFILTER.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.7.4.1 $  $Date: 2007/12/14 15:18:50 $ 

error(nargchk(2,inf,nargin,'struct'))

% If the input is numeric, use it to create a filter.

opts = struct('index', []);

if isempty(varargin{1}),
    filtobj = [];
else
    
    if isstruct(varargin{end})
        
        % If the last input is a structure, then we need at least 3 inputs
        % (hfvt, filter, structure)
        error(nargchk(3,inf,nargin,'struct'));
        opts     = setstructfields(opts, varargin{end});
        varargin = varargin(1:end-1);
    end
    
    filtobj = hFVT.findfilters(varargin{:});
end

if ~isempty(opts.index),
    oldfilts = get(hFVT, 'Filters');
    
    % We allow the caller to give multiple indexes, one of which can be 1
    % greater than the current number of filters.  The caller could also
    % set the filters and then add a filter, but this would cause a double
    % update.
    if length(oldfilts) < max(opts.index) - 1,
        error(generatemsgid('IdxOutOfBound'),'Index exceeds the number of filters.');
    end
    if length(filtobj) ~= length(opts.index),
        error(generatemsgid('InvalidDimensions'),'Number of indexes does not match the number of filters.');
    end
    for indx = 1:length(opts.index),
        oldfilts(opts.index(indx)) = filtobj(indx);
    end
    filtobj = oldfilts;
end

% Send the newfilter event with the newfilt object.  This is done so that filter listeners
% can be updated before the filter is actually set in the object.
eventData = sigdatatypes.sigeventdata(hFVT, 'NewFilter', filtobj);
send(hFVT, 'NewFilter', eventData);

hFVT.Filters = filtobj;

% [EOF]
