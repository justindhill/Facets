//
//  OZLModelAttachment.h
//  Facets
//
//  Created by Justin Hill on 11/14/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

@import Foundation;
#import "OZLModelUser.h"

typedef NS_ENUM(NSInteger, OZLAttachmentFileType) {
    OZLAttachmentFileTypeUnknown,
    OZLAttachmentFileTypeText,
    OZLAttachmentFileTypeImage,
    OZLAttachmentFileTypeVideo,
    OZLAttachmentFileTypeAudio
};

@interface OZLModelAttachment : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)dict;

/**
 *  @brief Who attached this attachment
 */
@property (strong) OZLModelUser *attacher;

/**
 *  @brief The mime type of the attachment
 */
@property (strong) NSString *mimeType;

/**
 *  @brief The URL at which the attachment can be accessed
 */
@property (strong) NSString *contentURL;

/**
 *  @brief When the attachment was created
 */
@property (strong) NSDate *creationDate;

/**
 *  @brief A short description of the attachment
 */
@property (strong) NSString *detailDescription;

/**
 *  @brief The name of the the attachment, as provided by the user
 */
@property (strong) NSString *name;

/**
 *  @brief Size of the attachment in bytes.
 */
@property NSInteger size;

/**
 *  @brief The Redmine ID of the attachment
 */
@property NSInteger attachmentID;

/**
 *  @brief The URL for the attachment's thumbnail. nil if the attachment isn't an image.
 */
@property (readonly) NSString *thumbnailURL;

/**
 *  @brief The key used to cache this attachment locally.
 */
@property (readonly) NSString *cacheKey;

/**
 *  @brief The classification of the attachment based on its mimeType; for instance, an attachment with 
 *         mimeType video/mp4 would return OZLAttachmentFileTypeVideo.
 */
@property (readonly) OZLAttachmentFileType fileClassification;

/**
 *  @brief The name of the icon associated with the fileClassification of the attachment.
 */
@property (readonly) NSString *fileClassificationImageName;

@end
