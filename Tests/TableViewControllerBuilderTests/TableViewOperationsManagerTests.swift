//
//  TableViewOperationsManagerTests.swift
//  Copyright © 2018 Dolfn. All rights reserved.
//

import XCTest
@testable import TableViewControllerBuilder

class TableViewOperationsManagerTests: XCTestCase {

    var sut: TableViewOperationsManager<FakeHeaderDisplayData, FakeCellDisplayData>!
    var tableView: UITableViewSpy!
    var cellReconfiguratorSpy: CellReconfiguratorSpy!
    var anyViewModel: AnyTableViewModel<FakeHeaderDisplayData, FakeCellDisplayData>!
    var rowDataUpdatableSpy: CellDisplayDataUpdatableSpy!
    var rowHeightsDataUpdatableSpy: CellDisplayDataUpdatableSpy!
    var headerDataUpdatableSpy: HeaderDisplayDataUpdatableSpy!
    var newSection: SectionDataAlias!
    
    override func setUp() {
        super.setUp()
        cellReconfiguratorSpy = CellReconfiguratorSpy()
        sut = TableViewOperationsManager<FakeHeaderDisplayData, FakeCellDisplayData>(cellReconfigurator: cellReconfiguratorSpy)
        tableView = UITableViewSpy()
        sut.tableView = tableView
        
        rowDataUpdatableSpy = CellDisplayDataUpdatableSpy()
        let rowDataUpdatable = AnyCellDisplayDataUpdatable(updatable: rowDataUpdatableSpy)
        sut.rowDataUpdatable = rowDataUpdatable
        
        rowHeightsDataUpdatableSpy = CellDisplayDataUpdatableSpy()
        let rowHeightsDataUpdatable = AnyCellDisplayDataUpdatable(updatable: rowHeightsDataUpdatableSpy)
        sut.rowHeightsDataUpdatable = rowHeightsDataUpdatable
        
        headerDataUpdatableSpy = HeaderDisplayDataUpdatableSpy()
        let headerDataUpdatable = AnyHeaderDisplayDataUpdatable(updatable: headerDataUpdatableSpy)
        sut.headerDataUpdatable = headerDataUpdatable
        
        var viewModel = TableViewModelStub()
        newSection = getNewSection(headerHeight: 10, numberOfRows: 3, rowHeight: 15, estimatedRowHeight: 15)
        viewModel.sectionsDisplayData = [newSection]
        anyViewModel = AnyTableViewModel(tableViewModel: viewModel)
    }
    
    override func tearDown() {
        cellReconfiguratorSpy = nil
        sut = nil
        tableView = nil
        anyViewModel = nil
        rowDataUpdatableSpy = nil
        rowHeightsDataUpdatableSpy = nil
        headerDataUpdatableSpy = nil
        newSection = nil
        super.tearDown()
    }
    
    func test_GivenReconfigurator_IsRetainedWeak() {
        var cellReconfiguratorSpy: CellReconfigurator? = CellReconfiguratorSpy()
        sut = TableViewOperationsManager<FakeHeaderDisplayData, FakeCellDisplayData>(cellReconfigurator: cellReconfiguratorSpy!)
        weak var reference: CellReconfigurator? = cellReconfiguratorSpy
        cellReconfiguratorSpy = nil
        XCTAssertNil(reference)
    }
    
    func test_GivenTableView_IsRetainedWeak() {
        weak var reference: UITableViewSpy? = sut.tableView as? UITableViewSpy
        tableView = nil
        XCTAssertNil(reference)
    }
    
