//
//  OZLFormSection.swift
//  Facets
//
//  Created by Justin Hill on 3/13/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

class OZLFormSection: NSObject {

    var title: String?
    var fields: [OZLFormField]

    init(title: String?, fields: [OZLFormField]) {
        self.title = title
        self.fields = fields

        super.init()
    }
}
