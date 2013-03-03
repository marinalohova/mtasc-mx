//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

class mx.lang.Locale {
	private static var flaName:String;
	private static var defaultLang:String;
	private static var xmlLang:String = System.capabilities.language;
	private static var xmlMap:Object = new Object();
	private static var xmlDoc:XML;
	private static var stringMap:Object = new Object();
	private static var delayedInstanceArray:Array = new Array();
	private static var currentXMLMapIndex:Number = -1;
	private static var callback:Function;

	// new in Flash 8
	private static var autoReplacment:Boolean = true;			// should we assign text automatically after loading xml?
	private static var currentLang:String;						// the current language of stringMap
	private static var stringMapList:Object = new Object();		// the list of stringMap objects, used for caching

	/******************************************
	* Accessors
	******************************************/
	// return the status of whether we should replace the strings automatically after loading the xml
	static function get autoReplace():Boolean {
		return autoReplacment;
	}

	// set the status of whether we should replace the strings automatically after loading the xml
	// set to false by Flash if the text replacement method is "via ActionScript at runtime"
	static function set autoReplace(auto:Boolean):Void {
		autoReplacment = auto;
	}

	// return an array of language codes
	static function get languageCodeArray():Array {
		var langCodeArray:Array = new Array;
		for(var i:String in xmlMap) {
			if(i != undefined) {
				langCodeArray.push(i);
			}
		}

		return langCodeArray;
	}

	// return an array of string IDs
	static function get stringIDArray():Array {
		var strIDArray:Array = new Array;
		for(var i:String in stringMap) {
			if(i != "") {
				strIDArray.push(i);
			}
		}

		return strIDArray;
	}

	/******************************************
	 * public methods
	 ******************************************/

	static function setFlaName(name:String):Void {
		flaName = name;
	}

	// Return the default language code.
	static function getDefaultLang():String {
		return defaultLang;
	}

	// Set the default language code.
	static function setDefaultLang(langCode:String):Void {
		defaultLang = langCode;
	}

	// Add the {languageCode and languagePath} pair into the internal array for later use.
	// This is primarily used by  Flash when the strings replacement method is "automatically at runtime"
	// or "via ActionScript at runtime". 
	static function addXMLPath(langCode:String, path:String):Void {
		if(xmlMap[langCode] == undefined) {
			xmlMap[langCode] = new Array();
		}
		
		xmlMap[langCode].push(path);
	}


	// Add the {instance, string ID} pair into the internal array for later use.
	// This is primarily used by Flash when the strings replacement method is "automatically at runtime". 
	static function addDelayedInstance(instance:Object, stringID:String) {
		delayedInstanceArray.push({inst : instance, strID : stringID});
		var len:Number = delayedInstanceArray.length;
	}

	// Return true if the xml is loaded, false otherwise. 
	static function checkXMLStatus():Boolean {
		var stat:Boolean = xmlDoc.loaded && xmlDoc.status == 0;
		return stat;
	}

	// Set the callback function that will be called after the xml file is loaded.
	static function setLoadCallback(loadCallback:Function) {
		callback = loadCallback;
	}

	// Return the string value associated with the given string id in the current language.
	static function loadString(id:String):String {
		return stringMap[id];
	}

	// Return the string value associated with the given string id and language code.
	// To avoid unexpected xml loading, this call will not load the language xml if it has not been loaded.
	// You should decide on the right time to call loadLanguageXML manually if you want to load a language xml.
	public static function loadStringEx(stringID:String, languageCode:String):String {
		var tmpMap:Object = stringMapList[languageCode];
		if (tmpMap != undefined) {
			return tmpMap[stringID];
		} else {
			return "";
		}
	}

	// Set the new string value of a given string ID and language code.
	public static function setString(stringID:String, languageCode:String, stringValue:String):Void {
		var tmpMap:Object = stringMapList[languageCode];
		if (tmpMap != undefined) {
			tmpMap[stringID] = stringValue;
		} else {
			// the map doesn't exist, possibly haven't loaded the language xml file yet, but we store the string anyway
			tmpMap = new Object();
			tmpMap[stringID] = stringValue;
			stringMapList[languageCode] = tmpMap;
		}
	}

