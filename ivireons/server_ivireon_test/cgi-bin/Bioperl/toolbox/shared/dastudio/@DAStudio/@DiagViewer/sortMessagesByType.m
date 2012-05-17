function sortMessagesByType(h)
%  SORTMESSAGESBYTYPE
%
%  Sorts messages to be displayed in the diagnostic viewer by
%  type in the follow order:
%
%    error
%    warning
%    info
%    log
%    diagnostic
%
%  Copyright 2007-2008 The MathWorks, Inc.

  if ~isempty(h.Messages)
    orders = cell(1, length(h.Messages));
    for i = 1:length(h.Messages)
      msg = h.Messages(i);
      order = getOrder(cellstr(msg.Type));
      orders{i} = num2str(order);
    end
    [b indx] = sort(orders);
    h.Messages = h.Messages(indx);
  end

end

function orderValue = getOrder(iName)
  curName = lower(iName);
  if(strcmp(curName, 'error'))
    orderValue = 0;
  elseif(strcmp(curName, 'warning'))
    orderValue = 1;
  elseif(strcmp(curName, 'info'))
    orderValue = 2;
  elseif(strcmp(curName, 'log'))
    orderValue = 3;
  elseif(strcmp(curName, 'diagnostic'))
    orderValue = 4;
  else
    orderValue = 0;
  end

end