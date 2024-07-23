//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

class Instructor {
    init(
        maxRunningCount: Int = 2,
        previousInstruction: Instructor.Instruction? = nil,
        runningCount: Int = 0,
        onLog: ((_ message: String) -> Void)? = nil
    ) {
        self.maxRunningCount = maxRunningCount
        self.previousInstruction = previousInstruction
        self.runningCount = runningCount
        self.onLog = onLog
    }

    enum Instruction: Equatable {
        case `match`
        case tooFarLeft(
            text: String = "Move head right",
            nearnessPercentage: Double
        )
        case tooFarRight(
            text: String = "Move head left",
            nearnessPercentage: Double
        )
        case tooClose(
            text: String = "Move head farther.",
            nearnessPercentage: Double
        )
        case tooFar(
            text: String = "Move head closer.",
            nearnessPercentage: Double
        )
        case none

        static func == (lhs: Instruction, rhs: Instruction) -> Bool {
            switch (lhs, rhs) {
            case (.match, .match): return true
            case (.tooFarLeft, .tooFarLeft): return true
            case (.tooFarRight, .tooFarRight): return true
            case (.tooClose, .tooClose): return true
            case (.tooFar, .tooFar): return true
            default: return false
            }
        }
    }

    var previousInstruction: Instruction?
    var runningCount = 0
    var maxRunningCount = 2
    var onLog: ((_ message: String) -> Void)?

    func instruction(for update: Instruction) -> Instruction {
        onLog?("""
            Instruction update state: \(update)
            Instruction previous state: \(String(describing: previousInstruction))
            runningCount: \(runningCount)
            maxRunningCount: \(maxRunningCount)
        """)
        if previousInstruction == update {
            runningCount += 1
            if runningCount >= maxRunningCount {
                onLog?("running count completed")
                return update
            }
            onLog?("running count continue")
            return .none
        } else {
            onLog?("running count reset")
            previousInstruction = update
            runningCount = 0
        }
        return .none
    }
}
