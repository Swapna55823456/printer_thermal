package com.example.flutter_printer_app

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothSocket
import android.content.Context
import android.hardware.usb.*
import java.io.IOException
import java.io.OutputStream
import java.util.*

class PrinterService(private val context: Context) {
    private val bluetoothAdapter: BluetoothAdapter? by lazy {
        val manager = context.getSystemService(Context.BLUETOOTH_SERVICE) as? android.bluetooth.BluetoothManager
        manager?.adapter
    }

    private var bluetoothSocket: BluetoothSocket? = null
    private var usbConnection: UsbDeviceConnection? = null
    private var usbEndpoint: UsbEndpoint? = null
    private var outputStream: OutputStream? = null

    /** 🔹 Get Paired Bluetooth Devices */
    fun getPairedBluetoothDevices(): List<Map<String, String>> {
        val devices = mutableListOf<Map<String, String>>()

        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.S) {
            val hasPermission = context.checkSelfPermission(
                android.Manifest.permission.BLUETOOTH_CONNECT
            ) == android.content.pm.PackageManager.PERMISSION_GRANTED

            if (!hasPermission) {
                return devices
            }
        }

        bluetoothAdapter?.bondedDevices?.forEach { device ->
            devices.add(
                mapOf(
                    "name" to (device.name ?: "Unknown"),
                    "address" to device.address
                )
            )
        }
        return devices
    }


    /** 🔹 Bluetooth */
    fun connectBluetoothPrinter(address: String): Boolean {
        if (bluetoothAdapter == null || bluetoothAdapter?.isEnabled != true) return false
        val device: BluetoothDevice = bluetoothAdapter!!.getRemoteDevice(address) ?: return false

        return try {
            val uuid = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB")
            bluetoothSocket = device.createRfcommSocketToServiceRecord(uuid)
            bluetoothSocket?.connect()
            outputStream = bluetoothSocket?.outputStream
            true
        } catch (e: IOException) {
            e.printStackTrace()
            closeConnection()
            false
        }
    }

    /** 🔹 USB */
    fun connectUsbPrinter(): Boolean {
        val usbManager = context.getSystemService(Context.USB_SERVICE) as UsbManager
        val deviceList: HashMap<String, UsbDevice> = usbManager.deviceList
        if (deviceList.isEmpty()) return false

        val device = deviceList.values.first()
        val interface0 = device.getInterface(0)
        usbEndpoint = interface0.getEndpoint(0)
        usbConnection = usbManager.openDevice(device)

        return usbConnection != null
    }

    /** 🔹 Print */
    fun printText(text: String): Boolean {
        return try {
            when {
                outputStream != null -> {
                    outputStream?.write(text.toByteArray())
                    outputStream?.write(byteArrayOf(0x0A))
                    true
                }
                usbConnection != null && usbEndpoint != null -> {
                    usbConnection!!.bulkTransfer(
                        usbEndpoint, text.toByteArray(), text.length, 1000
                    ) >= 0
                }
                else -> false
            }
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    /** 🔹 Close */
    fun closeConnection() {
        try {
            outputStream?.close()
            bluetoothSocket?.close()
            usbConnection?.close()
        } catch (e: IOException) {
            e.printStackTrace()
        }
    }
}
