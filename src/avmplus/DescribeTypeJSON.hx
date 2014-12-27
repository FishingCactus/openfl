/*
 * Copyright (c) 2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package avmplus;

/**
 * Makes the hidden, inofficial function describeTypeJSON available outside of the avmplus
 * package.
 *
 * <strong>As Adobe doen't officially support this method and it is only visible to client
 * code by accident, it should only ever be used with runtime-detection and automatic fallback
 * on describeType.</strong>
 *
 * @see http://www.tillschneidereit.de/2009/11/22/improved-reflection-support-in-flash-player-10-1/
 */
class DescribeTypeJSON
{
	// FIX
	//----------------------              Public Properties             ----------------------//
	//public static var available:Bool = describeTypeJSON != null;
	public static var available:Bool = false;
	
	/*public static var INSTANCE_FLAGS:UInt = INCLUDE_BASES | INCLUDE_INTERFACES
		| INCLUDE_VARIABLES | INCLUDE_ACCESSORS | INCLUDE_METHODS | INCLUDE_METADATA
		| INCLUDE_CONSTRUCTOR | INCLUDE_TRAITS | USE_ITRAITS | HIDE_OBJECT;
	public static var CLASS_FLAGS:UInt = INCLUDE_INTERFACES | INCLUDE_VARIABLES
		| INCLUDE_ACCESSORS | INCLUDE_METHODS | INCLUDE_METADATA | INCLUDE_TRAITS | HIDE_OBJECT;*/


	//----------------------               Public Methods               ----------------------//
	public function new()
	{
		
	}
	
	//public function describeType(target:Dynamic, flags:UInt):Dynamic
	//{
		//var describeTypeJSONClass = untyped __global__["avmplus.describeTypeJSON"];
		//describeTypeJSON
		//describeType
		//var describeTypeJSON:Dynamic = Type.createInstance(describeTypeJSONClass, []);
		//var func:Dynamic->Dynamic->Dynamic = describeTypeJSON.describeType;
		//return null;//describeTypeJSON(target, flags);
	//}

	public function getInstanceDescription(type:Class<Dynamic>):Dynamic
	{
		// FIX
		return null;//describeTypeJSON(type, INSTANCE_FLAGS);
	}

	//public function getClassDescription(type:Class<Dynamic>):Dynamic
	//{
		//return null;//describeTypeJSON(type, CLASS_FLAGS);
	//}
}