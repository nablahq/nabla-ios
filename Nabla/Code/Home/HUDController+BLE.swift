//
//  HUDController+BLE.swift
//  ble-tbt-navigation-ios
//
//  Created by Jaksa Tomovic on 23.08.2023..
//

import UIKit
import Bluejay

extension HUDController {
    
    public func sendCommand(command: InstructionCommand) {
        let command = encoder.buildInstructionCommand(instruction: command)
        
        currentData.append(command)
        
        if currentData != lastData {
            writeCharacteristic(data: currentData)
        }
        
        lastData = currentData
        currentData = Data()
    }

    
    func writeCharacteristic(data: Data) {
        
        let heartRateService = ServiceIdentifier(uuid: BLECostants.uuidService)
        let sensorLocation = CharacteristicIdentifier(uuid: BLECostants.uuidCharForWrite, service: heartRateService)

        bluejay.write(to: sensorLocation, value: data) { result in
            switch result {
            case .success:
                debugPrint("Write to sensor location is successful.")
            case .failure(let error):
                debugPrint("Failed to write sensor location with error: \(error.localizedDescription)")
            }
        }
    }
}


