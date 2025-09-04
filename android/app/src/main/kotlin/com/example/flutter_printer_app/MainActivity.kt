package com.example.flutter_printer_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channel = "com.example.flutter_printer_app/printer"
    private lateinit var printerService: PrinterService

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        printerService = PrinterService(applicationContext)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            when (call.method) {
                "getPairedBluetoothDevices" -> {
                    val devices = printerService.getPairedBluetoothDevices()
                    result.success(devices)
                }
                "connectBluetoothPrinter" -> {
                    val address = call.argument<String>("address")
                    if (address != null) {
                        result.success(printerService.connectBluetoothPrinter(address))
                    } else {
                        result.error("INVALID_ARGUMENT", "Address required", null)
                    }
                }
                "connectUsbPrinter" -> {
                    result.success(printerService.connectUsbPrinter())
                }
                "printText" -> {
                    val text = call.argument<String>("text")
                    if (text != null) {
                        result.success(printerService.printText(text))
                    } else {
                        result.error("INVALID_ARGUMENT", "Text required", null)
                    }
                }
                "closeConnection" -> {
                    printerService.closeConnection()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }
}