    func test_GivenUpdatables_AreRetainedStrong() {
        let cellReconfiguratorSpy: CellReconfigurator? = CellReconfiguratorSpy()
        sut = TableViewOperationsManager<FakeHeaderDisplayData, FakeCellDisplayData>(cellReconfigurator: cellReconfiguratorSpy!)

        let rowDataUpdatable = AnyCellDisplayDataUpdatable(updatable: CellDisplayDataUpdatableSpy())
        sut.rowDataUpdatable = rowDataUpdatable

        let rowHeightsDataUpdatable = AnyCellDisplayDataUpdatable(updatable: CellDisplayDataUpdatableSpy())
        sut.rowHeightsDataUpdatable = rowHeightsDataUpdatable

        let headerDataUpdatable = AnyHeaderDisplayDataUpdatable(updatable: HeaderDisplayDataUpdatableSpy())
        sut.headerDataUpdatable = headerDataUpdatable
        
        wait(for: 0.1)
        
        XCTAssertNotNil(rowDataUpdatable)
        XCTAssertNotNil(rowHeightsDataUpdatable)
        XCTAssertNotNil(headerDataUpdatable)
    }
    
    func test_SetupTableView_WithGivenInitialData() {
        XCTAssertEqual(tableView.reloadDataCounter, 0)
        sut.didLoadInitialData(in: anyViewModel)
        
        XCTAssertEqual(tableView.reloadDataCounter, 1)
        checkSectionsContent()
    }
    
    func test_UpdatingSectionsNotAnimated() {
        XCTAssertNil(tableView.animation)
        XCTAssertNil(tableView.sections)
        sut.didUpdateSection(at: 0, in: anyViewModel.erased, animated: false)
        XCTAssertEqual(tableView.animation, UITableViewRowAnimation.none)
        XCTAssertEqual(tableView.sections, IndexSet(integer: 0))
        checkSectionsContent()
    }
    
    func test_UpdatingSectionsAnimated() {
        XCTAssertNil(tableView.animation)
        XCTAssertNil(tableView.sections)
        sut.didUpdateSection(at: 0, in: anyViewModel.erased, animated: true)
        XCTAssertEqual(tableView.animation, UITableViewRowAnimation.automatic)
        XCTAssertEqual(tableView.sections, IndexSet(integer: 0))
        checkSectionsContent()
    }
    
    func test_RemoveRowsNotAnimatedForGivenIndexPaths() {
        XCTAssertNil(tableView.animation)
        sut.didRemove(itemsFrom: getIndexPaths(), in: anyViewModel.erased, animated: false)
        endRemoveRowsTest()
        XCTAssertEqual(tableView.animation, UITableViewRowAnimation.none)
    }
    
    func test_RemoveRowsAnimatedForGivenIndexPaths() {
        XCTAssertNil(tableView.animation)
        sut.didRemove(itemsFrom: getIndexPaths(), in: anyViewModel.erased, animated: true)
        endRemoveRowsTest()
        XCTAssertEqual(tableView.animation, UITableViewRowAnimation.automatic)
    }
    
    private func endRemoveRowsTest() {
        XCTAssertEqual(tableView.deleteRowsIndexPaths.count, 3)
        let indexPaths = getIndexPaths()
        XCTAssertTrue(tableView.deleteRowsIndexPaths.contains(indexPaths[0]))
        XCTAssertTrue(tableView.deleteRowsIndexPaths.contains(indexPaths[1]))
        XCTAssertTrue(tableView.deleteRowsIndexPaths.contains(indexPaths[2]))
        checkSectionsContent()
    }
    
    func test_UpdateIndexPathsAndGivenDataForGivenTableView() {
        let indexPaths = getIndexPaths()
        sut.didUpdate(itemsAt: indexPaths, in: anyViewModel.erased)
        checkSectionsContent()
        XCTAssertEqual(cellReconfiguratorSpy.tableView, tableView)
        XCTAssertTrue(cellReconfiguratorSpy.receivedIndexPaths.contains(indexPaths[0]))
        XCTAssertTrue(cellReconfiguratorSpy.receivedIndexPaths.contains(indexPaths[1]))
        XCTAssertTrue(cellReconfiguratorSpy.receivedIndexPaths.contains(indexPaths[2]))
    }
    
    func test_UpdateIndexPathsAndGivenDataWithoutTableView() {
        let indexPaths = getIndexPaths()
        sut.tableView = nil
        sut.didUpdate(itemsAt: indexPaths, in: anyViewModel.erased)
        checkSectionsContent()
        XCTAssertNil(cellReconfiguratorSpy.tableView)
        XCTAssertEqual(cellReconfiguratorSpy.receivedIndexPaths.count, 0)
    }
    
