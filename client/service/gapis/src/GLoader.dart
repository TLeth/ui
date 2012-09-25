//Copyright (C) 2012 Potix Corporation. All Rights Reserved.
//History: Wed, Jun 20, 2012  10:30:28 AM
// Author: hernichen

/**
 * Bridge Dart to Google JavaScript APIs loader; see https://developers.google.com/loader/ for details.
 */
class GLoader {
  //private JS operation
  static const String _GLOADER_READY = "gload.1";
  static const String _IP_LOCATION = "gload.2";
  static const String _LOAD_MODULE = "gload.3";
  
  static const String _BASE_URI = "https://www.google.com/jsapi";
  
  //module names
  static const String MAPS = "maps";
  static const String SEARCH = "search";
  static const String FEED = "feeds";
  static const String EARTH = "earth";
  static const String VISUALIZATION = "visualization";
  static const String ORKUT = "orkut";
  static const String PICKER = "picker";
  
  static LoadableModule _loaderModule;
  static final Map<String, double> _ipLatLng = JSUtil.toDartMap(JSUtil.jsCall(_IP_LOCATION));

  /** Load Google JavaScript API module; see <https://developers.google.com/loader/#GoogleLoad> for details.
   * + [name] the module name
   * + [version] the module version
   * + [options] the options used in loading the module; can specify a *callback* function when module loaded. 
   */
  static void load(String name, String version, [Map options]) {
    _initGLoader();
    _loaderModule.doWhenLoaded(()=>_load(name, version, options));
  }
  
  /** Load latitude/longitude of the calling client via callback function [onSuccess]. Note that this service sometimes
   * return null value.
   * + [onSuccess] callback function if successfully get the latitude/longitude.
   */
  static void loadIPLatLng(LatLngSuccessCallback onSuccess) {
    _initGLoader();
    _loaderModule.doWhenLoaded(() => onSuccess(_ipLatLng['lat'], _ipLatLng['lng']));
  }
  
  static _initGLoader() {
    if (_loaderModule == null)
      _loaderModule = new LoadableModule(_loadModule);
  }
  
  static void _loadModule(Function readyFn) {
    _initJSFunctions();
    
    JSUtil.injectJavaScriptSrc(_BASE_URI);
    JSUtil.doWhenReady(readyFn, ()=>JSUtil.jsCall(_GLOADER_READY), 
      (int msec) {if(msec == 0) print("Fail to load jsapi.js!");}, 10, 180000); //check every 10 ms, wait total 180 seconds
  }
  
  static void _load(String name, String version, [Map options]) {
    JSUtil.jsCall(_LOAD_MODULE, [name, version, JSUtil.toJSMap(options, (k,v) => k == "callback" ? JSUtil.toJSFunction(v, 0) : v)]);
  }
  
  static void _initJSFunctions() {
    JSUtil.newJSFunction(_GLOADER_READY, null, "return !!window.google && !!window.google.load;");
    JSUtil.newJSFunction(_IP_LOCATION, null,''' 
      var loc = {};
      if (window.google.loader.ClientLocation) {
        loc.lat = window.google.loader.ClientLocation.latitude;
        loc.lng = window.google.loader.ClientLocation.longitude;
      }
      return loc;
    ''');
    JSUtil.newJSFunction(_LOAD_MODULE, ["name", "version", "options"], 
      "window.google.load(name, version, options);");
  }
}

typedef LatLngSuccessCallback(double lat, double lng);
