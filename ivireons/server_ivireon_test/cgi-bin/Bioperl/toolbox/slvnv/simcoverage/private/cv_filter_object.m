function [filteredConditions, filteredDecisions, numFilteredMCDCEntries]=filter_object(cvId, metricNames)

	persistent sfIsa mlVer MetricVal;
    
	filteredDecisions = [];
	filteredConditions = [];
    numFilteredMCDCEntries=0;
    
    condEnable=0;
    decEnable=0;
    mcdcEnable=0;
    for (metric=metricNames(:)')
        if (strcmp(metric,'condition'))
            condEnable=1;
        elseif (strcmp(metric,'decision'))
            decEnable=1;
        elseif (strcmp(metric,'mcdc'))
            mcdcEnable=1;
            numFilteredMDCDEntries=0;
        end
    end
        
    
    
 	if isempty(sfIsa)
		sfIsa.trans =    sf('get','default','trans.isa');
		sfIsa.state =    sf('get','default','state.isa');
		sfIsa.junction = sf('get','default','junction.isa');
		sfIsa.data =     sf('get','default','data.isa');
		sfIsa.chart =    sf('get','default','chart.isa');
	end
	
	[origin,refClass,sfId] = cv('get',cvId,'.origin','.refClass','.handle');
	
	if origin==2                                
		switch(refClass)
		case sfIsa.chart
            sf('Parse',sfId);
		case sfIsa.trans
       
            decisions = cv('MetricGet',cvId, cvi.MetricRegistry.getEnum('decision'),'.baseObjs');
            conditions = cv('MetricGet',cvId,cvi.MetricRegistry.getEnum('condition'),'.baseObjs');

            transitionParsedStruct = sf('TransitionParsedStruct', sfId);
            isTriggered = transitionParsedStruct.isTriggered;
            label = sf('get', sfId, '.labelString');
            
			if isTriggered
				% 3 Forms of transitions with labels after an event
				% E
				% E|F [x==1]
				% E|F {action();}
				% E|F /action();
				% E|F /* comment */
                
                eventCnt= cvEventParser(label);

				if eventCnt == 1 
					if isempty(conditions)
                        if (decEnable)
						    filteredDecisions = decisions(1);   
                        end 
					else
                        if (condEnable)
						    filteredConditions = conditions(1);
                        end
					end
				else
					if (eventCnt>length(conditions)&&condEnable)
						error('SLVNV:simcoverage:cv_filter_object:BadInput','Bad stuff');
					end
                    if (condEnable)
					    filteredConditions = conditions(1:eventCnt);
                    end
					if (eventCnt==length(conditions))
                        if(decEnable)
						    filteredDecisions = decisions(1);
                        end
					end
				end;
                numFilteredMCDCEntries=eventCnt;
                
            end
		end
	end