    func test_ReplaceIndexPathsNotAnimatedAndGivenData() {
        sut.didReplace(itemsAt: getIndexPaths(), in: anyViewModel.erased, animated: false)
        endReplaceRowsTest()
        XCTAssertEqual(tableView.animation, UITableViewRowAnimation.none)
    }
    
    func test_ReplaceIndexPathsAnimatedAndGivenData() {
        sut.didReplace(itemsAt: getIndexPaths(), in: anyViewModel.erased, animated: true)
        endReplaceRowsTest()
        XCTAssertEqual(tableView.animation, UITableViewRowAnimation.automatic)
    }
    
    private func endReplaceRowsTest() {
        let indexPaths = getIndexPaths()
        XCTAssertEqual(tableView.reloadRowsIndexPaths.count, 3)
        XCTAssertTrue(tableView.reloadRowsIndexPaths.contains(indexPaths[0]))
        XCTAssertTrue(tableView.reloadRowsIndexPaths.contains(indexPaths[1]))
        XCTAssertTrue(tableView.reloadRowsIndexPaths.contains(indexPaths[2]))
        checkSectionsContent()
    }
    
    func test_InsertSectionsAnimatedAndGivenData() {
        sut.didInsertSections(at: [3, 4, 5], in: anyViewModel.erased, animated: true)
        
        checkSectionsContent()
        endInsertSections()
        XCTAssertEqual(tableView.animation, UITableViewRowAnimation.automatic)
    }
    
    func test_InsertSectionsNotAnimatedAndGivenData() {
        sut.didInsertSections(at: [3, 4, 5], in: anyViewModel.erased, animated: false)
        
        checkSectionsContent()
        endInsertSections()
        XCTAssertEqual(tableView.animation, UITableViewRowAnimation.none)
    }
    
