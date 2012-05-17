function b = set(s,varargin)
%SET Set a random stream property value.
%   SET(S,'PropertyName',VALUE) sets the property 'PropertyName' of the
%   random stream S to the value VALUE.
%  
%   SET(S,'Property1',Value1,'Property2',Value2,...) sets multiple
%   random stream property values with a single statement.
%  
%   SET(S,A), where A is a structure whose field names are property names of
%   the random stream S, sets the properties of S named by each field with the
%   values contained in those fields.
%
%   A = SET(S,'Property') or SET(S,'Property') displays or returns possible
%   values for the specified property of S.
%
%   A = SET(S) or SET(S) displays or returns all properties of S and their
%   possible values. 
%
%   See also RANDSTREAM, RANDSTREAM/GET.

%   Copyright 2008 The MathWorks, Inc. 
%   $Revision: 1.1.6.5 $  $Date: 2009/01/23 21:37:53 $

if nargin == 2 && isstruct(varargin{1}) % values in fields of a structure
    a = varargin{1};
    fn = fieldnames(a);
    for i = 1:length(fn)
        propname = fn{i};
        for j = 1:numel(a) % what HG does
            p = a(j).(propname);
            setproperty(s,propname,p);
        end
    end
    
elseif nargin < 3
    readOnlyPropertyNames = {'Type' 'NumStreams' 'StreamIndex' 'Seed'};
    writablePropertyNames = {'Substream' 'State' 'RandnAlg' 'Antithetic' 'FullPrecision'};
    
    propertyVals   = cell2struct(cell(size(writablePropertyNames)), writablePropertyNames, 2);
    propertyDescrs = cell2struct(cell(size(writablePropertyNames)), writablePropertyNames, 2);
    
%     genTypes = getset_mex('generatorlist',true);
%     propertyVals.Type          = {};
%     propertyDescrs.Type        = sprintf('''%s'' | ', genTypes{:}); propertyDescrs.Type(end-2:end) = [];
%     propertyVals.NumStreams    = {};
%     propertyDescrs.NumStreams  = 'Positive integer scalar';
%     propertyVals.StreamIndex   = {};
%     propertyDescrs.StreamIndex = 'Positive integer scalar';
    propertyVals.Substream        = {};
    propertyDescrs.Substream      = 'Positive integer scalar';
%     propertyVals.Seed          = {};
%     propertyDescrs.Seed        = 'Non-negative integer scalar';
    propertyVals.State            = {};
    propertyDescrs.State          = 'Numeric vector | Cell array';
    propertyVals.RandnAlg         = {'Ziggurat', 'Polar', 'Inversion'};
    propertyDescrs.RandnAlg       = '''Ziggurat'' | ''Polar'' | ''Inversion''';
    propertyVals.Antithetic       = {true false};
    propertyDescrs.Antithetic     = 'Logical scalar';
    propertyVals.FullPrecision    = {true false};
    propertyDescrs.FullPrecision  = 'Logical scalar';
    
    if nargin == 2
        propname = varargin{1};
        i = find(strcmpi(propname,writablePropertyNames));
        if isempty(i)
            i = find(strcmpi(propname,readOnlyPropertyNames));
            if isempty(i)
                error('MATLAB:RandStream:set:UnrecognizedProperty', ...
                      'Unrecognized property ''%s''.',propname);
            else
                error('MATLAB:RandStream:set:IllegalPropertyAssignment', ...
                      'You cannot set the ''%s'' property.',propname);
            end
        end
        
        if nargout == 1
            b = propertyVals.(writablePropertyNames{i});
        else
            disp(propertyDescrs.(writablePropertyNames{i}));
        end        
    else
        if nargout == 1
            b = propertyVals;
        else
            fields = fieldnames(propertyDescrs);
            for i = 1:length(fields)
                f = fields{i};
                disp(sprintf('%16s: %s',f,propertyDescrs.(f)));
            end
        end
    end
    
    
elseif mod(nargin,2) == 1 %name/value pairs
    if nargout > 0
        error('MATLAB:RandStream:set:MaxLHS', ...
              'Too many output arguments.');
    end
    for i = 1:(nargin-1)/2
        propname = varargin{2*i-1};
        p = varargin{2*i};
        setproperty(s,propname,p);
    end
else
    error('MATLAB:RandStream:set:WrongNumberArgs', ...
          'Wrong number of arguments.');
end


function p = setproperty(s,propname,p)
if s.StreamID==0
    error('MATLAB:RandStream:set:InvalidHandle', 'Invalid or deleted object.');
end

switch lower(propname)
case 'substream'
    getset_mex('substream',s.StreamID,p);
case 'state'
    getset_mex('state',s.StreamID,p);
case 'randnalg'
    getset_mex('randnalg',s.StreamID,p);
case 'antithetic'
    getset_mex('antithetic',s.StreamID,p);
case 'fullprecision'
    getset_mex('fullprecision',s.StreamID,p);
case {'type' 'seed' 'numstreams' 'streamindex'}
    error('MATLAB:RandStream:set:IllegalPropertyAssignment', ...
          'You cannot set the ''%s'' property.',propname);
otherwise
    error('MATLAB:RandStream:set:UnrecognizedProperty', ...
          'Unrecognized property ''%s''.',propname);
end

