//
//  AppDelegate.swift
//  Cocoa Bluetooth RFCOMM Swift
//
//  Created by Worker PC on 2/8/15.
//  Copyright (c) 2015 Garvin Casimir. All rights reserved.
//

import Cocoa
import IOBluetooth
import IOBluetoothUI


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, IOBluetoothRFCOMMChannelDelegate {

    var mRFCOMMChannel : IOBluetoothRFCOMMChannel? = nil ;
    
    @IBOutlet weak var window: NSWindow!
 
    @IBOutlet var textView: NSTextView!
    
    @IBOutlet var txtvw: NSTextView!
    
    @IBAction func discover(sender:AnyObject){
        
        let deviceSelector = IOBluetoothDeviceSelectorController.deviceSelector()
        let sppServiceUUID = IOBluetoothSDPUUID.uuid32(kBluetoothSDPUUID16ServiceClassSerialPort.rawValue)
       
        
        if ( deviceSelector == nil ) {
            self.log("Error - unable to allocate IOBluetoothDeviceSelectorController.\n" )
            return;
        }
        
        deviceSelector.addAllowedUUID(sppServiceUUID)

        if ( deviceSelector.runModal()  !=  Int32(kIOBluetoothUISuccess) ) {
            self.log("User has cancelled the device selection.\n")
            return;
        }
        
        let deviceArray = deviceSelector.getResults();
        
        if ( ( deviceArray == nil ) || ( deviceArray.count == 0 ) ) {
            self.log("Error - no selected device.  ***This should never happen.***\n")
            return;
        }
        
        let device: IOBluetoothDevice = deviceArray[0] as! IOBluetoothDevice;
        
        let sppServiceRecord = device.getServiceRecordForUUID(sppServiceUUID)
        
        //device.getservi
        if ( sppServiceRecord == nil ) {
            self.log("Error - no spp service in selected device.  ***This should never happen since the selector forces the user to select only devices with spp.***\n")
            return;
        }
        
        let rfcommChannelID: UnsafeMutablePointer<BluetoothRFCOMMChannelID> = UnsafeMutablePointer.alloc(1)
        
        if (sppServiceRecord.getRFCOMMChannelID(rfcommChannelID) != kIOReturnSuccess ) {
            self.log("Error - no spp service in selected device.  ***This should never happen an spp service must have an rfcomm channel id.***\n")
            return;
        }
  
        
        if ( device.openRFCOMMChannelAsync(&mRFCOMMChannel, withChannelID: rfcommChannelID.memory, delegate: self) != kIOReturnSuccess    ) {
            // Something went bad (looking at the error codes I can also say what, but for the moment let's not dwell on
            // those details). If the device connection is left open close it and return an error:
            self.log("Error - open sequence failed.***\n")
           
            return;
        }
        
        


        
    }
    
    func log(text:String?){
      
        if (text != nil) {
          textView.textStorage!.mutableString.appendString(text!)
        }
        else {
          textView.textStorage!.mutableString.appendString("Empty message??")
        }
        
       
        
    }
    
    @IBAction func clearText(sender:AnyObject){
        textView.textStorage!.mutableString.setString("")
    }
    
    
    @IBAction func hello(sender:AnyObject){
        let myString = "I am doing ok Android. Thanks for asking";
        
        self.sendMessage(myString)
    }
    
    func sendMessage(message:String){
        let data = message.dataUsingEncoding(NSUTF8StringEncoding)
        let length = data!.length
        let dataPointer = UnsafeMutablePointer<Void>.alloc(1)
        
        data?.getBytes(dataPointer,length: length)
        
        self.log("Sending Message\n")
        mRFCOMMChannel?.writeSync(dataPointer, length: UInt16(length))
    }
    

    func rfcommChannelOpenComplete(rfcommChannel: IOBluetoothRFCOMMChannel!, status error: IOReturn) {
        if(error != kIOReturnSuccess){
            self.log("Error - Failed to open the RFCOMM channel");
        }
        else {
            self.log("Connected");
        }
    }
    
    func rfcommChannelData(rfcommChannel: IOBluetoothRFCOMMChannel!, data dataPointer: UnsafeMutablePointer<Void>, length dataLength: Int) {
        let message = String(bytesNoCopy: dataPointer, length: Int(dataLength), encoding: NSUTF8StringEncoding, freeWhenDone: false)
        
        self.log(message);
    }
    


    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    


}

