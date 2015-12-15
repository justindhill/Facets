//
//  OZLModelIssue.m
//  RedmineMobile
//
//  Created by lizhijie on 7/15/13.

#import "OZLModelIssue.h"
#import "OZLModelProject.h"

@implementation OZLModelIssue

@synthesize description = _description;

- (id)initWithDictionary:(NSDictionary *)dic {
    if (self = [super init]) {
        _index = [[dic objectForKey:@"id"] integerValue];
        _projectId = [[[dic objectForKey:@"project"] objectForKey:@"id"] integerValue];
        id parent = [dic objectForKey:@"parent"];
        
        if (parent != nil) {
            _parentIssueId = [[parent objectForKey:@"id"] integerValue];
        } else {
            _parentIssueId = -1;
        }
        
        id tracker = [dic objectForKey:@"tracker"];
        
        if (tracker != nil) {
            _tracker = [[OZLModelTracker alloc] initWithAttributeDictionary:tracker];
        }
        
        id author = [dic objectForKey:@"author"];
        
        if (author != nil) {
            _author = [[OZLModelUser alloc] initWithAttributeDictionary:author];
        }
        
        id assignedTo = [dic objectForKey:@"assigned_to"];
        
        if (assignedTo != nil) {
            _assignedTo = [[OZLModelUser alloc] initWithAttributeDictionary:assignedTo];
        }
        
        id priority = [dic objectForKey:@"priority"];
        
        if (priority != nil) {
            _priority = [[OZLModelIssuePriority alloc] initWithAttributeDictionary:priority];
        }
        
        id status = [dic objectForKey:@"status"];
        
        if (status) {
            _status = [[OZLModelIssueStatus alloc] initWithAttributeDictionary:status];
        }
        
        id category = [dic objectForKey:@"category"];
        
        if (status) {
            _category = [[OZLModelIssueCategory alloc] initWithAttributeDictionary:category];
        }
        
        NSMutableArray *customFieldModels = [NSMutableArray array];
        id customFieldDicts = [dic objectForKey:@"custom_fields"];
        
        if ([customFieldDicts isKindOfClass:[NSArray class]]) {
            for (NSDictionary *customFieldDict in customFieldDicts) {
                [customFieldModels addObject:[[OZLModelCustomField alloc] initWithAttributeDictionary:customFieldDict]];
            }
        }
        
        self.customFields = customFieldModels;
        
        _subject = [dic objectForKey:@"subject"];
        _description = [dic objectForKey:@"description"];
        _startDate = [dic objectForKey:@"start_date"];
        _dueDate = [dic objectForKey:@"due_date"];
        _createdOn = [dic objectForKey:@"created_on"];
        _updatedOn = [dic objectForKey:@"updated_on"];
        _doneRatio = [[dic objectForKey:@"done_ratio"] floatValue];
        
        id targetVersion = dic[@"fixed_version"];
        
        if (targetVersion) {
            _targetVersion = [[OZLModelIssueTargetVersion alloc] initWithDictionary:targetVersion];
        }
        
        id spentHours = [dic objectForKey:@"spent_hours"];
        
        if (spentHours) {
            _spentHours = [spentHours floatValue];
        } else {
            _spentHours = 0.0f;
        }
        
        id estimatedHours = [dic objectForKey:@"estimated_hours"];
        
        if (spentHours) {
            _estimatedHours = [estimatedHours floatValue];
        } else {
            _estimatedHours = 0.0f;
        }
        
        NSArray *attachmentDictArray = dic[@"attachments"];
        
        if ([attachmentDictArray isKindOfClass:[NSArray class]]) {
            NSMutableArray <OZLModelAttachment *> *attachmentArray = [NSMutableArray array];
            
            for (NSDictionary *attachmentDict in attachmentDictArray) {
                OZLModelAttachment *attachment = [[OZLModelAttachment alloc] initWithDictionary:attachmentDict];
                [attachmentArray addObject:attachment];
            }
            
            self.attachments = attachmentArray;
        }
        
        NSArray *journalDictArray = dic[@"journals"];
        
        if ([journalDictArray isKindOfClass:[NSArray class]]) {
            NSMutableArray <OZLModelJournal *> *journalArray = [NSMutableArray array];
            
            for (NSDictionary *journalDict in journalDictArray) {
                OZLModelJournal *journal = [[OZLModelJournal alloc] initWithAttributes:journalDict];
                [journalArray addObject:journal];
            }
            
            self.journals = journalArray;
        }
    }

    return self;
}

