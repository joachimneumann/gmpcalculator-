//
//  CalculatorCommands.swift
//  CalculatorCommands
//
//  Created by Joachim Neumann on 10/9/21.
//

import SwiftUI

struct CalculatorCommands: Commands {
    @ObservedObject var brain: Brain
    
    private let keyInputSubject = KeyInputSubjectWrapper()
    
    var body: some Commands {
        CommandMenu("Edit ") {
            /// the extra space after "Edit" prevents MacOS to add 'Start Dictation'
            /// and 'Special Characters' to the Edit menu
            CopyCommand(brain: brain)
            PasteCommand(brain: brain)
            SpaceCommand(brain: brain)
        }
        CommandMenu("Precision") {
            LowPrecision(brain: brain)
            MediumPrecision(brain: brain)
            HighPrecision(brain: brain)
        }
    }
}

struct SpaceCommand: View {
    @ObservedObject var brain: Brain
    var body: some View {
        Button {
            withAnimation(.easeIn) {
                brain.zoomed.toggle()
                if !brain.zoomed {
                    brain.scrollViewTarget = 1
                }
            }
        } label: {
            Text("Toggle Zoom")
        }
        .keyboardShortcut(.space, modifiers: .none)
    }
}

extension CalculatorCommands {
    func keyInput(_ key: KeyEquivalent, modifiers: EventModifiers = .none) -> some View {
        keyboardShortcut(key, sender: keyInputSubject, modifiers: modifiers)
    }
}


struct LowPrecision: View {
    @ObservedObject var brain: Brain
    var body: some View {
        Button {
            brain.precision = TE.lowPrecision
        } label: {
            Text(((brain.precision == TE.lowPrecision) ? "✓ " : "    ") + TE.lowPrecisionString)
        }
        .keyboardShortcut("1", modifiers: [.command])
    }
}

struct MediumPrecision: View {
    @ObservedObject var brain: Brain
    var body: some View {
        Button {
            brain.precision = TE.mediumPrecision
        } label: {
            Text(((brain.precision == TE.mediumPrecision) ? "✓ " : "    ") + TE.mediumPrecisionString)
        }
        .keyboardShortcut("2", modifiers: [.command])
    }
}

struct HighPrecision: View {
    @ObservedObject var brain: Brain
    var body: some View {
        Button {
            brain.precision = TE.highPrecision
        } label: {
            Text(((brain.precision == TE.highPrecision) ? "✓ " : "    ") + TE.highPrecisionString)
        }
        .keyboardShortcut("3", modifiers: [.command])
    }
}

struct CopyCommand: View {
    @ObservedObject var brain: Brain
    var body: some View {
        Button {
            UIPasteboard.general.string = brain.longDisplayString
        } label: {
            Text("Copy")
        }
        .keyboardShortcut("C", modifiers: [.command])
    }
}

struct PasteCommand: View {
    var brain: Brain
    var body: some View {
        Button {
            brain.asyncOperation("fromPasteboard")
        } label: {
            Text("Paste")
        }
        .keyboardShortcut("V", modifiers: [.command])
        .disabled(!UIPasteboard.general.hasStrings)
    }
}
