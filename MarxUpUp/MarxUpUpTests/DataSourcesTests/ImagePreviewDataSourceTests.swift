//
//  ImagePreviewDataSourceTests.swift
//  MarxUpUpTests
//
//  Created by Ognyanka Boneva on 21.12.18.
//  Copyright © 2018 Ognyanka Boneva. All rights reserved.
//

import XCTest
@testable import MarxUpUp

class ImagePreviewDataSourceTests: XCTestCase {
    
    let dataFilter = DataFilter(local: false, sort: .Viral)
    let requester = ImageDataRequester(withSession: MockNetworkSession(), andParser: MockParserImages())
    let DBManager = MockDatabaseManagerImages()
    let cache = NSCache<NSString, UIImage>()
    let testImage = UIImage(named: "test-image")
    
    let table = UITableView.init(frame: CGRect.zero)
    var dataSource: ImagePreviewTableViewDataSource!

    override func setUp() {
        super.setUp()
        dataSource = ImagePreviewTableViewDataSource(withImagesFilteredBy: dataFilter, requester, cache, DBManager)
    }

    override func tearDown() {
        dataSource = nil
        super.tearDown()
    }

    func testImagesCount() {
        dataSource.loadData(withFilter: dataFilter) { (_) in }
        XCTAssertEqual(dataSource.imagesCount, 3)
    }

    func testGetImageFromCache() {
        guard let image = testImage else {
            XCTFail("Error: No test image available")
            return
        }
        cache.setObject(image, forKey: "link")
        dataSource.loadData(withFilter: dataFilter) { (_) in }
        XCTAssertEqual(dataSource.getImage(atIndex: 0).pngData(), image.pngData())
    }

    func testNumberOfSections() {
        XCTAssertEqual(dataSource.numberOfSections(in: table), 1)
    }

    func testNumberOfRowsInSection() {
        XCTAssertEqual(dataSource.tableView(table, numberOfRowsInSection: 0), 0)
        dataSource.loadData(withFilter: dataFilter) { (_) in}
        XCTAssertEqual(dataSource.tableView(table, numberOfRowsInSection: 0), 3)
    }
    
    func testUpdateImageWithLocalDataSource() {
        let filter = DataFilter(local: true, sort: .None)
        dataSource = ImagePreviewTableViewDataSource(withImagesFilteredBy: filter, requester, cache, DBManager)
        dataSource.selectedModelIndexForUpdate = 0
        
        dataSource.updateImage(withData: Data())
        
        XCTAssertTrue(DBManager.updateImageIsCalled)
    }
    
    func testUpdateImageWithNonLocalDataSource() {
        dataSource.updateImage(withData: Data())
        
        XCTAssertTrue(DBManager.saveImageIsCalled)
    }
    
    func testAddLocalData() {
        let filter = DataFilter(local: true, sort: .None)
        dataSource = ImagePreviewTableViewDataSource(withImagesFilteredBy: filter, requester, cache, DBManager)
        
        dataSource.addData { (dataCount) in
            XCTAssertNil(dataCount)
        }
    }
    
    func testAddNonLocalData() {
        let initialImagesCount = dataSource.imagesCount
        
        dataSource.addData { (dataCount) in
            XCTAssertEqual(self.dataSource.imagesCount, initialImagesCount + 3)
        }
    }
    
    func testLoadData() {
        dataSource.loadData(withFilter: dataFilter) { (dataCount) in
            XCTAssertEqual(self.dataSource.imagesCount , dataCount)
        }
    }
    
    func testRefreshData() {
        dataSource.loadData(withFilter: dataFilter) { _ in }
        
        dataSource.refreshData { (dataCount) in
            XCTAssertEqual(self.dataSource.imagesCount , dataCount)
        }
    }
    
}

class MockParserImages: NSObject, Parsable {
    var handlerIsCalled = false

    func linksFromJSONDict(_ dictionary: [String : AnyObject], countPerPage count: Int, andCompletion handler: ([String]) -> Void) {
        let links = ["link", "sdfgsfdg", "link"]
        handler(links)
        handlerIsCalled = true
    }

}

class MockDatabaseManagerImages: NSObject, LocalContentManaging {
    
    var updateImageIsCalled = false
    var saveImageIsCalled = false
    
    func loadPDFs() -> [LocalContentModel] {
        return [LocalContentModel]()
    }
    
    func loadImages() -> [LocalContentModel] {
        guard let id = URL(string: "zxcv") else {
            return [LocalContentModel]()
        }
        let image = LocalContentModel("asdf".data(using: .ascii) ?? Data(), id)
        return [image]
    }
    
    func saveImageWithData(_ data: Data) {
        saveImageIsCalled = true
    }
    
    func savePDFWithData(_ data: Data) {}
    
    func updatePDF(_ id: URL, withData data: Data) {}
    
    func updateImage(_ id: URL, withData data: Data) {
        updateImageIsCalled = true
    }
}
