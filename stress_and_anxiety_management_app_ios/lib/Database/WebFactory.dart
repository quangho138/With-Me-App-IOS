// The browser has no filesystem for sqflite to open a file on, so the web
// build swaps in the WebAssembly engine. Phones never import it.
export 'WebFactoryStub.dart'
    if (dart.library.js_interop) 'WebFactoryWeb.dart';
