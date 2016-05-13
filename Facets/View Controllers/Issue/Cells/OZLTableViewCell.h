//
//  OZLTableViewCell.h
//  Facets
//
//  Created by Justin Hill on 11/6/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

@import UIKit;

@interface OZLTableViewCell : UITableViewCell

/**
 *  @brief The amount of padding to be applied on each edge
 */
@property CGFloat contentPadding;

+ (CGFloat)heightForWidth:(CGFloat)width model:(NSObject *)model layoutMargins:(UIEdgeInsets)layoutMargins;

@end
