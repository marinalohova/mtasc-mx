// Copyright © 2004-2007. Adobe Systems Incorporated. All Rights Reserved.

import mx.utils.Delegate;
import mx.video.*;

/**
 * <p>Handles downloading and parsing SMIL xml format for
 * mx.video.NCManager.</p>
 *
 * <p>NCManager supports a subset of SMIL to handle multiple streams
 * for multiple bandwidths.  NCManager assumes any URL that does not
 * being with "rtmp://" and does not end with ".flv" is a SMIL url.
 *
 * <p>SMIL looks like this:</p>
 *
 * <pre>
 * &lt;smil&gt;
 *     &lt;head&gt;
 *         &lt;meta base="rtmp://myserver/mypgm/" /&gt;
 *         &lt;layout&gt;
 *             &lt;root-layout width="240" height="180" /&gt;
 *         &lt;/layout&gt;
 *     &lt;/head&gt;
 *     &lt;body&gt;
 *         &lt;switch&gt;
 *             &lt;ref src="myvideo_cable.flv" system-bitrate="128000" dur="3:00.1"/&gt;
 *             &lt;video src="myvideo_isdn.flv" system-bitrate="56000" dur="3:00.1"/&gt;
 *             &lt;video src="myvideo_mdm.flv" dur="3:00.1"/&gt;
 *         &lt;/switch&gt;
 *     &lt;/body&gt;
 * &lt;/smil&gt;
 * </pre>
 *
 * <p>The meta tag's base attribute has the URL for the FCS
 * server. The video tags give the stream names and the minimum
 * bandwidth required. The ref tag is synonomous with the video
 * tag.</p>
 *
 * <p>A similar format can be used for progressive http download
 * without using bandwidth detection.</p>
 *
 * <pre>
 * &lt;smil&gt;
 *     &lt;head&gt;
 *         &lt;layout&gt;
 *             &lt;root-layout width="240" height="180" /&gt;
 *         &lt;/layout&gt;
 *     &lt;/head&gt;
 *     &lt;body&gt;
 *         &lt;video src="http://myserver/myvideo.flv" dur="3:00.1"/&gt;
 *     &lt;/body&gt;
 * &lt;/smil&gt;
 * </pre>
 * 
 * Precise subset of SMIL supported
 *
 * <ul>
 *     <li>smil tag - top level tag</li>
 *     <ul>
 *         <li>head tag</li>
 *         <ul>
 *             <li>meta tag</li>
 *             <ul>
 *                 <li>Only base attribute supported</li>
 *                 <li>Two instances are supported for FCS.  First is primary server, second is backup.</li>
 *             </ul>
 *             <li>layout tag</li>
 *             <ul>
 *                 <li>Only first instance is used, rest ignored.</li>
 *                 <li>root-layout tag</li>
 *                 <ul>
 *                     <li>Only width and height attributes supported.</li>
 *                     <li>Width and height only supported in absolute pixel values.</li>
 *                 </ul>
 *             </ul>
 *         </ul>
 *         <li>body tag</li>
 *         <ul>
 *             <li>Only one tag allowed in body (either switch, video or ref)</li>
 *             <li>switch tag supported</li>
 *             <li>video tag supported</li>
 *             <ul>
 *                  <li>At top level and within switch tag.</li>
 *                  <li>Only src, system-bitrate and dur attributes supported.</li>
 *                  <li>system-bitrate attribute only supported within switch tag.</li>
 *                  <li>dur attribute we only support full clock format (e.g. 00:03:00.1) and partial clock format (e.g. 03:00.1).</li>
 *             </ul>
 *             <li>ref tag - synonym for video tag</li>
 *         </ul>
 *     </ul>
 * </ul>
 */

