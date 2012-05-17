<?php
/**
 * ------------------------------------------------------------------------
 * T3V2 Framework
 * ------------------------------------------------------------------------
 * Copyright (C) 2004-20011 J.O.O.M Solutions Co., Ltd. All Rights Reserved.
 * @license - GNU/GPL, http://www.gnu.org/licenses/gpl.html
 * Author: J.O.O.M Solutions Co., Ltd
 * Websites: http://www.joomlart.com - http://www.joomlancers.com
 * ------------------------------------------------------------------------
 */

// Ensure this file is being included by a parent file
defined('_JEXEC') or die( 'Restricted access' );

/**
 * Radio List Element
 *
 * @since      Class available since Release 1.2.0
 */
class JElementJaparamhelper extends JElement
{
	/**
	 * Element name
	 *
	 * @access	protected
	 * @var		string
	 */
	var	$_name = 'Japaramhelper';

	function fetchElement( $name, $value, &$node, $control_name ) {
		if (!defined ('_JA_PARAM_HELPER')) {
			define ('_JA_PARAM_HELPER', 1);
			$uri = str_replace(DS,"/",str_replace( JPATH_SITE, JURI::base (), dirname(__FILE__) ));
			$uri = str_replace("/administrator", "", $uri);
			
			JHTML::stylesheet('japaramhelper.css', $uri."/assets/css/");
			JHTML::script('japaramhelper.js', $uri."/assets/js/");
		}
		$func 	= (isset($node->_attributes['function']) && (string)$node->_attributes['function'])?(string)$node->_attributes['function']:'';
		if (substr($func, 0, 1) == '@'  ) {
			$func = substr($func, 1);
			if (method_exists ($this, $func)) {
				return $this->$func ($name, $value, $node, $control_name);
			}
		} else {
			$subtype = ( isset( $node->_attributes['subtype'] ) ) ? trim($node->_attributes['subtype']) : '';
			if (method_exists ($this, $subtype)) {
				return $this->$subtype ($name, $value, $node, $control_name);
			}
		}
		return;
	}
	
	function fetchTooltip( $label, $description, &$node, $control_name, $name )
	{
		$func 	= (isset($node->_attributes['function']) && (string)$node->_attributes['function'])?(string)$node->_attributes['function']:'';
		if (substr($func, 0, 1) == '@' || !isset( $node->_attributes['label'] ) || !$node->_attributes['label']) return;
		else return parent::fetchTooltip ($label, $description, $node, $control_name, $name);		
	}
	
