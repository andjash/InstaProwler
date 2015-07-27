//
//  MediaFeedCell.h
//  InstaProwler
//
//  Created by Andrey Yashnev on 27/07/15.
//  Copyright (c) 2015 Andrey Yashnev. All rights reserved.
//

#import <UIKit/UIKit.h>

@class InstagramMediaItem;

@interface MediaFeedCell : UITableViewCell

@property (nonatomic, strong) InstagramMediaItem *mediaItem;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

+ (CGFloat)heightWithItem:(InstagramMediaItem *)item;

@end
