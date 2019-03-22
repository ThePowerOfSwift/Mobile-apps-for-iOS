//
//  ChangesManager.swift
//  MarxUpUp
//
//  Created by Ognyanka Boneva on 29.11.18.
//  Copyright © 2018 Ognyanka Boneva. All rights reserved.
//

import UIKit
import PDFKit

class ChangesManager: NSObject {

    private var undoCommands = [Command]()
    private var redoCommands = [Command]()

    var unsavedWork: Bool {
        return !undoCommands.isEmpty
    }

    func redo(withCompletionHandler handler: () -> Void) {
        guard !redoCommands.isEmpty, let command = redoCommands.popLast() else {
            return
        }

        command.execute()
        undoCommands.append(command)
        handler()
    }

    func undo(withCompletionHandler handler: () -> Void) {
        guard !undoCommands.isEmpty, let command = undoCommands.popLast() else {
            return
        }

        command.unexecute()
        redoCommands.append(command)
        handler()
    }

    func addInkImageAnnotation(withLines lines: UIBezierPath, forImage image: UIImage, andFill fill: Bool) {
        let change = ImageInkAnnotation(withLines: lines, forImage: image, andFill: fill)
        undoCommands.append(change)
    }

    func addInkPDFAnnotation(_ annotation: PDFAnnotation, forPage page: PDFPage) {
        let change = PDFInkAnnotation(annotation, forPDFPage: page)
        undoCommands.append(change)
    }

    func addTextAnnotation(_ annotation: [PDFAnnotation], forPage page: PDFPage) {
        let change = TextAnnotation(annotation, forPage: page)
        undoCommands.append(change)
    }

    func reset() {
        undoCommands.reversed().forEach({ $0.unexecute() })
        clear()
    }

    func clear() {
        undoCommands.removeAll()
        redoCommands.removeAll()
    }
}
