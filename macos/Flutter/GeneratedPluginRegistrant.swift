//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import hotkey_manager
import macos_ui
import screen_retriever
import sqflite
import wakelock_macos
import window_manager

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  HotkeyManagerPlugin.register(with: registry.registrar(forPlugin: "HotkeyManagerPlugin"))
  MacOSUiPlugin.register(with: registry.registrar(forPlugin: "MacOSUiPlugin"))
  ScreenRetrieverPlugin.register(with: registry.registrar(forPlugin: "ScreenRetrieverPlugin"))
  SqflitePlugin.register(with: registry.registrar(forPlugin: "SqflitePlugin"))
  WakelockMacosPlugin.register(with: registry.registrar(forPlugin: "WakelockMacosPlugin"))
  WindowManagerPlugin.register(with: registry.registrar(forPlugin: "WindowManagerPlugin"))
}