	// Determine the language to use and begin xml loading.
	// This is primarily used by Flash when the strings replacement method is "automatically at runtime".
	static function initialize():Void {
		xmlDoc = new XML();
		xmlDoc.ignoreWhite = true;
		xmlDoc.onLoad = function(success:Boolean) {
			onXMLLoad(success); // parse the XML
			callback.call(null, success);
		}
		
		var langCode:String = xmlLang;
		if(xmlMap[xmlLang] == undefined) {
			langCode = defaultLang;
		}

		currentXMLMapIndex = 0;
		xmlDoc.load(xmlMap[langCode][0]);
	}

	// Load the specified language xml file.
	static function loadLanguageXML(xmlLanguageCode:String, customXmlCompleteCallback:Function):Void {
		// if xmlLang is not defined, set to SystemCapabilities.language
		var langCode:String = (xmlLanguageCode == "") ? System.capabilities.language : xmlLanguageCode;
		if(xmlMap[langCode] == undefined) {
			// if the specified language is not defined, set to default language
			langCode = defaultLang;
		}

		if (customXmlCompleteCallback) {
			callback = customXmlCompleteCallback;
		}

		if (stringMapList[xmlLanguageCode] == undefined) {
			// if the xml has not been loaded before, load it
			if (xmlDoc)
				delete xmlDoc;

			xmlDoc = new XML();
			xmlDoc.ignoreWhite = true;
			xmlDoc.onLoad = function(success:Boolean) {
				onXMLLoad(success); // parse the XML
				callback.call(null, success);
			}
			xmlDoc.load(xmlMap[langCode][0]);
		} else {
			// the xml is already loaded, retrieve it from the list
			stringMap = stringMapList[langCode]

			// call the callback here because onLoad is not called here
			if (callback)
				callback.call(null, true);
		}
		currentLang = langCode;
	}

	/******************************************
	 * private methods
	 ******************************************/
	
	private static function onXMLLoad(success:Boolean) {
		if(success == true) {
			// reset the string map
			delete stringMap;
			stringMap = new Object();

			parseStringsXML(xmlDoc);

			// store the string map in the list for caching
			if (stringMapList[currentLang] == undefined) {
				stringMapList[currentLang] = stringMap;
			}

			if (autoReplacment) {
				assignDelayedInstances();
			}
		}
	}

	private static function parseStringsXML(doc:XML):Void {
		if(doc.childNodes.length > 0 && doc.childNodes[0].nodeName == "xliff") {
			parseXLiff(doc.childNodes[0]);
		}
	}

	private static function parseXLiff(node:XMLNode):Void {
		if(node.childNodes.length > 0 && node.childNodes[0].nodeName == "file") {
			parseFile(node.childNodes[0]);
		}
	}

	private static function parseFile(node:XMLNode):Void {
		if(node.childNodes.length > 1 && node.childNodes[1].nodeName == "body") {
			parseBody(node.childNodes[1]);
		}
	}

	private static function parseBody(node:XMLNode):Void {
		for(var i:Number = 0; i < node.childNodes.length; i++) {
			if(node.childNodes[i].nodeName == "trans-unit") {
				parseTransUnit(node.childNodes[i]);
			}
		}
	}

	private static function parseTransUnit(node:XMLNode):Void {
		var id:String = node.attributes.resname;
		if(id.length > 0 && node.childNodes.length > 0 &&
				node.childNodes[0].nodeName == "source") {
			var value:String = parseSource(node.childNodes[0]);
			if(value.length > 0) {
				stringMap[id] = value;
			}
		}
	}

	// return the string value of the source node
	private static function parseSource(node:XMLNode):String {
		if(node.childNodes.length > 0) {
			return node.childNodes[0].nodeValue;
		}

		return "";
	}

	private static function assignDelayedInstances():Void {
		for(var i:Number = 0; i < delayedInstanceArray.length; i++) {
			if(delayedInstanceArray[i] != undefined) {
				var instance:Object = delayedInstanceArray[i].inst;
				var stringID:String = delayedInstanceArray[i].strID;
				instance.text = loadString(stringID);
			}
		}

	}
}