/*
 * XML examples from above without xml entitiy substitution:
 *
 * <smil>
 *     <head>
 *         <meta base="rtmp://myserver/mypgm/" />
 *         <layout>
 *             <root-layout width="240" height="180" />
 *         </layout>
 *     </head>
 *     <body>
 *         <switch>
 *             <ref src="myvideo_cable.flv" system-bitrate="128000" dur="3:00.1"/>
 *             <video src="myvideo_isdn.flv" system-bitrate="56000" dur="3:00.1"/>
 *             <video src="myvideo_mdm.flv" dur="3:00.1"/>
 *         </switch>
 *     </body>
 * </smil>
 *
 * <smil>
 *     <head>
 *         <layout>
 *             <root-layout width="240" height="180" />
 *         </layout>
 *     </head>
 *     <body>
 *         <video src="http://myserver/myvideo.flv" dur="3:00.1"/>
 *     </body>
 *
 * Precise subset of SMIL supported (more readable format):
 *
 * * smil tag - top level tag
 *     o head tag
 *         + meta tag
 *             # Only base attribute supported
 *             * Two instances are supported for FCS.  First is primary server, second is backup.
 *         + layout tag
 *             # Only first instance is used, rest ignored.
 *             # root-layout tag
 *                 * Only width and height attributes supported.
 *                 * Width and height only supported in absolute pixel values .
 *     o body tag
 *         + Only one tag allowed in body (either switch, video or ref)
 *         + switch tag supported
 *         + video tag supported
 *              # At top level and within switch tag.
 *              # Only src, system-bitrate and dur attributes supported.
 *              # system-bitrate attribute only supported within switch tag.
 *              # dur attribute we only support full clock format (e.g. 00:03:00.1) and partial clock format (e.g. 03:00.1).
 *         + ref tag - synonym for video tag
 *
 */

class mx.video.SMILManager {

	#include "ComponentVersion.as"

	// INCManager to ping when done
	private var _owner:INCManager;

	// smil support
	public var xml:XML;
	public var baseURLAttr:Array;
	public var width:Number;
	public var height:Number;
	public var videoTags:Array;

	private var _url:String;

	private static var ELEMENT_NODE:Number = 1;

	/**
	 * constructor
	 */
	public function SMILManager(owner:INCManager) {
		_owner = owner;
	} 

	/**
	 * <p>Starts download of XML file.  Will be parsed and based
	 * on that we will decide how to connect.</p>
	 *
	 * @private
	 */
	public function connectXML(url:String):Boolean {
		_url = fixURL(url);
		xml = new XML();
		xml.onLoad = Delegate.create(this, this.xmlOnLoad);
		xml.load(_url);
		return false;
	}

	/**
	 * <p>Append version parameter to URL.</p>
	 *
	 * @private
	 */
	private function fixURL(origURL:String):String {
		if ( origURL.substr(0, 5).toLowerCase() == "http:" ||
		     origURL.substr(0, 6).toLowerCase() == "https:" ) {
			var sep:String = (origURL.indexOf("?") >= 0) ? "&" : "?";
			return origURL + sep + "FLVPlaybackVersion=" + shortVersion;
		}
		return origURL;
	}