    func endInsertSections() {
        guard let sections = tableView.insertedSections else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sections.count, 3)
        XCTAssertTrue(sections.contains(3))
        XCTAssertTrue(sections.contains(4))
        XCTAssertTrue(sections.contains(5))
    }
    
    func test_RemoveSectionsAnimatedAndGivenData() {
        sut.didRemoveSections(at: [3, 10, 11], in: anyViewModel.erased, animated: true)
        
        checkSectionsContent()
        endRemoveSections()
        XCTAssertEqual(tableView.animation, UITableViewRowAnimation.automatic)
    }
    
    func test_RemoveSectionsNotAnimatedAndGivenData() {
        sut.didRemoveSections(at: [3, 10, 11], in: anyViewModel.erased, animated: false)
        
        checkSectionsContent()
        endRemoveSections()
        XCTAssertEqual(tableView.animation, UITableViewRowAnimation.none)
    }
    
    func endRemoveSections() {
        guard let sections = tableView.deletedSections else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sections.count, 3)
        XCTAssertTrue(sections.contains(3))
        XCTAssertTrue(sections.contains(10))
        XCTAssertTrue(sections.contains(11))
    }
    
    func test_updateGivenHeights() {
        XCTAssertFalse(tableView.beginUpdatesCalled)
        XCTAssertFalse(tableView.endUpdatesCalled)
        sut.didUpdateHeights(in: anyViewModel.erased)
        XCTAssertTrue(tableView.beginUpdatesCalled)
        XCTAssertTrue(tableView.endUpdatesCalled)
        checkSectionsContent()
    }
    
    func test_InsertGivenRowsAndDataAnimated() {
        sut.didInsert(itemsAt: getIndexPaths(), in: anyViewModel.erased, animated: true)
        XCTAssertEqual(tableView.animation, UITableViewRowAnimation.automatic)
        endInsertIndexPaths()
        checkSectionsContent()
    }
    
    func test_InsertGivenRowsAndDataNotAnimated() {
        sut.didInsert(itemsAt: getIndexPaths(), in: anyViewModel.erased, animated: false)
        XCTAssertEqual(tableView.animation, UITableViewRowAnimation.none)
        endInsertIndexPaths()
        checkSectionsContent()
    }
    
    private func endInsertIndexPaths() {
        let indexPaths = getIndexPaths()
        XCTAssertEqual(tableView.insertedRowsIndexPaths.count, 3)
        XCTAssertTrue(tableView.insertedRowsIndexPaths.contains(indexPaths[0]))
        XCTAssertTrue(tableView.insertedRowsIndexPaths.contains(indexPaths[1]))
        XCTAssertTrue(tableView.insertedRowsIndexPaths.contains(indexPaths[2]))
    }
    
    func test_scrollToGivenIndexPathAnimated() {
        let indexPath = IndexPath(row: 5, section: 5)
        sut.scrollTo(indexPath: indexPath, animated: true)
        XCTAssertEqual(tableView.animated, true)
        endScrollToGiven(indexPath: indexPath)
    }
    
    func test_scrollToGivenIndexPathNotAnimated() {
        let indexPath = IndexPath(row: 5, section: 5)
        sut.scrollTo(indexPath: indexPath, animated: false)
        XCTAssertEqual(tableView.animated, false)
        endScrollToGiven(indexPath: indexPath)
    }
    
    private func endScrollToGiven(indexPath: IndexPath) {
        XCTAssertEqual(tableView.scrollToIndexPath, indexPath)
        XCTAssertEqual(tableView.scrollPosition, UITableViewScrollPosition.bottom)
    }
    
    private func getIndexPaths() -> [IndexPath] {
        let indexPath1 = IndexPath(row: 0, section: 0)
        let indexPath2 = IndexPath(row: 2, section: 0)
        let indexPath3 = IndexPath(row: 1, section: 2)
        return [indexPath1, indexPath2, indexPath3]
    }
    
    private func checkSectionsContent() {
        XCTAssertTrue(compareEqual(cellsDisplayData: [newSection.sectionRowsData], with: rowDataUpdatableSpy.cellsDisplayData))
        XCTAssertTrue(compareEqual(cellsDisplayData: [newSection.sectionRowsData], with: rowHeightsDataUpdatableSpy.cellsDisplayData))
        XCTAssertTrue(compareEqual(headersDisplayData: [newSection.headerDisplayData], with: headerDataUpdatableSpy.headerDisplayData))
    }
    
    private func compareEqual(cellsDisplayData: [[FakeCellDisplayData]], with receivedCellsDisplayData: [[FakeCellDisplayData]]) -> Bool {
        if cellsDisplayData.count != receivedCellsDisplayData.count {
            return false
        }
        
        for index in 0 ..< cellsDisplayData.count {
            let firstHeader = cellsDisplayData[index]
            let firstReceivedHeader = receivedCellsDisplayData[index]
            
            if firstHeader.count != firstReceivedHeader.count {
                return false
            }
            
            for index2 in 0 ..< firstHeader.count {
                let firstHeaderData = firstHeader[index2]
                let firstReceivedHeaderData = firstReceivedHeader[index2]
                
                if firstHeaderData != firstReceivedHeaderData {
                    return false
                }
            }
        }
        
        return true
    }
    
    private func compareEqual(headersDisplayData: [FakeHeaderDisplayData?]?, with receivedHeadersDisplayData: [FakeHeaderDisplayData?]?) -> Bool {
        
        if headersDisplayData == nil && receivedHeadersDisplayData == nil {
            return true
        }
        
        guard let headersDisplayData = headersDisplayData, let receivedHeadersDisplayData = receivedHeadersDisplayData else {
            return false
        }
        
        if headersDisplayData.count != receivedHeadersDisplayData.count {
            return false
        }
        
        for index in 0 ..< headersDisplayData.count {
            let firstHeader = headersDisplayData[index]
            if let firstReceivedHeader = receivedHeadersDisplayData[index] {
                if firstHeader! != firstReceivedHeader {
                    return false
                }
            }
        }
        
        return true
    }
    
}
