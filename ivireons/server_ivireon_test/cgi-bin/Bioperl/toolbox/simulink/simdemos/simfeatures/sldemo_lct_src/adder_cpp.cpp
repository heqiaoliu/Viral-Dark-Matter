/* Copyright 2006 The MathWorks, Inc. */

/* $Revision: 1.1.6.1 $ */

#include "adder_cpp.h"

/***************************************/
/**** Class instance global storage ****/
/***************************************/

adder *adderVar;

/**********************************/
/**** Class method definitions ****/
/**********************************/

adder::adder()
{
	int_state = 0;
}

int adder::add_one(int increment)
{
	int_state += increment;
    return int_state;
}

int adder::get_val()
{
	return int_state;
}

//*************************************************
//**** Wrappers for methods called in Simulink ****
//*************************************************

void createAdder()
{
	adderVar = new adder;
}

void deleteAdder()
{
	delete adderVar;
}

int adderOutput(int increment)
{
	adderVar->add_one(increment);
	return adderVar->get_val();
}
