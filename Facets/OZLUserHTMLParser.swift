//
//  OZLUserHTMLParser.swift
//  Facets
//
//  Created by Justin Hill on 1/28/17.
//  Copyright © 2017 Justin Hill. All rights reserved.
//

import RaptureXML_Frankly

extension OZLModelUser {
    public static let OZLUserHTMLParserErrorDomain = "UserHTMLParserErrorDomain"
    @objc public enum OZLUserHTMLParserErrorCode: Int {
        case XMLParsingError
    }
    
    @objc class func user(withUserPageHTML html: String) -> OZLModelUser? {
        let user = OZLModelUser()

        do {
            try user.parse(html: html)
            return user
        } catch {
            return nil
        }
    }

    fileprivate func parse(html: String) throws {
        guard let ele = RXMLElement(fromHTMLString: html, encoding: String.Encoding.utf8.rawValue) else {
            throw NSError(domain: OZLModelUser.OZLUserHTMLParserErrorDomain, code: OZLModelUser.OZLUserHTMLParserErrorCode.XMLParsingError.rawValue, userInfo: [NSLocalizedDescriptionKey: "The Redmine server returned something we couldn't make sense of."])
        }
        if let imageEles = ele.children(withRootXPath: "//div[@id='content']/h2/img[@class='gravatar']"), let gravatarImage = imageEles.first as? RXMLElement {
            self.gravatarURL = gravatarImage.attribute("src")
        }

        // will need these when we do profile pages
//        let infoListItems = ele.children(withRootXPath: "//div[@id='content']/div[@class='splitcontentleft']/ul/li")
    }
}
