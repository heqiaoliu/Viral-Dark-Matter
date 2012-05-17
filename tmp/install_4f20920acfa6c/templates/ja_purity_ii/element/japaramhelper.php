<?php
/*
#------------------------------------------------------------------------
  JA Purity II for Joomla 1.5
#------------------------------------------------------------------------
#Copyright (C) 2004-2009 J.O.O.M Solutions Co., Ltd. All Rights Reserved.
#@license - GNU/GPL, http://www.gnu.org/copyleft/gpl.html
#Author: J.O.O.M Solutions Co., Ltd
#Websites: http://www.joomlart.com - http://www.joomlancers.com
#------------------------------------------------------------------------
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
		if (substr($name, 0, 1) == '@'  ) {
			$name = substr($name, 1);
			if (method_exists ($this, $name)) {
				return $this->$name ($name, $value, $node, $control_name);
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
		if (substr($name, 0, 1) == '@' || !isset( $node->_attributes['label'] ) || !$node->_attributes['label']) return;
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
		$group			= ( isset( $node->_attributes['group'] ) ) ? $node->_attributes['group'] : '';
		$group			= $group ? "id='params$group-group'":"";
		if ( $_title ) {
			$_title = html_entity_decode( JText::_( $_title ) );
		}

		if ( $_description ) { $_description = html_entity_decode( JText::_( $_description ) ); }
		if ( $_url ) { $_url = " <a target='_blank' href='{$_url}' >[".html_entity_decode( JText::_( "Demo" ) )."]</a> "; }

		$html = '
		<h4 class="block-head '.$class.'" '.$group.'>'.$_title.$_url.'</h4>
		<div class="block-des '.$class.'">'.$_description.'</div>
		';

		return $html;
	}
	
	/**
	 * include js: name="@js" file="filepath.js"
	 */
	function js( $name, $value, &$node, $control_name ) {
		$file = ( isset( $node->_attributes['file'] ) ) ? trim($node->_attributes['file']) : '';
		
		if(strpos($file, 'http') !== 0) {
			$uri = str_replace(DS,"/",str_replace( JPATH_SITE, JURI::base (), dirname(dirname(__FILE__)) ));
			$uri = str_replace("/administrator", "", $uri);
			$uri = $uri."/";
		} else {
			$uri = $file;
			$file = '';
		}
		JHTML::script($file, $uri);
		return ;
	}

	/**
	 * include css: name="@css" file="filepath.css"
	 */
	function css( $name, $value, &$node, $control_name ) {
		$file = ( isset( $node->_attributes['file'] ) ) ? trim($node->_attributes['file']) : '';
		
		if(strpos($file, 'http') !== 0) {
			$uri = str_replace(DS,"/",str_replace( JPATH_SITE, JURI::base (), dirname(dirname(__FILE__)) ));
			$uri = str_replace("/administrator", "", $uri);
			$uri = $uri."/";
		} else {
			$uri = $file;
			$file = '';
		}
		JHTML::stylesheet($file, $uri);
		return ;
	}
	
	/**
	 * Subtype - Checkbox: subtype="checkbox"
	 */
	function checkbox ( $name, $value, &$node, $control_name ){
		$options = array ();
		$paramname = ''.$control_name.'['.$name.'][]';
		$id = $control_name.$name;
		$k = 0;
		$html = "";
		
		$cols = intval($node->_attributes['cols']);
		if($cols == 0) $cols = 1;
		$width = floor(100/$cols);
		$style = ' style="width:'.$width.'%;"';
		
		foreach ($node->children() as $option)
		{
			$group = intval($option->attributes('group'));
			$odesc	= JText::_($option->attributes('description'));
			$otext	= JText::_($option->data());

			$tooltip	= addslashes(htmlspecialchars($odesc, ENT_QUOTES, 'UTF-8'));
			$titletip		= addslashes(htmlspecialchars($otext, ENT_QUOTES, 'UTF-8'));

			if($titletip) {
				$titletip = $titletip.'::';
			}
			
			if($group) {
				$html .= "\n\t<div class=\"group_title\"><span class=\"hasTip\" title=\"{$titletip}{$tooltip}\">$otext</span></div>";
			} else {
			
				$k++;
				$oval	= $option->attributes('value');
				$children	= $option->attributes('children');
				$alt = ($children) ? ' alt="'.$children.'"' : '';
				$extra	 = '';
	
				if (is_array( $value ))
				{
					foreach ($value as $val)
					{
						$val2 = is_object( $val ) ? $val->$key : $val;
						if ($oval == $val2)
						{
							$extra .= ' checked="checked"';
							break;
						}
					}
				} else {
					$extra .= ( (string)$oval == (string)$value  ? ' checked="checked"' : '' );
				}
				
				$html .= "\n\t<div class=\"group_item\" $style>";	
				$html .= "\n\t<input type=\"checkbox\" name=\"$paramname\" id=\"$id$k\" value=\"$oval\"$extra $alt />";
				$html .= "\n\t<label class=\"hasTip\" title=\"{$titletip}{$tooltip}\" for=\"$id$k\">$otext</label>";
				$html .= "\n\t</div>";
			}
		}

		return $html;
	}
	/**
	 * Subtype - container, subtype="container"
	 */
	function container ( $name, $value, &$node, $control_name ){
		$paramname = ''.$control_name.'['.$name.']';
		$id = $control_name.$name;
		$cols = ( isset( $node->_attributes['cols'] ) && $node->_attributes['cols'] != '')  ? 'cols="'.intval($node->_attributes['cols']).'"' : '';
		$rows = ( isset( $node->_attributes['rows'] ) && $node->_attributes['rows'] != '')  ? 'rows="'.intval($node->_attributes['rows']).'"' : '';
		
		$html = "";
		$html .= "\n\t<textarea name=\"$paramname\" id=\"$id\" $cols $rows />$value</textarea><br />";
		$html .= "\n\t".'<a href="javascript: CopyToClipboard(\''.$id.'\');">'.JText::_('COPY').'</a>';
		$html .= "\n\t".'&nbsp;|&nbsp;';
		$html .= "\n\t".'<a class="modal" id="jaMapPreview" target="_blank" href="#" rel="{handler: \'iframe\', size: {x: 640, y: 480}}">'.JText::_('PREVIEW').'</a>';		
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
		$HTMLCats[0]->title = JText::_("ALL CATEGORY");
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
		$attributes = $node->attributes(); // echo '<pre>'.print_r($attributes); die;
		$groups = array();
		if( isset($attributes['value']) && $attributes['value'] != "" ){
			$groups = preg_split("/[|]/", $attributes['value']);
		}
		
		if (!defined ('_JA_PARAM_HELPER')) {
			define ('_JA_PARAM_HELPER', 1);
			$uri = str_replace(DS,"/",str_replace( JPATH_SITE, JURI::base (), dirname(__FILE__) ));
			$uri = str_replace("/administrator", "", $uri);
			
			JHTML::stylesheet('japaramhelper.css', $uri."/");
			JHTML::script('japaramhelper.js', $uri."/");
		}
?>
<script type="text/javascript">
		window.addEvent( "domready", function(){
			<?php foreach ($groups as $group):?>
			initjapramhelpergroup( "<?php echo $group; ?>", { hideRow:<?php echo(isset($attributes['hiderow']) ? $attributes['hiderow']:false) ?>} );
			<?php endforeach;?>
		} );
</script>
<?php		
	return;
	}
} 