	/**
	 * <p>Handles load of XML.
	 *
	 * @private
	 */
	private function xmlOnLoad(success:Boolean):Void {
		try {
			if (!success) {
				// signal failure
				_owner.helperDone(this, false);
			} else {
				baseURLAttr = new Array();
				videoTags = new Array();
				var parentNode:XMLNode = xml.firstChild;
				var foundNode:Boolean = false;
				while (parentNode != null) {
					if (parentNode.nodeType == ELEMENT_NODE) {
						foundNode = true;
						if (parentNode.nodeName.toLowerCase() == "smil") break;
					}
					parentNode = parentNode.nextSibling;
				}
				if (!foundNode) {
					throw new VideoError(VideoError.INVALID_XML, "URL: \"" + _url + "\" No root node found; if url is for an flv it must have .flv extension and take no parameters");
				} else if (parentNode == null) {
					throw new VideoError(VideoError.INVALID_XML, "URL: \"" + _url + "\" Root node not smil");
				}
				var foundBody:Boolean = false;
				for (var i:Number = 0; i < parentNode.childNodes.length; i++) {
					var node:XMLNode = parentNode.childNodes[i];
					if (node.nodeType != ELEMENT_NODE) continue;
					if (node.nodeName.toLowerCase() == "head") {
						parseHead(node);
					} else if (node.nodeName.toLowerCase() == "body") {
						foundBody = true;
						parseBody(node);
					} else {
						throw new VideoError(VideoError.INVALID_XML, "URL: \"" + _url + "\" Tag " + node.nodeName + " not supported in " + parentNode.nodeName + " tag.");
					}
				}
				if (!foundBody) {
					throw new VideoError(VideoError.INVALID_XML, "URL: \"" + _url + "\" Tag body is required.");
				}
				_owner.helperDone(this, true);
			}
		} catch (err:Error) {
			_owner.helperDone(this, false);
			throw err;
		}
	}

	/**
	 * parse head node of smil
	 *
	 * @private
	 */
	private function parseHead(parentNode:XMLNode):Void {
		var gotLayout:Boolean = false;
		for (var i:Number = 0; i < parentNode.childNodes.length; i++) {
			var node:XMLNode = parentNode.childNodes[i];
			if (node.nodeType != ELEMENT_NODE) continue;
			if (node.nodeName.toLowerCase() == "meta") {
				for (var attr:String in node.attributes) {
					if (attr.toLowerCase() == "base") {
						baseURLAttr.push(node.attributes[attr]);
					} else {
						throw new VideoError(VideoError.INVALID_XML, "URL: \"" + _url + "\" Attribute " + attr + " not supported in " + node.nodeName + " tag.");
					}
				}
			} else if (node.nodeName.toLowerCase() == "layout") {
				if (!gotLayout) {
					parseLayout(node);
					gotLayout = true;
				} else {
					//ifdef DEBUG
					//throw new VideoError(VideoError.INVALID_XML, "URL: \"" + _url + "\" Multiple " + node.nodeName + " tags in " + parentNode.nodeName + " tag.");
					//endif
				}
			} else {
				//ifdef DEBUG
				//throw new VideoError(VideoError.INVALID_XML, "URL: \"" + _url + "\" Tag " + node.nodeName + " not supported in " + parentNode.nodeName + " tag.");
				//endif
			}
		}
	}

	/**
	 * parse layout node of smil
	 *
	 * @private
	 */
	private function parseLayout(parentNode:XMLNode):Void {
		for (var i:Number = 0; i < parentNode.childNodes.length; i++) {
			var node:XMLNode = parentNode.childNodes[i];
			if (node.nodeType != ELEMENT_NODE) continue;
			if (node.nodeName.toLowerCase() == "root-layout") {
				for (var attr:String in node.attributes) {
					if (attr.toLowerCase() == "width") {
						width = Number(node.attributes[attr]);
					} else if (attr.toLowerCase() == "height") {
						height = Number(node.attributes[attr]);
					} else {
						//ifdef DEBUG
						//throw new VideoError(VideoError.INVALID_XML, "URL: \"" + _url + "\" Attribute " + attr + " not supported in " + node.nodeName + " tag.");
						//endif
					}
				}
				if ( isNaN(width) || width < 0 || isNaN(height) || height < 0 ) {
					throw new VideoError(VideoError.INVALID_XML, "URL: \"" + _url + "\" Tag " + node.nodeName + " requires attributes id, width and height.  Width and height must be numbers greater than or equal to 0.");
				}
				width = Math.round(width);
				height = Math.round(height);
				return;
			} else {
				//ifdef DEBUG
				//throw new VideoError(VideoError.INVALID_XML, "URL: \"" + _url + "\" Tag " + node.nodeName + " not supported in " + parentNode.nodeName + " tag.");
				//endif
			}
		}
	}

