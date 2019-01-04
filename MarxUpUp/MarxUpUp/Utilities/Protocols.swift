//
//  Protocols.swift
//  MarxUpUp
//
//  Created by Ognyanka Boneva on 15.11.18.
//  Copyright © 2018 Ognyanka Boneva. All rights reserved.
//

import UIKit
import CoreData

protocol ToolboxItemDelegate: AnyObject {
    func didChoose(textAnnotationFromType type: ToolboxItemType)
    func didChoosePen()
    func didChoose(_ option: Int, forToolboxItem type: ToolboxItemType)
    func didChoose(lineWidth width: Float)
    func didChooseColor(_ color: UIColor)
}

protocol ToolbarButtonsDelegate: AnyObject {
    func didSelectAnnotate()
    func didSelectSave()
    func didSelectReset()
    func didSelectToolbox()
}

protocol EditedContentStateDelegate: AnyObject {
    func didSelectUndo()
    func didSelectRedo()
}

protocol UpdateDatabaseDelegate: AnyObject {
    func updatePDF(withData data: Data)
    func updateImage(withData data: Data)
}

protocol DrawDelegate: AnyObject {
    func willBeginDrawing()
}

protocol LocalContentManaging: ContentLoading, ContentSaving, ContentUpdating {}

protocol ContentLoading {
    func loadPDFs() -> [LocalContentModel]
    func loadImages() -> [LocalContentModel]
}

protocol ContentSaving {
    func saveImageWithData(_ data: Data)
    func savePDFWithData(_ data: Data)
}

protocol ContentUpdating {
    func updatePDF(_ id: URL, withData data: Data)
    func updateImage(_ id: URL, withData data: Data)
}

protocol CameraInterface: AnyObject {
    func switchPosition()
    func stop()
    func takePhoto()
    func updateOrientation(forView view: UIView)
    var isSupportedByTheDevice: Bool { get }
}
