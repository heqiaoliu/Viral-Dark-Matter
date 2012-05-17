/* Copyright 2006 The MathWorks, Inc. */

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

//******************************************************************
//**** Wrappers for methods called in Stateflow action language ****
//******************************************************************

adder *createAdder()
{
	return new adder;
}

void deleteAdder(adder *obj)
{
	delete obj;
}

double adderOutput(adder *obj, int increment)
{
	obj->add_one(increment);
	return obj->get_val();
}