	/**
	 * parse body node of smil
	 *
	 * @private
	 */
	private function parseBody(parentNode:XMLNode):Void {
		var tagCount:Number = 0;
		for (var i:Number = 0; i < parentNode.childNodes.length; i++) {
			var node:XMLNode = parentNode.childNodes[i];
			if (node.nodeType != ELEMENT_NODE) continue;
			if (++tagCount > 1) {
				throw new VideoError(VideoError.INVALID_XML, "URL: \"" + _url + "\" Tag " + parentNode.nodeName + " is required to contain exactly one tag.");
			}
			if (node.nodeName.toLowerCase() == "switch") {
				parseSwitch(node);
			} else if (node.nodeName.toLowerCase() == "video" || node.nodeName.toLowerCase() == "ref") {
				var videoObj:Object = parseVideo(node);
				videoTags.push(videoObj);
			} else {
				//ifdef DEBUG
				//throw new VideoError(VideoError.INVALID_XML, "URL: \"" + _url + "\" Tag " + node.nodeName + " not supported in " + parentNode.nodeName + " tag.");
				//endif
			}
		}
		if (videoTags.length < 1) {
			throw new VideoError(VideoError.INVALID_XML, "URL: \"" + _url + "\" At least one video of ref tag is required.");
		}
	}

	/**
	 * parse switch node of smil
	 *
	 * @private
	 */
	private function parseSwitch(parentNode:XMLNode):Void {
		for (var i:Number = 0; i < parentNode.childNodes.length; i++) {
			var node:XMLNode = parentNode.childNodes[i]
			if (node.nodeType != ELEMENT_NODE) continue;
			if (node.nodeName.toLowerCase() == "video" || node.nodeName.toLowerCase() == "ref") {
				videoTags.push(parseVideo(node));
			} else {
				//ifdef DEBUG
				//throw new VideoError(VideoError.INVALID_XML, "URL: \"" + _url + "\" Tag " + node.nodeName + " not supported in " + parentNode.nodeName + " tag.");
				//endif
			}
		}
	}

	/**
	 * parse video or ref node of smil.  Returns object with
	 * attribute info.
	 *
	 * @private
	 */
	private function parseVideo(node:XMLNode):Object {
		var obj:Object = new Object();
		for (var attr:String in node.attributes) {
			if (attr.toLowerCase() == "src") {
				obj.src = node.attributes[attr];
			} else if (attr.toLowerCase() == "system-bitrate") {
				obj.bitrate = Number(node.attributes[attr]);
			} else if (attr.toLowerCase() == "dur") {
				obj.dur = parseTime(node.attributes[attr]);
			} else {
				//ifdef DEBUG
				//throw new VideoError(VideoError.INVALID_XML, "URL: \"" + _url + "\" Attribute " + attr + " not supported in " + node.nodeName + " tag.");
				//endif
			}
		}
		if (obj.src == undefined) {
			throw new VideoError(VideoError.INVALID_XML, "URL: \"" + _url + "\" Attribute src is required in " + node.nodeName + " tag.");
		}
		return obj;
	}

	/**
	 * parse time in hh:mm:ss.s or mm:ss.s format.
	 * Also accepts a bare number of seconds with
	 * no colons.  Returns a number of seconds.
	 *
	 * @private
	 */
	private function parseTime(timeStr:String):Number {
		var t:Number = 0;
		var s:Array = timeStr.split(":");
		if (s.length < 1 || s.length > 3) {
			throw new VideoError(VideoError.INVALID_XML, "Invalid dur value: " + timeStr);
		}
		for (var i:Number = 0; i < s.length; i++) {
			var j:Number = Number(s[i]);
			if (isNaN(j)) {
				throw new VideoError(VideoError.INVALID_XML, "Invalid dur value: " + timeStr);
			}
			t *= 60;
			t += j;
		}
		return t;
	}

}
