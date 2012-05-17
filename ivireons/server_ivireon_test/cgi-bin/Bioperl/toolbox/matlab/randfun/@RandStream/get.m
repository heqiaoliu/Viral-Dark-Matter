function p = get(s,propname)
%GET Get a random stream property.
%   GET(S) prints the list of properties for the random stream S.
%
%   P = GET(S) returns all properties of S in a scalar structure.
%
%   P = GET(S,'PropertyName') returns the property 'PropertyName'.
%
%   See also RANDSTREAM, RANDSTREAM/SET.

%   Copyright 2008 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $  $Date: 2009/01/23 21:37:46 $

if nargin == 1
    % The order here matches that of the disp method
    props = struct('Type',getproperty(s,'type'), ...
                   'NumStreams',getproperty(s,'numstreams'), ...
                   'StreamIndex',getproperty(s,'streamindex'), ...
                   'Substream',getproperty(s,'substream'), ...
                   'Seed',getproperty(s,'seed'), ...
                   'State',{getproperty(s,'state')}, ... % this might be a cell array
                   'RandnAlg',getproperty(s,'randnalg'), ...
                   'Antithetic',getproperty(s,'antithetic'), ...
                   'FullPrecision',getproperty(s,'fullprecision'));
    if nargout == 1
        p = props;
    else
        disp(props);
    end
    
elseif nargin == 2
    if iscellstr(propname)
        p = cell(1,numel(propname));
        for i = 1:length(p)
            p{i} = getproperty(s,propname{i});
        end
    else
        p = getproperty(s,propname);
    end
end


function p = getproperty(s,propname)
if s.StreamID==0
    error('MATLAB:RandStream:get:InvalidHandle', 'Invalid or deleted object.');
end
    
switch lower(propname)
case 'type'
    p = s.Type;
case 'numstreams'
    p = s.NumStreams;
case 'streamindex'
    p = s.StreamIndex;
case 'substream'
    p = getset_mex('substream',s.StreamID);
case 'seed'
    p = s.Seed;
case 'state'
    p = getset_mex('state',s.StreamID);
case 'randnalg'
    p = getset_mex('randnalg',s.StreamID);
case 'antithetic'
    p = getset_mex('antithetic',s.StreamID);
case 'fullprecision'
    p = getset_mex('fullprecision',s.StreamID);
otherwise
    error('MATLAB:RandStream:get:UnrecognizedProperty', ...
          'Unrecognized property ''%s''.',propname);
end
