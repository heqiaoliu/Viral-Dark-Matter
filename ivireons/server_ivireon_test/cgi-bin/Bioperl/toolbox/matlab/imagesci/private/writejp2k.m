function writejp2k(data, map, filename, fmt, varargin)
%WRITEJP2K Internal function facilitating JPEG2000 writes for J2C and JP2.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/09/03 05:24:32 $

% Input checking.
if (ndims(data) > 3)
    error('MATLAB:writejp2k:tooManyDims', ...
          '%d-D data is not supported for JPEG2000 files', ndims(data));
end

if (~isempty(map))
    error('MATLAB:writejp2k:tooManyDimsForIndexed', ...
          '%d-D indexed image data is not supported for JPEG2000 files', ndims(data));
end

if isfloat(data)
    % single/double data is converted to uint8
    maxval = 255;
    data = uint8(maxval * data);
end

props = set_jp2c_props(data,fmt,varargin{:});

writejp2c(data, filename, props);

function props = set_jp2c_props(data,fmt,varargin)
% SET_JP2C_PROPS
%
% Parse input parameters to produce a properties structure.  
%

%
% Set the default properties.
props.cratio = 1;
props.mode = 'lossy';
props.porder = 'lrcp';
props.qlayers = 1;
props.rlevels = -1;
props.tilewidth = size(data, 2);
props.tileheight = size(data, 1);
props.comment = {};
props.format = fmt;

% Process param/value pairs
paramStrings = {'format'
                'compressionratio'
                'mode'
                'progressionorder'
                'qualitylayers'
                'reductionlevels'
                'tilesize'
                'comment'};

for k = 1:2:length(varargin)
  
    param = lower(varargin{k});
    if (~ischar(param))
        error('MATLAB:writejp2k:badParameterName', ...
              'Parameter name must be a string');
    end
    
    idx = strmatch(param, paramStrings);
    if (isempty(idx))
        error('MATLAB:writejp2k:unrecognizedParameter', ...
              'Unrecognized parameter name "%s"', param);
    elseif (length(idx) > 1)
        error('MATLAB:writejp2k:ambiguousParameter', ...
              'Ambiguous parameter name "%s"', param);
    end

    param = deblank(paramStrings{idx});

    props = process_argument_value ( props, param, varargin{k+1} );
    
end

return



% Process a parameter name/value pair, return the new property structure
function output_props = process_argument_value ( props, param_name, param_value )

output_props = props;

switch param_name 
case 'compressionratio'
  
    cratio = param_value;
    
    if (~isa(cratio,'numeric'))
        error('MATLAB:writejp2k:badCompressionRatio', ...
              '''CompressionRatio'' value must be numeric.')
    end
    if ((cratio < 1) || ~isfinite(cratio))
        error('MATLAB:writejp2k:badCompressionRatio', ...
              'Invalid value specified for ''CompressionRatio''.');
    end
    
    output_props.cratio = cratio;
    
case 'mode'
    
    mode = lower(param_value);
    
    if ((~ischar(mode)) || ...
        ((~isequal(mode, 'lossy')) && (~isequal(mode, 'lossless'))))
        error('MATLAB:writejp2k:badMode', ...
              '''Mode'' must be ''Lossy'' or ''Lossless''')
    end
    
    output_props.mode = mode;
 
case 'progressionorder'
    porder = lower(param_value);
    
    if ((~ischar(porder)) || ...
        (~isequal(porder, 'lrcp') && ~isequal(porder, 'rlcp') && ...
         ~isequal(porder, 'rpcl') && ~isequal(porder, 'pcrl') && ...
         ~isequal(porder, 'cprl')))
        error('MATLAB:writejp2k:badProgressionOrder', ...
              '''ProgressionOrder'' must be ''LRCP'', ''RLCP'', ''RPCL'', ''PCRL'' or ''CPRL''')
    end
    
    output_props.porder = porder;
  
case 'qualitylayers'
    qlayers = param_value;
    
    if (~isa(qlayers,'numeric'))
        error('MATLAB:writejp2k:badQualityLayers', ...
              '''QualityLayers'' value must be numeric')
    end
    if ((qlayers < 1) || (qlayers > 20) || rem(qlayers, 1) ~= 0)
        error('MATLAB:writejp2k:badQualityLayers', ...
              '''QualityLayers'' must be an integer between 1 and 20.');
    end
    
    output_props.qlayers = qlayers;
    
case 'reductionlevels'
    rlevels = param_value;
    
    if (~isa(rlevels,'numeric'))
        error('MATLAB:writejp2k:badReductionLevels', ...
              '''ReductionLevels'' value must be numeric')
    end
    if ((rlevels < 1) || (rlevels > 8)  || rem(rlevels, 1) ~= 0)
        error('MATLAB:writejp2k:badReductionLevels', ...
              '''ReductionLevels'' must be an integer between 1 and 8.');
    end
    
    output_props.rlevels = rlevels;
    
case 'tilesize'
    tilesize = param_value;
    
    if ~isa(tilesize,'numeric') || numel(tilesize) ~= 2
        error('MATLAB:writejp2k:badTileSize', ...
              '''TileSize'' value must be 2-element numeric vector')
    end
    if tilesize(1) < 128 || tilesize(2) < 128 || ...
       ~all(tilesize <= intmax) || any(rem(tilesize, 1) ~= 0)
        error('MATLAB:writejp2k:badTileSize', ...
              '''TileSize'' must contain positive integers between 128 and INTMAX.');
    end

    output_props.tileheight = tilesize(1);
    output_props.tilewidth = tilesize(2);

case 'comment'
    comment = param_value;
    if (~ischar(comment) && ~iscellstr(comment))
        error('MATLAB:writejp2k:badComment', ...
              ['''Comment'' value must be a cell array of' ...
               ' strings or a char matrix']);
    end
    % Convert the char matrix to a cell array
    output_props.comment = cellstr(comment);
end

return