	/**
	 * render title: name="@title"
	 */
	function title( $name, $value, &$node, $control_name ) {	
		$_title			= ( isset( $node->_attributes['label'] ) ) ? $node->_attributes['label'] : '';
		$_description	= ( isset( $node->_attributes['description'] ) ) ? $node->_attributes['description'] : '';
		$_url			= ( isset( $node->_attributes['url'] ) ) ? $node->_attributes['url'] : '';
		$class			= ( isset( $node->_attributes['class'] ) ) ? $node->_attributes['class'] : '';
		$level			= ( isset( $node->_attributes['level'] ) ) ? $node->_attributes['level'] : '';
		$group			= ( isset( $node->_attributes['group'] ) ) ? $node->_attributes['group'] : '';
		$group			= $group ? "id='params$group-group'":"";
		if ( $_title ) {
			$_title = html_entity_decode( JText::_( $_title ) );
		}

		if ( $_description ) { $_description = html_entity_decode( JText::_( $_description ) ); }
		if ( $_url ) { $_url = " <a target='_blank' href='{$_url}' >[".html_entity_decode( JText::_( "Demo" ) )."]</a> "; }
		
		$regionID = time()+rand();
		
		$class_name = trim(str_replace(" ", "", strtolower($_title) ));
		
		if($level==1){
			$html = '
				<h4 rel="'.$level.'" class="block-head block-head-'.$class_name.' open '.$class.' " '.$group.' id="'.$regionID.'">
					<span class="block-setting" >'.$_title.$_url.'</span> 
					<span class="icon-help editlinktip hasTip" title="'.htmlentities($_description).'">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>
					<a class="toggle-btn open" title="'.JText::_('Expand all').'" onclick="showRegion(\''.$regionID.'\', \'level'.$level.'\'); return false;">'.JText::_('Expand all').'</a>
					<a class="toggle-btn close" title="'.JText::_('Collapse all').'" onclick="hideRegion(\''.$regionID.'\', \'level'.$level.'\'); return false;">'.JText::_('Collapse all').'</a>
		    	</h4>';
		}
		else {
			$html = '
				<h4 rel="'.$level.'" class="block-head block-head-'.$class_name.' open '.$class.' " '.$group.' id="'.$regionID.'">
					<span class="block-setting" >'.$_title.$_url.'</span> 
					<span class="icon-help editlinktip hasTip" title="'.htmlentities($_description).'">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>
					<a class="toggle-btn" title="'.JText::_('Click here to expand or collapse').'" onclick="showHideRegion(\''.$regionID.'\', \'level'.$level.'\'); return false;">open</a>
		    	</h4>';
		} 
		//<div class="block-des '.$class.'"  id="desc-'.$regionID.'">'.$_description.'</div>';
		
		return $html;
	}
			

	
	/**
	 * Subtype - Categories, multiselect: subtype="categories"
	 */
	function categories ( $name, $value, &$node, $control_name ){
		$db = &JFactory::getDBO();
		$query = '
			SELECT 
				c.section,
				s.title AS section_title,
				c.id AS cat_id,
				c.title AS cat_title 
			FROM #__sections AS s
			INNER JOIN #__categories c ON c.section = s.id
			WHERE s.published=1
			AND c.published = 1
			ORDER BY c.section, c.title
			';
		$db->setQuery( $query );
		$cats = $db->loadObjectList();
		$HTMLCats=array();
		$HTMLCats[0]->id = '';
		$HTMLCats[0]->title = JText::_("All Categories");
		$section_id = 0;
		foreach ($cats as $cat) {
			if($section_id != $cat->section) {
				$section_id = $cat->section;
				
				$cat->id = $cat->section;
				$cat->title = $cat->section_title;
				$optgroup = JHTML::_('select.optgroup', $cat->title, 'id', 'title');
				array_push($HTMLCats, $optgroup);
			}
			$cat->id = $cat->cat_id;
			$cat->title = $cat->cat_title;
			array_push($HTMLCats, $cat);
		}
		return JHTML::_('select.genericlist',  $HTMLCats, ''.$control_name.'['.$name.'][]', 'class="inputbox" style="width:95%;" multiple="multiple" size="10"', 'id', 'title', $value );
	}	
	/**
	 * render js to control setting form.
	 */
	function group( $name, $value, &$node, $control_name ){
	?>
		
		<script type="text/javascript">
			<?php foreach ($node->option as $option) {?>
				<?php $hideRow = isset($option->_attributes['hiderow'])?''.$option->_attributes['hiderow'].'':1;?>
				japh_addgroup ('<?php echo $option->_attributes['for']; ?>', { val: '<?php echo $option->_attributes['value']; ?>', els_str: '<?php echo trim((string) $option->_data); ?>', group:'<?php echo $control_name?>', hideRow: <?php echo $hideRow?>});
			<?php };?>			
		</script>
		
		<?php		
		return;
	}
	
	/**
	 * render js to control setting form for embeded.
	 */
	function group2( $name, $value, &$node, $control_name ){ 
		$attributes = $node->attributes(); // echo '<pre>'.print_r($attributes); die;
		$_title			= ( isset( $node->_attributes['label'] ) ) ? JText::_($node->_attributes['label'] ): '';
		$_description	= ( isset( $node->_attributes['description'] ) ) ? JText::_($node->_attributes['description']) : '';
				
		$groups = array();
		if( isset($attributes['value']) && $attributes['value'] != "" ){
			$groups = preg_split("/[|]/", $attributes['value']);
		}
		$html = '';
		if (!defined ('_JA_PARAM_HELPER')) {
			define ('_JA_PARAM_HELPER', 1);
			$uri = str_replace(DS,"/",str_replace( JPATH_SITE, JURI::base (), dirname(__FILE__) ));
			$uri = str_replace("/administrator", "", $uri);
			
			JHTML::stylesheet('japaramhelper.css', $uri."/assets/css/");
			JHTML::script('japaramhelper.js', $uri."/assets/js/");		
		}
		
		$html .= '<script type="text/javascript">';
		$html .= 'window.addEvent( "domready", function(){';
		foreach ($groups as $group){
			$html .= 'initjapramhelpergroup( "'.$group.'", { hideRow:'.(isset($attributes['hiderow']) ? $attributes['hiderow']:false).' } );';
		}
		$html .= '} );</script>';
		if ($_title) $html .= "<h4 class=\"block-head\">$_title</h4>";
		if ($_description) $html .= "<div class=\"block-des\">$_description</div>";
		return $html;
	}	
} 