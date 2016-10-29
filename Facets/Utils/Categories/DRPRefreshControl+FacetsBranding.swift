//
//  DRPRefreshControl+FacetsBranding.swift
//  Facets
//
//  Created by Justin Hill on 10/29/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

import DRPLoadingSpinner

extension DRPRefreshControl {
    class func facetsBranded() -> DRPRefreshControl {
        let refresh = DRPRefreshControl()
        refresh.loadingSpinner.lineWidth = 2
        refresh.loadingSpinner.colorSequence = [UIColor.lightGrayColor()]
        
        return refresh
    }
}
