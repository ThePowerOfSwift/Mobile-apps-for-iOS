//
//  Constants.h
//  MarxUp
//
//  Created by Ognyanka Boneva on 26.09.18.
//  Copyright © 2018 Ognyanka Boneva. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

#define IDENTIFIER_TOOLBOX_ITEM_OPTIONS_CELL   @"ToolboxItemOptionsCell"
#define IDENTIFIER_DOCUMENT_PREVIEW_CELL       @"DocumentPreviewCell"
#define IDENTIFIER_IMAGE_PREVIEW_CELL          @"ImagePreviewCell"
#define IDENTIFIER_TABS_CELL                   @"TabsCell"

#define ID_VIEW_CONTROLLER                     @"RootViewControllerID"
#define ID_LINE_WIDTH_VIEW_CONTROLLER          @"LineWidthViewControllerID"
#define ID_COLOR_PICKER_VIEW_CONTROLLER        @"ColorPickerViewControllerID"
#define ID_TOOLBOX_ITEM_VIEW_CONTROLLER        @"ToolboxItemViewControllerID"
#define ID_DOCUMENT_PREVIEW_VIEW_CONTROLLER    @"DocumentPreviewTableViewControllerID"
#define ID_IMAGE_PREVIEW_VIEW_CONTROLLER       @"ImagePreviewTableViewControllerID"
#define ID_SINGLE_DOCUMENT_VIEW_CONTROLLER     @"SingleDocumentViewControllerID"
#define ID_SINGLE_IMAGE_VIEW_CONTROLLER        @"SingleImageViewControllerID"
#define ID_TOOLBAR_VIEW_CONTROLLER             @"ToolbarViewControllerID"

typedef enum : NSInteger {
    ToolboxItemTypeColor = 1,
    ToolboxItemTypeShape,
    ToolboxItemTypePen,
    ToolboxItemTypeArrow,
    ToolboxItemTypeWidth,
    ToolboxItemTypeTextUnderline,
    ToolboxItemTypeTextHighlight,
    ToolboxItemTypeTextStrikeThrough,
    ToolboxItemTypeUndo,
    ToolboxItemTypeRedo,
} ToolboxItemType;

typedef enum : NSUInteger {
    ShapeTypeCircle = 1,
    ShapeTypeRoundedRectangle,
    ShapeTypeRegularRectangle,
} ShapeType;

typedef enum : NSUInteger {
    ArrowEndLineTypeClosed,
    ArrowEndLineTypeOpen,
} ArrowEndLineType;

typedef enum : NSUInteger {
    ImagesSortViral,
    ImagesSortTop,
    ImagesSortDate,
} ImagesSort;

typedef enum : NSUInteger {
    ContentTypePDF,
    ContentTypeImage,
} ContentType;

typedef enum : NSUInteger {
    EnumCameraFront,
    EnumCameraBack,
} EnumCamera;

#endif /* Constants_h */
