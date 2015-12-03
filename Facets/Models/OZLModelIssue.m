//
//  OZLModelIssue.m
//  RedmineMobile
//
//  Created by lizhijie on 7/15/13.

#import "OZLModelIssue.h"

@implementation OZLModelIssue

@synthesize description = _description;

- (id)initWithDictionary:(NSDictionary *)dic {
    if (self = [super init]) {
        _index = [[dic objectForKey:@"id"] intValue];
        _projectId = [[[dic objectForKey:@"project"] objectForKey:@"id"] intValue];
        id parent = [dic objectForKey:@"parent"];
        
        if (parent != nil) {
            _parentIssueId = [[parent objectForKey:@"id"] intValue];
        } else {
            _parentIssueId = -1;
        }
        
        id tracker = [dic objectForKey:@"tracker"];
        
        if (tracker != nil) {
            _tracker = [[OZLModelTracker alloc] initWithAttributeDictionary:tracker];
        }
        
        id author = [dic objectForKey:@"author"];
        
        if (author != nil) {
            _author = [[OZLModelUser alloc] initWithDictionary:author];
        }
        
        id assignedTo = [dic objectForKey:@"assigned_to"];
        
        if (assignedTo != nil) {
            _assignedTo = [[OZLModelUser alloc] initWithDictionary:assignedTo];
        }
        
        id priority = [dic objectForKey:@"priority"];
        
        if (priority != nil) {
            _priority = [[OZLModelIssuePriority alloc] initWithDictionary:priority];
        }
        
        id status = [dic objectForKey:@"status"];
        
        if (status) {
            _status = [[OZLModelIssueStatus alloc] initWithDictionary:status];
        }
        
        id category = [dic objectForKey:@"category"];
        
        if (status) {
            _category = [[OZLModelIssueCategory alloc] initWithAttributeDictionary:category];
        }
        
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
    
    if (_status && _status.index > 0) {
        [issueData setObject:[NSNumber numberWithInteger:_status.index] forKey:@"status_id"];
    }
    
    if (_priority && _priority.init > 0) {
        [issueData setObject:[NSNumber numberWithInteger:_priority.index] forKey:@"priority_id"];
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
    
    if (_assignedTo && _assignedTo.index > 0) {
        [issueData setObject:[NSNumber numberWithInteger:_assignedTo.index] forKey:@"assigned_to_id"];
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

@end
