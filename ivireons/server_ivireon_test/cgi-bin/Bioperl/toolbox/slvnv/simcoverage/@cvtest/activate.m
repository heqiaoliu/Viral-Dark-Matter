function activate(test, modelcovId)
     % Make this the activeTest
     testId = test.id;
     cv('set',modelcovId,'.activeTest',testId);
    
     % Remove this test from pending test link list
     if cv('get',testId,'.linkNode.parent')==modelcovId,
         cv('PendingTestRemove',modelcovId,testId);
     end
    
