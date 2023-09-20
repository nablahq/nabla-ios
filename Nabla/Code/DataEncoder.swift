import Foundation

class DataEncoder {
    
    func buildInstructionCommand(instruction: InstructionCommand) -> Data {
        return instruction.data
    }
}
