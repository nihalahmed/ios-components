//
//  CellObjectSectionInfo.swift
//  CellObject
//
//  Created by Nihal on 2017-05-06.
//  Copyright © 2017 Wattpad Corp. All rights reserved.
//

import Foundation
import TLIndexPathTools

/// Subclass which allows for configuring of the layout of a section.
public class CellObjectSectionInfo: TLIndexPathSectionInfo {
    
    /// The minimum line spacing for the section.
    open var minimumLineSpacing: CGFloat? = nil
    
    /// The minimum interitem spacing for the section.
    open var minimumInteritemSpacing: CGFloat? = nil
    
    /// The inset for the section.
    open var inset: UIEdgeInsets? = nil
    
}