- (NSMutableDictionary *)toParametersDic {
    
    NSMutableDictionary *issueData = [[NSMutableDictionary alloc] init];
    
    if (_projectId > 0) {
        [issueData setObject:[NSNumber numberWithInteger:_projectId] forKey:@"project_id"];
    }
    
    if (_tracker && _tracker.trackerId > 0) {
        [issueData setObject:[NSNumber numberWithInteger:_tracker.trackerId] forKey:@"tracker_id"];
    }
    
    if (_status && _status.statusId > 0) {
        [issueData setObject:[NSNumber numberWithInteger:_status.statusId] forKey:@"status_id"];
    }
    
    if (_priority && _priority.init > 0) {
        [issueData setObject:[NSNumber numberWithInteger:_priority.priorityId] forKey:@"priority_id"];
    }
    
    if (_subject.length > 0) {
        [issueData setObject:_subject forKey:@"subject"];
    }
    
    if (_description.length > 0) {
        [issueData setObject:_description forKey:@"description"];
    }
    
    if (_category) {
        [issueData setObject:[NSNumber numberWithInteger:_category.categoryId] forKey:@"category_id"];
    }
    
    if (_assignedTo && _assignedTo.userId > 0) {
        [issueData setObject:[NSNumber numberWithInteger:_assignedTo.userId] forKey:@"assigned_to_id"];
    }
    
    if (_parentIssueId > 0) {
        [issueData setObject:[NSNumber numberWithInteger:_parentIssueId] forKey:@"parent_issue_id"];
    }
    
    if (_spentHours > 0) {
        [issueData setObject:[NSNumber numberWithFloat:_spentHours] forKey:@"spent_hours"];
    }
    
    if (_estimatedHours > 0) {
        [issueData setObject:[NSNumber numberWithFloat:_estimatedHours] forKey:@"estimated_hours"];
    }

    return [[NSMutableDictionary alloc] initWithObjectsAndKeys:issueData, @"issue", nil];
}

+ (nullable NSString *)displayValueForAttributeName:(NSString *)name attributeId:(NSInteger)attributeId {
    if ([name isEqualToString:@"project_id"]) {
        return [[OZLModelProject objectForPrimaryKey:@(attributeId)] name];
    } else if ([name isEqualToString:@"tracker_id"]) {
        return [[OZLModelTracker objectForPrimaryKey:@(attributeId)] name];
    } else if ([name isEqualToString:@"fixed_version_id"]) {
        return [[OZLModelVersion objectForPrimaryKey:@(attributeId)] name];
    } else if ([name isEqualToString:@"status_id"]) {
        return [[OZLModelIssueStatus objectForPrimaryKey:@(attributeId)] name];
    } else if ([name isEqualToString:@"assigned_to_id"]) {
        return [[OZLModelUser objectForPrimaryKey:@(attributeId)] name];
    } else if ([name isEqualToString:@"category_id"]) {
        return [[OZLModelIssueCategory objectForPrimaryKey:@(attributeId)] name];
    } else if ([name isEqualToString:@"priority_id"]) {
        return [[OZLModelIssuePriority objectForPrimaryKey:@(attributeId)] name];
    }
    
    return nil;
}

+ (nonnull NSString *)displayNameForAttributeName:(nonnull NSString *)attributeName {
    if ([attributeName isEqualToString:@"project_id"]) {
        return @"Project";
    } else if ([attributeName isEqualToString:@"tracker_id"]) {
        return @"Tracker";
    } else if ([attributeName isEqualToString:@"fixed_version_id"]) {
        return @"Target version";
    } else if ([attributeName isEqualToString:@"status_id"]) {
        return @"Status";
    } else if ([attributeName isEqualToString:@"assigned_to_id"]) {
        return @"Assignee";
    } else if ([attributeName isEqualToString:@"category_id"]) {
        return @"Category";
    } else if ([attributeName isEqualToString:@"priority_id"]) {
        return @"Priority";
    }
        
    return attributeName;
}

@end
