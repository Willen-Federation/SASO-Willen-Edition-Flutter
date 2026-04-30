// Stub header for mobile_scanner 6.x ObjC compatibility.
// mobile_scanner 6.x is pure Swift and removed MobileScannerPlugin.h.
// GeneratedPluginRegistrant.m falls back to @import mobile_scanner which
// fails with Clang's module system in static-framework mode.
// This stub header makes __has_include return true; it imports the
// Swift-generated ObjC bridge via the framework header path (no module
// system required) so MobileScannerPlugin is declared for ObjC callers.
#if __has_include(<mobile_scanner/mobile_scanner-Swift.h>)
#import <mobile_scanner/mobile_scanner-Swift.h>
#endif
