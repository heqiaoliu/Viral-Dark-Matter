function errorCount = update_truth_table_for_fcn(fcnId, incremental)
%   Copyright 1995-2009 The MathWorks, Inc.
%   $Revision: 1.8.4.11 $  $Date: 2009/02/18 02:32:46 $
    
    errorCount = 0;
    oldChecksum = sf('get',fcnId,'state.truthTable.checksum');

    if incremental
        newChecksum = compute_truth_table_checksum(fcnId);
        
        if isequal(oldChecksum, newChecksum)
            return;
        end
        
        % further sanity check
    end
    
    ignoreErrors = 1;
    errorCount = create_truth_table(fcnId, ignoreErrors);
    
    if errorCount > 0
        errStr = sprintf('Errors occurred during parsing of truth table (#%d).', fcnId);
        construct_error(fcnId, 'Parse', errStr, 0);
    else
        newChecksum = compute_truth_table_checksum(fcnId);
        sf('set', fcnId, 'state.truthTable.checksum', newChecksum);
    end
        
    return;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
function  checksum = compute_truth_table_checksum(fcnId)
    checksum = [0 0 0 0];

    predicateArray = sf('get', fcnId, 'state.truthTable.predicateArray');
    actionArray    = sf('get', fcnId, 'state.truthTable.actionArray');
    underSpecDiagn = sf('get', fcnId, 'state.truthTable.diagnostic.underSpecification');
    overSpecDiagn  = sf('get', fcnId, 'state.truthTable.diagnostic.overSpecification');
    IsEmTable      = is_eml_truth_table_fcn(fcnId);

    % add internal truth table version
    truthTableVersion = 1.0;
    checksum = md5(checksum, truthTableVersion);

    % Compute checksum for truth table content
    checksum = md5(checksum, predicateArray);
    checksum = md5(checksum, actionArray);
    
    % Checksum for over/under specification diagnostic setttings
    checksum = md5(checksum, underSpecDiagn);
    checksum = md5(checksum, overSpecDiagn);
    
    % Checksum for implementation mode
    checksum = md5(checksum, IsEmTable);
    
    % Checksum for C-bitops flags algorithm.
    checksum = md5(checksum, truth_table_gen_use_flags_algorithm(fcnId));
        
    % Checksum on autogened content
    if IsEmTable
        checksum = md5(checksum, eml_content_checksum(fcnId));
    else
        checksum = md5(checksum, diagram_content_checksum(fcnId));
    end
    
    return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function checksum = eml_content_checksum(fcnId)
% Calculate checksum for the autogened eml content

    script = sf('get', fcnId, 'state.eml.script');
    [pStr st en] = eml_man('find_prototype_str',script);
    
    % Checksum for # of lines in prototype string
    % This is to make sure script line to table item mapping is accurate
    checksum = md5(length(find(pStr == 10)));

    % Checksum for eML script, without prototype string
    checksum = md5(checksum, script(en+1:end));
    return;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function checksum = diagram_content_checksum(fcnId)
% Calculate checksum for the autogened diagram content

    checksum = [0 0 0 0];
    
    % Checksum for all auto-generated tmp data under truthtable
    allData = sf('DataOf',fcnId);
    autogenData = sf('find',allData,'data.autogen.isAutoCreated',1);
    autogenTempData = sf('find',autogenData,'data.scope','TEMPORARY_DATA');
    for i=1:length(autogenTempData)
        checksum = md5(checksum,data_check_sum(autogenTempData(i)));    
    end

    % WISH we need a much better checksum mechanism
    % Here, we simply rely on user should not modify/delete the autogened diagram.
    transitions = sf('TransitionsOf', fcnId);
    checksum = md5(checksum, isempty(transitions));

    return;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
function checksum =  data_check_sum(dataId)
    [dataName,dataSize,dataType,dataScope] =sf('get',dataId...
                                  ,'data.name'...
                                  ,'data.props.array.size'...
                                  ,'data.props.type'...
                                  ,'data.scope');
    checksum = md5(dataName,dataSize,dataType,dataScope);
    return;
    