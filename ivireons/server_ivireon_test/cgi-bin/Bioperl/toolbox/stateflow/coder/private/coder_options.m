function result = coder_options(method,varargin)

%% This is a centralized repository of various coder options
%% that drive Stateflow Code Generation.
%% Usage:
%% sfc('coder_options') 
%% without any arguments returns the options strcuture
%% sfc('coder_options','ignoreChecksums') returns the value of this option
%% sfc('coder_options','ignoreChecksums',1) sets the option to 1
%% For more info on the options, look at the comments in this file.

%   Copyright 1995-2006 The MathWorks, Inc.
%   $Revision: 1.8.2.6 $  $Date: 2006/06/20 20:46:34 $


persistent sfCoderOptions

if(nargin==0)
    method = '';
end

isReset = strcmp(lower(method),'reset');

if( isReset || isempty(sfCoderOptions))
    sfCoderOptions.ignoreChecksums = 0;
    sfCoderOptions.debugBuilds = 0;
    sfCoderOptions.inlineThreshold = 10;
    sfCoderOptions.inlineThresholdMax = 200;
    sfCoderOptions.inlineStackLimit = 4000;
    sfCoderOptions.maxStackUsage = 200000;
    sfCoderOptions.maintainOneToOne = 0;
	 sfCoderOptions.ignoreUnresolvedSymbols = 0;
	 sfCoderOptions.dataflowAnalysisThreshold = -1;
	 sfCoderOptions.algorithmWordsizes = [8 16 32 32];
	 sfCoderOptions.targetWordsizes = [8 16 32 32];
end

if(nargin==0 || isempty(method) || isReset)
    result = sfCoderOptions;
    return;
end

names = fieldnames(sfCoderOptions);
for i=1:length(names)
	if(strcmp(lower(names{i}),lower(method)))
		if length(varargin)>0
            % setting new value
            newVal = [];
            
            if isnumeric(varargin{1})
                newVal = varargin{1};
            elseif ischar(varargin{1})
                newVal = str2num(varargin{1});
            end
            
            if ~isempty(newVal)
                sfCoderOptions = setfield(sfCoderOptions,names{i},newVal);
            end
    	end
    	result = getfield(sfCoderOptions,names{i});
		return;
	end
end

error(sprintf('Invalid option %s passed to coder_options',method));
