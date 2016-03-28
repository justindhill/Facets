//
//  OZLModelIssue.m
//  RedmineMobile
//
//  Created by lizhijie on 7/15/13.

#import "OZLModelIssue.h"
#import "OZLModelProject.h"
#import "OZLModelVersion.h"
#import "Facets-Swift.h"

@interface OZLModelIssue ()

@property (nullable, strong) NSMutableDictionary *mutableChangeDictionary;

@end

@implementation OZLModelIssue

@synthesize description = _description;

- (id)initWithDictionary:(NSDictionary *)dic {
    if (self = [super init]) {
        self.modelDiffingEnabled = NO;
        
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
        _startDate = [NSDate dateWithISO8601String:[dic objectForKey:@"start_date"]];
        _dueDate = [NSDate dateWithISO8601String:[dic objectForKey:@"due_date"]];
        _createdOn = [NSDate dateWithISO8601String:[dic objectForKey:@"created_on"]];
        _updatedOn = [NSDate dateWithISO8601String:[dic objectForKey:@"updated_on"]];
        _doneRatio = [[dic objectForKey:@"done_ratio"] floatValue];
        
        id targetVersion = dic[@"fixed_version"];
        
        if (targetVersion) {
            _targetVersion = [[OZLModelVersion alloc] initWithAttributeDictionary:targetVersion];
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

- (NSDictionary *)changeDictionary {
    return self.mutableChangeDictionary;
}

#pragma mark - Setters
- (void)setModelDiffingEnabled:(BOOL)modelDiffingEnabled {
    if (modelDiffingEnabled != _modelDiffingEnabled) {
        _modelDiffingEnabled = modelDiffingEnabled;
        
        if (modelDiffingEnabled) {
            self.mutableChangeDictionary = [NSMutableDictionary dictionary];
        } else {
            self.mutableChangeDictionary = nil;
        }
    }
}

- (void)setProjectId:(NSInteger)projectId {
    _projectId = projectId;
    
    if (self.modelDiffingEnabled && projectId) {
        self.mutableChangeDictionary[@"project_id"] = @(projectId);
    }
}

- (void)setParentIssueId:(NSInteger)parentIssueId {
    _parentIssueId = parentIssueId;
    
    if (self.modelDiffingEnabled && parentIssueId) {
        self.mutableChangeDictionary[@"parent_issue_id"] = @(parentIssueId);
    }
}

- (void)setTracker:(OZLModelTracker *)tracker {
    _tracker = tracker;
    
    if (self.modelDiffingEnabled && tracker) {
        self.mutableChangeDictionary[@"tracker_id"] = @(tracker.trackerId);
    }
}

- (void)setAssignedTo:(OZLModelUser *)assignedTo {
    _assignedTo = assignedTo;
    
    if (self.modelDiffingEnabled && assignedTo) {
        self.mutableChangeDictionary[@"assigned_to_id"] = @(assignedTo.userId);
    }
}

- (void)setPriority:(OZLModelIssuePriority *)priority {
    _priority = priority;
    
    if (self.modelDiffingEnabled && priority) {
        self.mutableChangeDictionary[@"priority_id"] = @(priority.priorityId);
    }
}

- (void)setStatus:(OZLModelIssueStatus *)status {
    _status = status;
    
    if (self.modelDiffingEnabled && status) {
        self.mutableChangeDictionary[@"status_id"] = @(status.statusId);
    }
}

- (void)setTargetVersion:(OZLModelVersion *)targetVersion {
    _targetVersion = targetVersion;
    
    if (self.modelDiffingEnabled && targetVersion) {
        self.mutableChangeDictionary[@"target_version_id"] = @(targetVersion.versionId);
    }
}

- (void)setCategory:(OZLModelIssueCategory *)category {
    _category = category;
    
    if (self.modelDiffingEnabled && category) {
        self.mutableChangeDictionary[@"category_id"] = @(category.categoryId);
    }
}

- (void)setSubject:(NSString *)subject {
    _subject = subject;
    
    if (self.modelDiffingEnabled && subject) {
        self.mutableChangeDictionary[@"subject"] = subject;
    }
}

- (void)setDescription:(NSString *)description {
    _description = description;
    
    if (self.modelDiffingEnabled && description) {
        self.mutableChangeDictionary[@"description"] = description;
    }
}

- (void)setStartDate:(NSDate *)startDate {
    _startDate = startDate;
    
    if (self.modelDiffingEnabled && startDate) {
        self.mutableChangeDictionary[@"start_date"] = [startDate ISO8601String];
    }
}

- (void)setDueDate:(NSDate *)dueDate {
    _dueDate = dueDate;
    
    if (self.modelDiffingEnabled && dueDate) {
        self.mutableChangeDictionary[@"due_date"] = [dueDate ISO8601String];
    }
}

- (void)setCreatedOn:(NSDate *)createdOn {
    _createdOn = createdOn;
    
    if (self.modelDiffingEnabled && createdOn) {
        self.mutableChangeDictionary[@"created_on"] = [createdOn ISO8601String];
    }
}

- (void)setUpdatedOn:(NSDate *)updatedOn {
    _updatedOn = updatedOn;
    
    if (self.modelDiffingEnabled && updatedOn) {
        self.mutableChangeDictionary[@"updated_on"] = [updatedOn ISO8601String];
    }
}

- (void)setDoneRatio:(float)doneRatio {
    _doneRatio = doneRatio;
    
    if (self.modelDiffingEnabled) {
        self.mutableChangeDictionary[@"done_ratio"] = @(doneRatio);
    }
}

- (void)setSpentHours:(float)spentHours {
    _spentHours = spentHours;
    
    if (self.modelDiffingEnabled) {
        self.mutableChangeDictionary[@"spent_hours"] = @(spentHours);
    }
}

- (void)setEstimatedHours:(float)estimatedHours {
    _estimatedHours = estimatedHours;
    
    if (self.modelDiffingEnabled) {
        self.mutableChangeDictionary[@"estimated_hours"] = @(estimatedHours);
    }
}

- (void)setNotes:(NSString *)notes {
    _notes = notes;
    
    if (self.modelDiffingEnabled && notes) {
        self.mutableChangeDictionary[@"notes"] = notes;
    }
}

- (id)copyWithZone:(NSZone *)zone {
    OZLModelIssue *copy = [[OZLModelIssue alloc] init];
    copy.index = self.index;
    copy.projectId = self.projectId;
    copy.parentIssueId = self.parentIssueId;
    copy.tracker = self.tracker;
    copy.author = self.author;
    copy.assignedTo = self.assignedTo;
    copy.priority = self.priority;
    copy.status = self.status;
    copy.category = self.category;
    copy.targetVersion = self.targetVersion;
    copy.customFields = self.customFields;
    copy.subject = self.subject;
    copy.description = self.description;
    copy.startDate = self.startDate;
    copy.dueDate = self.dueDate;
    copy.createdOn = self.createdOn;
    copy.updatedOn = self.updatedOn;
    copy.doneRatio = self.doneRatio;
    copy.spentHours = self.spentHours;
    copy.estimatedHours = self.estimatedHours;
    copy.notes = self.notes;
    copy.attachments = self.attachments;
    copy.journals = self.journals;
    
    return copy;
}

@end
