//
//  OZLModelAttachment.m
//  Facets
//
//  Created by Justin Hill on 11/14/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

@import ISO8601;

#import "OZLModelAttachment.h"

@interface OZLModelAttachment ()

@property NSString *fileExtension;

@end

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
    
    self.mimeType = dict[@"content_type"];
    self.fileExtension = [[[dict[@"content_url"] componentsSeparatedByString:@"."] lastObject] lowercaseString];
    self.contentURL = dict[@"content_url"];
    self.creationDate = [NSDate dateWithISO8601String:dict[@"created_on"]];
    self.detailDescription = dict[@"description"];
    self.name = dict[@"filename"];
    self.size = [dict[@"filesize"] integerValue];
    self.attachmentID = [dict[@"id"] integerValue];
}

- (NSString *)thumbnailURL {
    if ([self.mimeType hasPrefix:@"image"]) {
        NSURLComponents *c = [NSURLComponents componentsWithString:self.contentURL];
        c.path = [[NSString stringWithFormat:@"/attachments/thumbnail/%ld", (long)self.attachmentID] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
        
        return c.URL.absoluteString;
    }
    
    return nil;
}

- (OZLAttachmentFileType)fileClassification {
    if (self.mimeType) {
        if ([self.mimeType containsString:@"image"]) {
            return OZLAttachmentFileTypeImage;
        } else if ([self.mimeType containsString:@"video"] ||
                   [self.mimeType containsString:@"mp4"]) {
            return OZLAttachmentFileTypeVideo;
        } else if ([self.mimeType containsString:@"audio"]) {
            return OZLAttachmentFileTypeAudio;
        } else if ([self.mimeType containsString:@"text"]) {
            return OZLAttachmentFileTypeText;
        }
    } else if (self.fileExtension) {
        if ([self.fileExtension isEqualToString:@"png"]) {
            return OZLAttachmentFileTypeImage;
        }
    }

    return OZLAttachmentFileTypeUnknown;
}

- (NSString *)fileClassificationImageName {
    switch (self.fileClassification) {
        case OZLAttachmentFileTypeText: return @"icon-filetype-text";
        case OZLAttachmentFileTypeImage: return @"icon-filetype-image";
        case OZLAttachmentFileTypeAudio: return @"icon-filetype-audio";
        case OZLAttachmentFileTypeVideo: return @"icon-filetype-video";

        default: return @"icon-filetype-unknown";
    }
}

- (NSString *)cacheKey {
#warning Revisit this choice of cache key before shipping
    return self.contentURL;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<OZLModelAttachment: %p> name: %@, attacher: %@", self, self.name, self.attacher.name];
}

@end
