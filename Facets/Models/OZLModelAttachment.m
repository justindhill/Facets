//
//  OZLModelAttachment.m
//  Facets
//
//  Created by Justin Hill on 11/14/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

@import ISO8601;

#import "OZLModelAttachment.h"

@implementation OZLModelAttachment

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        [self applyValuesFromDictionary:dict];
    }
    
    return self;
}

- (void)applyValuesFromDictionary:(NSDictionary *)dict {
    NSDictionary *attacherDict = dict[@"author"];
    
    if ([attacherDict isKindOfClass:[NSDictionary class]]) {
        self.attacher = [[OZLModelUser alloc] initWithAttributeDictionary:attacherDict];
    }
    
    self.contentType = dict[@"content_type"];
    self.contentURL = dict[@"content_url"];
    self.creationDate = [NSDate dateWithISO8601String:dict[@"created_on"]];
    self.detailDescription = dict[@"description"];
    self.name = dict[@"filename"];
    self.size = [dict[@"filesize"] integerValue];
    self.attachmentID = [dict[@"id"] integerValue];
}

- (NSString *)thumbnailURL {
    if ([self.contentType hasPrefix:@"image"]) {
        NSURLComponents *c = [NSURLComponents componentsWithString:self.contentURL];
        c.path = [NSString stringWithFormat:@"/attachments/thumbnail/%ld", (long)self.attachmentID];
        
        return [c.URL.absoluteString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    return nil;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<OZLModelAttachment: %p> name: %@, attacher: %@", self, self.name, self.attacher.name];
}

@end
