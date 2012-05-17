classdef nnetLayer

% Copyright 2010 The MathWorks, Inc.
  
  properties
    dimensions = 0; % 1-dimension of size 0
    distanceFcn = '';
    distanceParam = nnetParam;
    distances = [];
    initFcn = 'initwb';
    name = 'Layer';
    netInputFcn = 'netsum';
    netInputParam = nnetParam('netsum');
    positions = zeros(0,1);
    range = zeros(0,2);
    size = 0;
    topologyFcn = '';
    transferFcn = 'purelin';
    transferParam = nnetParam('purelin');
    userdata = struct;
  end
  
  methods
    
    function x = nnetLayer(s)
      if nargin == 0
        x.userdata.note = 'Put your custom layer information here.';
      elseif isstruct(s)
        x = nnconvert.struct2obj(x,s);
      else
        nnerr.throw('Unrecognized input argument.');
      end
    end
    
    function disp(x)
      isLoose = strcmp(get(0,'FormatSpacing'),'loose');
      if numel(x) == 0
        disp('    Empty array of Neural Network Layers.');
      elseif numel(x) > 1
        disp(['    Array of ' num2str(numel(x)) ' Neural Network Layers.'])
      else
        disp('    Neural Network Layer');
        if (isLoose), fprintf('\n'), end
        disp([nnlink.prop2link('layer','name') nnstring.str2str(x.name)]);
        disp([nnlink.prop2link('layer','dimensions') nnstring.int2str(x.dimensions)]);
        disp([nnlink.prop2link('layer','distanceFcn') nnlink.fcn2strlink(x.distanceFcn)]);
        disp([nnlink.prop2link('layer','distanceParam') nnlink.paramstruct2str(x.distanceParam)]);
        disp([nnlink.prop2link('layer','distances') nnstring.num2str(x.distances)]);
        disp([nnlink.prop2link('layer','initFcn') nnlink.fcn2strlink(x.initFcn)]);
        disp([nnlink.prop2link('layer','netInputFcn') nnlink.fcn2strlink(x.netInputFcn)]);
        disp([nnlink.prop2link('layer','netInputParam') nnlink.paramstruct2str(x.netInputParam)]);
        disp([nnlink.prop2link('layer','positions') nnstring.num2str(x.positions)]);
        disp([nnlink.prop2link('layer','range') nnstring.num2str(x.range)]);
        disp([nnlink.prop2link('layer','size') nnstring.num2str(x.size)]);
        disp([nnlink.prop2link('layer','topologyFcn') nnlink.fcn2strlink(x.topologyFcn)]);
        disp([nnlink.prop2link('layer','transferFcn') nnlink.fcn2strlink(x.transferFcn)]);
        disp([nnlink.prop2link('layer','transferParam') nnlink.paramstruct2str(x.transferParam)]);
        disp([nnlink.prop2link('layer','userdata') '(your custom info)']);
      end
      if (isLoose), fprintf('\n'), end
    end
    
    function s = struct(x)
      s = nnconvert.obj2struct(x);
    end
    
  end
end
