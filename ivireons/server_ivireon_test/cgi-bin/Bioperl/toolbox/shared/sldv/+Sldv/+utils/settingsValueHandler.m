function features = settingsValueHandler(features, modelH, toStore)
% it tries to get the parameter and chaceh it if toStore is on
% rules - if modelH is given it uses get_param, e.g set_param(modelH, ....
%       - then it tries to find a 'set' and will use 'get' omitting last
%       argument .e.g, sf('Private', 'set' ....
%       - then gets by omitting the last arguments, .e.g feature(...

%   Copyright 2009 The MathWorks, Inc.

    for idx = 1:length(features)
        cf = features{idx};
        startIdx = 1;
        if isempty(modelH)
            startIdx = 2;
        end
        pars = {};
        for i = startIdx:length(cf) 
            ca = cf{i};
            if ischar(ca)
                ca = ['''' ca '''']; %#ok
            else
                ca = num2str(ca);
            end
            pars{end+1} = [ca, ',']; %#ok
        end
        cmd = [cf{1} '('];
        if (toStore)        
            if ~isempty(modelH)
                cmd = ['get_param(''' getfullname(modelH) ''','];
            else
                for idxp = 1:length(pars)
                    if strcmp(pars{idxp},'''set'',')
                        pars{idxp} = '''get'','; %#ok
                        break;
                    end
                end
            end

            parExpr = cat(2,pars{1:end-1});
            getExpr = [cmd parExpr(1:end-1) ');'];         
            getCurrentValue = evalin('base', getExpr);
            if ischar(getCurrentValue)
                getCurrentValue = strrep(getCurrentValue,'''','''''');
            end
            cf{end} = getCurrentValue;
            %replace the value with the old value for future restore purposes
            features{idx} = cf;
        else
            if ~isempty(modelH)
                cmd = ['set_param(''' getfullname(modelH) ''','];
            end

            parExpr = cat(2,pars{:});
            setExpr = [cmd parExpr(1:end-1) ');'];
            evalin('base', setExpr);
        end
    end
end

