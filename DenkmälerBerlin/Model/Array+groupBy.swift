//
//  Array+groupBy.swift
//  DenkmälerBerlin
//
//  Created by Pascal Weiß on 12.12.15.
//  Copyright © 2015 HTWBerlin. All rights reserved.
//

import UIKit
public extension SequenceType {
    
    /// Categorises elements of self into a dictionary, with the keys given by keyFunc
    
    func groupBy<U : Hashable>(@noescape keyFunc: Generator.Element -> U) -> [U:[Generator.Element]] {
        var dict: [U:[Generator.Element]] = [:]
        for el in self {
            let key = keyFunc(el)
            dict[key]?.append(el) ?? {dict[key] = [el]}()
        }
        return dict
    }
}