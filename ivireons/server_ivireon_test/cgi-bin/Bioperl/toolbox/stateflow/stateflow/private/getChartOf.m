% get the chart of the object
function chartId = getChartOf(objectId)

CHART_ISA = sf('get', 'default', 'chart.isa');
STATE_ISA = sf('get', 'default', 'state.isa' );
TRANSITION_ISA = sf('get', 'default', 'transition.isa' );
JUNCTION_ISA = sf('get', 'default', 'junction.isa' );
EVENT_ISA = sf('get', 'default', 'event.isa' );
DATA_ISA = sf('get', 'default', 'data.isa' );

objectIsA = sf('get', objectId, '.isa');
switch objectIsA
    case CHART_ISA
        chartId = objectId;
    case {STATE_ISA, TRANSITION_ISA, JUNCTION_ISA}
        chartId = sf('get', objectId, '.chart');
    case DATA_ISA
        linkNodeParentId = sf('get', objectId, 'data.linkNode.parent');
        chartId = getChartOf(linkNodeParentId);
    case EVENT_ISA
        linkNodeParentId = sf('get', objectId, 'event.linkNode.parent');
        chartId = getChartOf(linkNodeParentId);
    otherwise
        chartId = 0;
end
