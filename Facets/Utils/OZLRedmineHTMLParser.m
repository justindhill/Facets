//
//  OZLRedmineHTMLParser.m
//  Facets
//
//  Created by Justin Hill on 12/1/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

#import "OZLRedmineHTMLParser.h"
#import "OZLModelCustomField.h"
#import "OZLModelStringContainer.h"
#import <RaptureXML/RXMLElement.h>
#import <GTMNSStringHTMLAdditions/GTMNSString+HTML.h>

@implementation OZLRedmineHTMLParser

+ (NSNumberFormatter *)formatter {
    static NSNumberFormatter *formatter;
    
    if (!formatter) {
        formatter = [[NSNumberFormatter alloc] init];
    }
    
    return formatter;
}

+ (NSArray<OZLModelCustomField *> *)parseCustomFieldsHTMLString:(NSString *)html error:(NSError **)error {
    NSMutableArray *fields = [NSMutableArray array];
    
    NSString *plainString = [html gtm_stringByUnescapingFromHTML];
    
    RXMLElement *ele = [RXMLElement elementFromXMLString:plainString encoding:NSUTF8StringEncoding];
    NSArray *fieldParagraphs = [ele childrenWithRootXPath:@"//div[@id='attributes']/div[@class='splitcontent'][2]/div/p"];
    
    for (RXMLElement *p in fieldParagraphs) {
        RXMLElement *titleSpan = [[p child:@"label"] child:@"span"];
        NSString *fieldName = [titleSpan.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *rawFieldIdString = [[p child:@"label"] attribute:@"for"];
        NSString *fieldIdString = [[rawFieldIdString componentsSeparatedByString:@"_"] lastObject];
        NSInteger fieldId = [[self.formatter numberFromString:fieldIdString] integerValue];
        OZLModelCustomFieldType fieldType = [self fieldTypeFromParagraph:p];
        
//        NSLog(@"field name: %@, id: %ld, type: %ld", fieldName, (long)fieldId, (long)fieldType);
        
        NSArray<OZLModelStringContainer *> *options;
        
#warning Custom field support is incomplete! Need to parse the rest of the types.
        if (fieldType == OZLModelCustomFieldTypeInvalid) {
            continue;
        } else if (fieldType == OZLModelCustomFieldTypeList) {
             options = [self optionsFromListFieldParagraph:p];
        }
        
        OZLModelCustomField *field = [[OZLModelCustomField alloc] init];
        field.name = fieldName;
        field.type = fieldType;
        field.fieldId = fieldId;
        
        if (options.count > 0) {
            [field.options addObjects:options];
        }
        
        [fields addObject:field];
    }
    
    return fields;
}

+ (NSArray<OZLModelStringContainer *> *)optionsFromListFieldParagraph:(RXMLElement *)p {
    NSMutableArray *options = [NSMutableArray array];
    [p iterate:@"select.option" usingBlock:^(RXMLElement *optionEle) {
        NSString *optionText = [optionEle.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//        NSLog(@"option value: %@", optionText);
        
        if (optionText.length == 0) {
            return;
        }
        
        OZLModelStringContainer *option = [OZLModelStringContainer containerWithString:optionText];
        
        [options addObject:option];
    }];
    
    return options;
}

+ (OZLModelCustomFieldType)fieldTypeFromParagraph:(RXMLElement *)p {
    
    RXMLElement *valueContainer = [self valueContainerFromParagraph:p];
    NSString *fieldTypeString = [valueContainer attribute:@"class"];
    
    if (!fieldTypeString) {
        return OZLModelCustomFieldTypeInvalid;
    }
    
    if ([fieldTypeString containsString:@"list_cf"]) {
        return OZLModelCustomFieldTypeList;
    } else if ([fieldTypeString containsString:@"version_cf"]) {
        return OZLModelCustomFieldTypeVersion;
    } else if ([fieldTypeString containsString:@"int_cf"]) {
        return OZLModelCustomFieldTypeInteger;
    } else if ([fieldTypeString containsString:@"bool_cf"]) {
        return OZLModelCustomFieldTypeBoolean;
    } else if ([fieldTypeString containsString:@"string_cf"]) {
        return OZLModelCustomFieldTypeText;
    } else if ([fieldTypeString containsString:@"text_cf"]) {
        return OZLModelCustomFieldTypeLongText;
    } else if ([fieldTypeString containsString:@"user_cf"]) {
        return OZLModelCustomFieldTypeUser;
    } else if ([fieldTypeString containsString:@"link_cf"]) {
        return OZLModelCustomFieldTypeLink;
    } else if ([fieldTypeString containsString:@"float_cf"]) {
        return OZLModelCustomFieldTypeFloat;
    } else if ([fieldTypeString containsString:@"date_cf"]) {
        return OZLModelCustomFieldTypeDate;
        
    } else {
        NSAssert(fieldTypeString, @"Found a field type that isn't implemented!");
        NSLog(@"Found a field type that isn't implemented!");
        return OZLModelCustomFieldTypeInvalid;
    }
}

+ (RXMLElement *)valueContainerFromParagraph:(RXMLElement *)p {
    RXMLElement *valueContainer = [p child:@"select"];
    
    if (!valueContainer) {
        valueContainer = [p child:@"input"];
    }
    
    if (!valueContainer) {
        valueContainer = [p child:@"span"];
    }
    
    if (!valueContainer) {
        valueContainer = [p child:@"textarea"];
    }
    
    return valueContainer;
}

@end
