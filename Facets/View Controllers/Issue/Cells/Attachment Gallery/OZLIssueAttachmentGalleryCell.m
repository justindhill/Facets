//
//  OZLIssueAttachmentGalleryCell.m
//  Facets
//
//  Created by Justin Hill on 11/14/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

#import "OZLIssueAttachmentGalleryCell.h"
#import "OZLIssueAttachmentGalleryItemCell.h"
#import "Facets-Swift.h"

@interface OZLIssueAttachmentGalleryCell () <UICollectionViewDataSource, UICollectionViewDelegate>

@property BOOL isFirstLayout;
@property UICollectionView *galleryView;

@end

NSString * const OZLAttachmentCellReuseIdentifier = @"OZLAttachmentCellReuseIdentifier";

@implementation OZLIssueAttachmentGalleryCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.isFirstLayout = YES;
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        self.galleryView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        self.galleryView.delegate = self;
        self.galleryView.dataSource = self;
        self.galleryView.backgroundColor = [UIColor clearColor];
        self.galleryView.showsHorizontalScrollIndicator = NO;
        self.galleryView.showsVerticalScrollIndicator = NO;
        
        [self.galleryView registerClass:[OZLIssueAttachmentGalleryItemCell class] forCellWithReuseIdentifier:OZLAttachmentCellReuseIdentifier];
    }
    
    return self;
}

- (void)setAttachments:(NSArray<OZLModelAttachment *> *)attachments {
    if (attachments == _attachments) {
        return;
    }
    
    _attachments = attachments;
    [self.galleryView reloadData];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.isFirstLayout) {
        [self.contentView addSubview:self.galleryView];
    }
    
    CGFloat galleryYOffset = self.contentPadding / 2.;
    CGFloat galleryHeight = self.contentView.frame.size.height - galleryYOffset - self.contentPadding;
    self.galleryView.frame = (CGRect){{0, galleryYOffset}, {self.contentView.frame.size.width, galleryHeight}};
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.galleryView.collectionViewLayout;
    
    if (layout.sectionInset.left != self.contentPadding) {
        layout.sectionInset = UIEdgeInsetsMake(0, self.contentPadding, 0, self.contentPadding);
        layout.minimumInteritemSpacing = (self.contentPadding / 2.);
        [layout invalidateLayout];
    }
    
    const CGFloat itemWHRatio = 1.15;
    if (layout.itemSize.height != galleryHeight) {
        layout.itemSize = CGSizeMake(ceilf(galleryHeight * itemWHRatio), ceilf(galleryHeight));
        [layout invalidateLayout];
    }
    
    self.isFirstLayout = NO;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.attachments.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    OZLIssueAttachmentGalleryItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:OZLAttachmentCellReuseIdentifier forIndexPath:indexPath];
    cell.attachment = self.attachments[indexPath.row];
    cell.backgroundColor = [UIColor whiteColor];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(galleryCell:didSelectAttachment:withCellRelativeFrame:thumbnailImage:)]) {
        OZLIssueAttachmentGalleryItemCell *cell = (OZLIssueAttachmentGalleryItemCell *)[collectionView cellForItemAtIndexPath:indexPath];
        CGRect cellFrame = [cell convertRect:cell.frame toView:self];
        
        [self.delegate galleryCell:self didSelectAttachment:self.attachments[indexPath.row] withCellRelativeFrame:cellFrame thumbnailImage:cell.thumbnailImageView.image];
    }
}

@end
