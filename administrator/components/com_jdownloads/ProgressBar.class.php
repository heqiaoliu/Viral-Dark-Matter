<?php
/**
 * Class ProgressBar
 * Easy to use progress bar in html and css.
 *
 * @author David Bongard (mail@bongard.net | www.bongard.net)
 * @version 1.2 - 20070814
 * @license http://www.opensource.org/licenses/mit-license.php MIT License
 * @copyright Copyright &copy; 2007, David Bongard
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 * Example of usage:
 * <code>
 * require_once 'ProgressBar.class.php';
 * $bar = new ProgressBar();
 *
 * $elements = 100000; //total number of elements to process
 * $bar->initialize($elements); //print the empty bar
 *
 * for($i=0;$i<$elements;$i++){
 *  	//do something here...
 * 		$bar->increase(); //calls the bar with every processed element
 * }
 * </code>
 *
 * Another example:
 * <code>
 * require_once 'ProgressBar.class.php';
 * $bar = new ProgressBar();
 * $bar->setMessage("Let's talk to the user!");
 *
 * $bar->initialize(3); //initialize the bar with the total number of elements to process
 *
 * //do something time consuming here...
 * $bar->increase(); //call for first element
 *
 * //do something time consuming here...
 * $bar->increase(); //call for second element
 * $bar->setMessage("Tell the user what you are doing!");
 *
 * //do something time consuming here...
 * $bar->increase(); //call for third element. end of bar...
 * </code>
 *
 * @changes
 * Version 1.2
 * - added method setMessage() to change the message at runtime (JavaScript)
 * - minor changes in HTML-code
 * - refactoring: added new setter-methods
 *
 * Version 1.1: Use $bar->stop(true) stop the bar instantly at any time.
 *
 */
 
defined( '_JEXEC' ) or die( 'Restricted access-class' );
 
class ProgressBar {
	/**
	* Flag for class initialization.
	* @param bool $initialized true=class initialized
	*/
	private $initialized;
	
	/**
	* Flag for start of the progress bar.
	* @started bool $started true=progress bar has been started.
	*/
	private $started;
	
	/**
	* Flag for the  end of the progress bar.
	* @param bool $finished true=progress bar has reached the end.
	*/
	private $finished;
	
	private $firstStep;
	
	/**
	 * Constructor
	 *
	 * @param str $message Message shown above the bar eg. "Please wait...". Default: ''
	 * @param bool $hide Hide the bar after completion (with JavaScript).
	 * Default: false
	 * @param int $sleepOnFinish Seconds to sleep after bar completion. Default: 0
	 * @param int $barLength Length in pixels. Default: 200
	 * @param int $precision Desired number of steps to show. Default: 20. Precision will become $numElements when greater than $numElements. $barLength will increase if $precision is greater than $barLength.
	 * @param str $backgroundColor Color of the bar background
	 * @param str $foregroundColor Color of the actual progress-bar
	 * @param str $domID Html-Attribute "id" for the bar
	 * @param str $stepElement Element the bar is build from
	 */
    function ProgressBar($message='', $hide=false, $sleepOnFinish=0, $barLength=300, $precision=20,
    					 $backgroundColor='#cccccc', $foregroundColor='blue', $domID='progressbar',
    					 $stepElement='<div style="width:%spx;height:15px;float:left;background-color:%s;"></div>')
    {
		global $pb_instance;
    	$this->instance = $pb_instance++;

    	$this->setAutohide($hide);
    	$this->setSleepOnFinish($sleepOnFinish);
		$this->setDomIDs($domID);
    	$this->setMessage($message);
    	$this->setStepElement($stepElement);
    	$this->setPrecision($precision);
    	$this->setBackgroundColor($backgroundColor);
		$this->setForegroundColor($foregroundColor);
		$this->setBarLength($barLength);
		
		//Initialization
		$this->initialized = false;
		$this->started = false;
		$this->finished = false;
		$this->firstStep = null;
    }


