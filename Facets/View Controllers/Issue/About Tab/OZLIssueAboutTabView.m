//
//  OZLIssueAboutTabView.m
//  Facets
//
//  Created by Justin Hill on 11/7/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

#import "OZLIssueAboutTabView.h"
#import "Facets-Swift.h"

@interface OZLIssueAboutTabView ()

@property NSMutableArray *fieldViews;
@property CGFloat minColumnWidth;
@property NSInteger currentLayoutItemsPerColumn;
@property OZLModelIssue *issueModel;

@end

@implementation OZLIssueAboutTabView

@synthesize heightChangeListener;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    
    return self;
}

- (void)setup {
    self.fieldViews = [NSMutableArray array];
    self.fieldNameFont = [UIFont OZLMediumSystemFontOfSize:12.];
    self.fieldValueFont = [UIFont systemFontOfSize:12];
    self.minColumnWidth = 120.;
}

- (void)applyIssueModel:(OZLModelIssue *)issueModel {
    [self.fieldViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.issueModel = issueModel;
    
    NSMutableArray *fieldViews = [NSMutableArray array];
    
    if (issueModel.status.name) {
        [fieldViews addObject:[[OZLAboutTabFieldView alloc] initWithTitle:@"Status".uppercaseString value:issueModel.status.name]];
    }
    
    if (issueModel.priority.name) {
        [fieldViews addObject:[[OZLAboutTabFieldView alloc] initWithTitle:@"Priority".uppercaseString value:issueModel.priority.name]];
    }
    
    if (issueModel.category.name) {
        [fieldViews addObject:[[OZLAboutTabFieldView alloc] initWithTitle:@"Category".uppercaseString value:issueModel.category.name]];
    }
    
    if (issueModel.targetVersion.name) {
        [fieldViews addObject:[[OZLAboutTabFieldView alloc] initWithTitle:@"Target version".uppercaseString value:issueModel.targetVersion.name]];
    }
    
    if (issueModel.author.name) {
        [fieldViews addObject:[[OZLAboutTabFieldView alloc] initWithTitle:@"Author".uppercaseString value:issueModel.author.name]];
    }
    
    for (OZLModelCustomField *field in issueModel.customFields) {
        OZLModelCustomField *cachedField = [OZLModelCustomField objectForPrimaryKey:@(field.fieldId)];
        
        if (field.value) {
            NSString *displayValue = [OZLModelCustomField displayValueForCustomFieldType:cachedField.type attributeId:cachedField.fieldId attributeValue:field.value];
            
            [fieldViews addObject:[[OZLAboutTabFieldView alloc] initWithTitle:field.name.uppercaseString value:displayValue]];
        }
    }
    
    self.fieldViews = fieldViews;
    
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    CGFloat usableWidth = self.frame.size.width - (self.contentPadding * 2);
    CGFloat colCount = floorf(usableWidth / self.minColumnWidth);
    CGFloat colWidth = usableWidth / colCount;
    NSInteger itemsPerColumn = ceilf(self.fieldViews.count / colCount);
    
    self.currentLayoutItemsPerColumn = itemsPerColumn;
    
    UILabel *previousFieldView;
    
    for (NSInteger i = 0; i < self.fieldViews.count; i++) {
        NSInteger colIndex = i / itemsPerColumn;
        NSInteger rowIndex = i % itemsPerColumn;
        UILabel *fieldView = self.fieldViews[i];
        
        if (!fieldView.superview) {
            [self addSubview:fieldView];
        }
        
        CGFloat xOffset = ceilf(self.contentPadding + (colIndex * colWidth));
        CGFloat yOffset;
        
        if (rowIndex == 0) {
            yOffset = ceilf(self.contentPadding);
        } else {
            yOffset = ceilf(previousFieldView.bottom + self.contentPadding);
        }
        
        fieldView.frame = (CGRect){{xOffset, yOffset}, [fieldView sizeThatFits:CGSizeMake(colWidth, CGFLOAT_MAX)]};
        previousFieldView = fieldView;
    }
}

- (CGFloat)intrinsicHeightWithWidth:(CGFloat)width {
    if (!self.fieldViews.count) {
        return 0;
    }
    
    static OZLIssueAboutTabView *sizingView;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingView = [[OZLIssueAboutTabView alloc] init];
    });
    
    sizingView.bounds = CGRectMake(0, 0, width, 0);
    sizingView.contentPadding = self.contentPadding;
    [sizingView applyIssueModel:self.issueModel];
    [sizingView layoutSubviews];
    
    UILabel *bottomRowLabel = sizingView.fieldViews[sizingView.currentLayoutItemsPerColumn - 1];
    
    return bottomRowLabel.bottom + self.contentPadding;
}

@end
