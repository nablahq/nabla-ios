import Foundation
import Bluejay

struct InstructionCommand {
    var instruction: String
    
    init(maneuver: String, junctionDistance: String, speedLimit: Int, eta: Int, progress: Double, totalDistance: String, image: String) {
        self.instruction = "\(maneuver)|\(junctionDistance)|\(speedLimit)|\(eta)|\(progress)|\(totalDistance)|\(image)"
    }
    
    var data: Data {
        let instruction = self.instruction
        let data = instruction.data(using: .utf8) // non-nil
        return data!
    }
}

struct NablaDeviceResponse {
    var info: String
    
    init(from data: Data) throws {
        if let string = String(data: data, encoding: .utf8) {
            info = string
        } else {
            print("not a valid UTF-8 sequence")
            info = ""
        }
    }
}

struct HeartRateMeasurement: Receivable {

    var info: String

    init(bluetoothData: Data) throws {
        if let string = String(data: bluetoothData, encoding: .utf8) {
            info = string
        } else {
            print("not a valid UTF-8 sequence")
            info = ""
        }
    }

}

// swiftlint:disable all
func getImageNumber(img: String) -> Int {
    
    let image = img
    
    switch(image) {
    case "direction_arrive":
        return 1;
    case "direction_notificaiton_right":
        return 2;
    case "direction_arrive_left":
        return 3;
    case "direction_notificaiton_sharp_right":
        return 4;
    case "direction_arrive_right":
        return 5;
    case "direction_notification_left":
        return 6;
    case "direction_arrive_straight":
        return 7;
    case "direction_notification_sharp_left":
        return 8;
    case "direction_close":
        return 9;
    case "direction_notification_slight_left":
        return 10;
    case "direction_continue":
        return 11;
    case "direction_notification_slight_right":
        return 12;
    case "direction_continue_left":
        return 13;
    case "direction_notification_straight":
        return 14;
    case "direction_continue_right":
        return 15;
    case "direction_off_ramp_left":
        return 16;
    case "direction_continue_slight_left":
        return 17;
    case "direction_off_ramp_right":
        return 18;
    case "direction_continue_slight_right":
        return 19;
    case "direction_off_ramp_slight_left":
        return 20;
    case "direction_off_ramp_slight_right":
        return 21;
    case "direction_continue_uturn":
        return 22;
    case "direction_on_ramp_left":
        return 23;
    case "direction_depart":
        return 24;
    case "direction_on_ramp_right":
        return 25;
    case "direction_depart_left":
        return 26;
    case "direction_on_ramp_sharp_left":
        return 27;
    case "direction_depart_right":
        return 28;
    case "direction_on_ramp_sharp_right":
        return 29;
    case "direction_depart_straight":
        return 30;
    case "direction_on_ramp_slight_left":
        return 31;
    case "direction_end_of_road_left":
        return 32;
    case "direction_on_ramp_slight_right":
        return 33;
    case "direction_end_of_road_right":
        return 34;
    case "direction_on_ramp_straight":
        return 35;
    case "direction_flag":
        return 36;
    case "direction_rotary":
        return 37;
    case "direction_fork":
        return 38;
    case "direction_rotary_left":
        return 39;
    case "direction_fork_left":
        return 40;
    case "direction_fork_right":
        return 41;
    case "direction_rotary_sharp_left":
        return 42;
    case "direction_fork_slight_left":
        return 43;
    case "direction_rotary_sharp_right":
        return 44;
    case "direction_fork_slight_right":
        return 45;
    case "direction_rotary_slight_left":
        return 46;
    case "direction_fork_straight":
        return 47;
    case "direction_rotary_slight_right":
        return 48;
    case "direction_invalid":
        return 49;
    case "direction_rotary_straight":
        return 50;
    case "direction_invalid_left":
        return 51;
    case "direction_roundabout":
        return 52;
    case "direction_invalid_right":
        return 53;
    case "direction_roundabout_left":
        return 54;
    case "direction_invalid_slight_left":
        return 55;
    case "direction_roundabout_right":
        return 56;
    case "direction_invalid_slight_right":
        return 57;
    case "direction_roundabout_sharp_left":
        return 58;
    case "direction_invalid_straight":
        return 59;
    case "direction_roundabout_sharp_right":
        return 60;
    case "direction_invalid_uturn":
        return 61;
    case "direction_roundabout_slight_left":
        return 62;
    case "direction_merge_left":
        return 63;
    case "direction_roundabout_slight_right":
        return 64;
    case "direction_merge_right":
        return 65;
    case "direction_roundabout_straight":
        return 66;
    case "direction_merge_slight_left":
        return 67;
    case "direction_turn_left":
        return 68;
    case "direction_merge_slight_right":
        return 69;
    case "direction_turn_right":
        return 70;
    case "direction_merge_straight":
        return 71;
    case "direction_turn_sharp_left":
        return 72;
    case "direction_new_name_left":
        return 73;
    case "direction_turn_sharp_right":
        return 74;
    case "direction_new_name_right":
        return 75;
    case "direction_turn_slight_left":
        return 76;
    case "direction_new_name_sharp_left":
        return 77;
    case "direction_turn_slight_right":
        return 78;
    case "direction_new_name_sharp_right":
        return 79;
    case "direction_turn_straight":
        return 80;
    case "direction_new_name_slight_left":
        return 81;
    case "direction_updown":
        return 82;
    case "direction_new_name_slight_right":
        return 83;
    case "direction_uturn":
        return 84;
    case "direction_new_name_straight":
        return 85;
    default:
        return 0;
    }
}
// swiftlint:enable all
