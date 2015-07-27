//
//  MediaFeedCell.m
//  InstaProwler
//
//  Created by Andrey Yashnev on 27/07/15.
//  Copyright (c) 2015 Andrey Yashnev. All rights reserved.
//

#import "MediaFeedCell.h"
#import "InstagramMediaItem.h"
#import "InstagramUser.h"

@interface MediaFeedCell ()

@property (nonatomic, weak) IBOutlet UILabel *authorLabel;
@property (nonatomic, weak) IBOutlet UILabel *creationDateLabel;
@property (nonatomic, weak) IBOutlet UIImageView *photoImageView;
@property (nonatomic, weak) IBOutlet UILabel *commentsLabel;

@end


@implementation MediaFeedCell

#pragma mark - Static

+ (CGFloat)heightWithItem:(InstagramMediaItem *)item {
    CGFloat width = [UIScreen mainScreen].bounds.size.width - 10;
    CGRect paragraphRect =
    [[self attributedStringFromComments:item.comments] boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                                                    options:(NSStringDrawingUsesLineFragmentOrigin| NSStringDrawingUsesFontLeading)
                                                                    context:nil];
    return paragraphRect.size.height + 340;
}

+ (NSAttributedString *)attributedStringFromComments:(NSArray *)comments {
    UIFont *authorFont = [UIFont boldSystemFontOfSize:14];
    UIFont *commentFont = [UIFont systemFontOfSize:14];
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] init];
    
    for (InstagramMediaItemComment *itemComment in comments) {
        NSString *authorString = [NSString stringWithFormat:@"%@ ", itemComment.author.username];
        NSAttributedString *commentAuthorString = [[NSAttributedString alloc] initWithString:authorString attributes:    @{NSFontAttributeName : authorFont,                                                                                                                                     NSForegroundColorAttributeName : [UIColor blueColor]}];
        
        NSAttributedString *commentString = [[NSAttributedString alloc] initWithString:itemComment.text attributes:
                                             @{NSFontAttributeName : commentFont,
                                               NSForegroundColorAttributeName : [UIColor darkGrayColor]}];
        NSAttributedString *lineBreak = [[NSAttributedString alloc] initWithString:@"\n"];
        
        
        [attrString appendAttributedString:commentAuthorString];
        [attrString appendAttributedString:commentString];
        [attrString appendAttributedString:lineBreak];
    }
    return attrString;
}

#pragma mark - UIView

- (UIEdgeInsets)layoutMargins {
    return UIEdgeInsetsZero;
}

#pragma mark - Properties

- (void)setMediaItem:(InstagramMediaItem *)mediaItem {
    _mediaItem = mediaItem;
    [self updateUIWithItem:mediaItem];
}

#pragma mark - Private

- (void)updateUIWithItem:(InstagramMediaItem *)mediaItem {
    self.authorLabel.text = mediaItem.author.username;
    self.creationDateLabel.text = [self.dateFormatter stringFromDate:mediaItem.creationDate];
    self.commentsLabel.attributedText = [[self class] attributedStringFromComments:mediaItem.comments];
}

@end