	/**
	 * Print the empty progress bar
	 * @param int $numElements Number of Elements to be processed and number of times $bar->initialize() will be called while processing
	 */
	function initialize($numElements)
	{
		//increase time limit if allowed
		if(!ini_get('safe_mode')){
			set_time_limit(0);
		}

		$this->StepCount = 0;
    	$this->CallCount = 0;

		$numElements = (int) $numElements ;

    	if($numElements == 0){
    		$numElements = 1;
    	}

		//calculate the number of calls for one step
    	$this->CallsPerStep = ceil(($numElements/$this->precision)); // eg. 1000/200 = 100

		//calculate the total number of steps
		if($numElements >= $this->CallsPerStep){
			$this->numSteps = round($numElements/$this->CallsPerStep);
		}else{
			$this->numSteps = round($numElements);
		}

    	//calculate the length of one step
    	$this->stepLength = floor($this->barLength/$this->numSteps);  // eg. 100/10 = 10

    	//the rest is the first step
    	$this->rest = $this->barLength-($this->stepLength*$this->numSteps);

    	if($this->rest > 0){
			$this->firstStep = $this->getStep($this->rest);
    	}

		//build bar background
		$backgroundLength = $this->rest+($this->stepLength*$this->numSteps);
		$this->backgroundBar = sprintf($this->stepElement,$backgroundLength,$this->backgroundColor);

		//stop buffering (only when a buffer is active)
		if (count(ob_list_handlers()) != 0) {
			ob_end_flush();
		}
		
    	//start buffering
    	ob_start();

		echo '<div id="'.$this->domID.'" style="margin-bottom:5px;" class="progressbar">'.
			 '<span style="display:block" id="'.$this->domIDMessage.'">'.$this->message.'</span>'.
			 '<div style="position:absolute;">'.$this->backgroundBar.'</div>' .
			 '<div style="position:absolute;">';

		ob_flush();
		flush();

		$this->initialized = true;
	}

	/**
	 * Count steps and increase bar length
	 *
	 */
	function increase()
	{
		$this->CallCount++;

		if(!$this->started){
			//rest output
			echo $this->firstStep;
			ob_flush();
			flush();
		}

		if($this->StepCount < $this->numSteps
		&&(!$this->started || $this->CallCount == $this->CallsPerStep)){

			//add a step
			echo $this->getStep();
			ob_flush();
			flush();

			$this->StepCount++;
			$this->CallCount=0;
		}
		$this->started = true;

		if(!$this->finished && $this->StepCount == $this->numSteps){
			$this->stop();
		}
	}

	function stop($error=false)
	{
			// close the bar
			echo '</div></div>';
			ob_flush();
			flush();

			//sleep x seconds before ending the script
			if(!$error){
				if($this->sleepOnFinish > 0){
					sleep($this->sleepOnFinish);
				}

				//hide the bar
				if($this->hide){
					echo '<script type="text/javascript">document.getElementById("'.$this->domID.'").style.display = "none";</script>';
					ob_flush();
					flush();
				}
			}
			$this->finished = true;
	}

	function setMessage($text)
	{
		if($this->initialized){
			echo '<script type="text/javascript">document.getElementById("'.$this->domIDMessage.'").innerHTML = "'.$text.'";</script>';
			ob_flush();flush();
		}else{
			$this->message = $text;
		}
	}

	function setAutohide($hide)
	{
    	$this->hide = (bool) $hide;
    }

    function setSleepOnFinish($sleepOnFinish)
    {
    	$this->sleepOnFinish = (int) $sleepOnFinish;
    }

    function setDomIDs($domID)
    {
    	$this->domID = strip_tags($domID).$this->instance;
    	$this->domIDMessage = $this->domID.'_message';
    }

    function setStepElement($stepElement)
    {
    	$this->stepElement = $stepElement;
    }

    function setBarLength($barLength)
    {
    	$this->barLength = (int) $barLength;

    	if($this->barLength < $this->precision){
    		$this->barLength = $this->precision;
    	}
    }

    function setPrecision($precision)
    {
    	$this->precision = (int) $precision;
    }

    function setBackgroundColor($color)
    {
    	$this->backgroundColor = strip_tags($color);
    }

    function setForegroundColor($color)
    {
    	$this->foregroundColor = strip_tags($color);
    }

    function getStep($length=null)
    {
    	if($length==null){
    		$length = $this->stepLength;
    	}
    	return sprintf($this->stepElement,$length,$this->foregroundColor);
    }
}
?>