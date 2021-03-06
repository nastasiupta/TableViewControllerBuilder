//
//  AnyTableViewModelDelegate.swift
//  Copyright © 2017 Dolfn. All rights reserved.
//

import Foundation

public struct AnyTableViewModelDelegate<H, R>: TableViewModelDelegate {

    public typealias HeaderDisplayDataType = H
    public typealias CellDisplayDataType = R
    
    private var didLoadInitialData: (AnyTableViewModel<H, R>) -> Void
    private var didUpdate: ([IndexPath], AnyTableViewModel<H, R>) -> Void
    private var didReplace: ([IndexPath], AnyTableViewModel<H, R>, Bool) -> Void
    private var didRemove: ([IndexPath], AnyTableViewModel<H, R>, Bool) -> Void
    private var didInsertSections: ([Int], AnyTableViewModel<H, R>, Bool) -> Void
    private var didRemoveSections: ([Int], AnyTableViewModel<H, R>, Bool) -> Void
    private var didUpdateSection: (Int, AnyTableViewModel<H, R>, Bool) -> Void
    private var didUpdateHeights: (AnyTableViewModel<H, R>) -> Void
    private var didInsert: ([IndexPath], AnyTableViewModel<H, R>, Bool) -> Void
    private var scrollTo: (IndexPath, Bool) -> Void
    
    init<D: TableViewModelDelegate>(delegate: D) where D.HeaderDisplayDataType == H, D.CellDisplayDataType == R {
        didLoadInitialData = delegate.didLoadInitialData
        didUpdate = delegate.didUpdate
        didReplace = delegate.didReplace
        didRemove = delegate.didRemove
        didUpdateSection = delegate.didUpdateSection
        didInsertSections = delegate.didInsertSections
        didRemoveSections = delegate.didRemoveSections
        didUpdateHeights = delegate.didUpdateHeights
        didInsert = delegate.didInsert
        scrollTo = delegate.scrollTo
    }
    
    public func didLoadInitialData(in tableViewModel: AnyTableViewModel<H, R>) {
        didLoadInitialData(tableViewModel)
    }

    public func didUpdateHeights(in tableViewModel: AnyTableViewModel<H, R>) {
        didUpdateHeights(tableViewModel)
    }
    
    public func didInsert(itemsAt indexPaths: [IndexPath], in tableViewModel: AnyTableViewModel<H, R>, animated: Bool) {
        didInsert(indexPaths, tableViewModel, animated)
    }

    public func didReplace(itemsAt indexPaths: [IndexPath], in tableViewModel: AnyTableViewModel<H, R>, animated: Bool) {
        didReplace(indexPaths, tableViewModel, animated)
    }
    
    public func didUpdate(itemsAt indexPaths: [IndexPath], in tableViewModel: AnyTableViewModel<H, R>) {
        didUpdate(indexPaths, tableViewModel)
    }
    
    public func didRemove(itemsFrom indexPaths: [IndexPath], in tableViewModel: AnyTableViewModel<H, R>, animated: Bool) {
        didRemove(indexPaths, tableViewModel, animated)
    }
    
    public func didInsertSections(at indexes: [Int], in tableViewModel: AnyTableViewModel<H, R>, animated: Bool) {
        didInsertSections(indexes, tableViewModel, animated)
    }

    public func didUpdateSection(at index: Int, in tableViewModel: AnyTableViewModel<H, R>, animated: Bool) {
        didUpdateSection(index, tableViewModel, animated)
    }

    public func didRemoveSections(at indexes: [Int], in tableViewModel: AnyTableViewModel<H, R>, animated: Bool) {
        didRemoveSections(indexes, tableViewModel, animated)
    }
    
    public func scrollTo(indexPath: IndexPath, animated: Bool) {
        scrollTo(indexPath, animated)
    }
    
}
